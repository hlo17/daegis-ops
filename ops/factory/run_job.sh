#!/usr/bin/env bash
set -Eeuo pipefail
source ops/factory/_lib.sh

JOB_FILE="${1:?job json required}"
[[ ! -f "$JOB_FILE" ]] && { echo "NO_JOB"; exit 2; }

JOB_ID="$(jq -r '.job_id // "unknown"' "$JOB_FILE")"
INTENT="$(jq -r '.intent // "unknown"' "$JOB_FILE")"
ROLE="$(jq -r '.role // ""' "$JOB_FILE")"
PHASE="$(jq -r '.phase // "unknown"' "$JOB_FILE")"
TIMEOUT_SEC="$(jq -r '.timeout_sec // 60' "$JOB_FILE")"
DRY="$(jq -r '.dry_run // false' "$JOB_FILE")"

# role binding
if [[ -z "$ROLE" || "$ROLE" == "null" ]] && [[ "$INTENT" != "unknown" ]]; then
  ROLE="$(role_for_intent "$INTENT")"
fi
[[ -z "$ROLE" || "$ROLE" == "null" ]] && { echo "ROLE_MISSING"; exit 2; }

# HMAC gate (non-dry only)
if [[ "$DRY" != "true" ]]; then
  ver="$(verify_hmac "$JOB_FILE" || true)"
  if [[ "$ver" != "OK" ]]; then
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" intent="$INTENT" role="$ROLE" phase="$PHASE" event="deny" reason="hmac_${ver}")"
    echo "SIG_${ver}"
    exit 2
  fi
fi

rc_total=0
started=0
finish() {
  if [[ $started -eq 1 ]]; then
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" event="job_end" rc="$rc_total")"
  fi
}
trap finish EXIT

journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" intent="$INTENT" role="$ROLE" phase="$PHASE" event="job_start")"
started=1

# materialize commands once to avoid pipes/subshell
TMP="$(mktemp)"
jq -c '.commands[]' "$JOB_FILE" > "$TMP"
len="$(wc -l < "$TMP" | tr -d ' ')"
step=0

for (( idx=0; idx<len; idx++ )); do
  ((step++))
  row="$(sed -n "$((idx+1))p" "$TMP")"

  # tokens: one per line, then build bash array safely
  tokens=()
  while IFS= read -r tok; do
    [[ -n "$tok" ]] && tokens+=( "$tok" )
  done < <(echo "$row" | jq -r '.[]')

  # guard empty
  [[ ${#tokens[@]} -eq 0 ]] && {
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="skip" reason="no_tokens")"
    continue
  }

  # RBAC
  if ! is_cmd_allowed_tokens "$ROLE" -- "${tokens[@]}"; then
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="deny" cmd="$(printf '%s ' "${tokens[@]}")" reason="not_allowed")"
    rc_total=126
    continue
  fi

  # DRY
  if [[ "$DRY" == "true" ]]; then
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="dry_ok" cmd="$(printf '%s ' "${tokens[@]}")")"
    continue
  fi

  # EXEC
  out="logs/jobs/${JOB_ID}.${step}.out"
  err="logs/jobs/${JOB_ID}.${step}.err"
  mkdir -p "$(dirname "$out")"
  if safe_exec_tokens "$TIMEOUT_SEC" -- "${tokens[@]}" >"$out" 2>"$err"; then
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="ok" out_sha="$(hash_file "$out")" err_sha="$(hash_file "$err")")"
  else
    rc=$?
    rc_total=$rc
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="fail" rc="$rc" err_sha="$(hash_file "$err")")"
  fi
done

rm -f "$TMP"
exit "$rc_total"
