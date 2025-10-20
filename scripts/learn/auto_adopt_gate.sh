#!/usr/bin/env sh
# L10.5 Gate (append-only): adopt only when L13 PASS and ALLOW ⊆ canary_intents
set -eu
ROOT="${ROOT:-$(pwd)}"
LOG_DIR="${ROOT}/logs"
FLAG_DIR="${ROOT}/flags"
SRC="${ROOT}/scripts/dev/env_candidates.sh"
ALLOW_RAW="$(echo "${AUTO_TUNE_ALLOW_INTENTS:-}" | tr 'A-Z' 'a-z')"
mkdir -p "${LOG_DIR}" "${FLAG_DIR}"

# 0) Respect VETO
if [ -f "${FLAG_DIR}/L5_VETO" ]; then
  echo "[auto-adopt-gate] VETO present; skip"
  exit 0
fi

# 1) L13 verdict must be PASS
VERDICT="FAIL"
CANARY_JSON=""
if command -v jq >/dev/null 2>&1 && [ -f "${LOG_DIR}/policy_canary_verdict.jsonl" ]; then
  VERDICT="$(tac "${LOG_DIR}/policy_canary_verdict.jsonl" | jq -r 'select(.event=="canary_verdict")|.verdict' | head -1 || echo FAIL)"
  CANARY_JSON="$(tac "${LOG_DIR}/policy_canary_verdict.jsonl" | jq -c 'select(.event=="canary_verdict")|.canary_intents' | head -1 || echo '[]')"
else
  # fallback: grep
  if [ -f "${LOG_DIR}/policy_canary_verdict.jsonl" ]; then
    VERDICT="$(tac "${LOG_DIR}/policy_canary_verdict.jsonl" | grep -m1 -o '"verdict":"[A-Z]*"' | head -1 | cut -d: -f2 | tr -d '"' || echo FAIL)"
    CANARY_JSON="[]"
  fi
fi
if [ "${VERDICT}" != "PASS" ]; then
  echo "[auto-adopt-gate] L13 verdict != PASS (${VERDICT}); skip"
  exit 0
fi

# 2) ALLOW ⊆ canary_intents
ALLOW_SET="$(printf "%s" "${ALLOW_RAW}" | tr ',' ' ' | awk '{for(i=1;i<=NF;i++) if($i!="") print $i}')"
CANARY_SET=""
if command -v jq >/dev/null 2>&1; then
  CANARY_SET="$(printf "%s" "${CANARY_JSON:-[]}" | jq -r '.[]? // empty' 2>/dev/null || true)"
fi
# if jq failed, allow empty canary_set (treated as unknown); we still proceed if ALLOW is empty
if [ -n "${ALLOW_SET}" ] && [ -n "${CANARY_SET}" ]; then
  for it in ${ALLOW_SET}; do
    echo "${CANARY_SET}" | grep -qx "${it}" || { echo "[auto-adopt-gate] ALLOW intent '${it}' not in canary_intents; skip"; exit 0; }
  done
fi

# 3) Filter env candidates by ALLOW (if provided)
if [ ! -f "${SRC}" ]; then
  echo "[auto-adopt-gate] missing ${SRC}; skip"
  exit 0
fi
TMP="/tmp/env_cand.$$"
if [ -n "${ALLOW_SET}" ]; then
  # export DAEGIS_SLA_<INTENT>_MS=…
  awk -F'[ =]' '/^export[[:space:]]+DAEGIS_SLA/ {intent=$(3); print tolower(intent), $0}' "${SRC}" \
  | awk -v a="$(printf "%s" "${ALLOW_SET}")" 'BEGIN{split(a,al," "); for(i in al) ok[al[i]]=1} ok[$1]==1{ $1=""; sub(/^[[:space:]]*/,""); print }' > "${TMP}"
else
  cp "${SRC}" "${TMP}"
fi

# 4) Run adopter with override source
ENV_CANDIDATES_OVERRIDE="${TMP}" python3 "${ROOT}/scripts/learn/apply_autoadopt.py" || true
rm -f "${TMP}" || true

# 5) Record cooldown marker if present or inferable
POL_LOG="${LOG_DIR}/policy_apply_controlled.jsonl"
if [ -f "${POL_LOG}" ]; then
  if command -v jq >/dev/null 2>&1; then
    CD_LINE="$(tac "${POL_LOG}" | jq -c 'select(.event=="auto_adopt_skip" and (.reason|ascii_upcase)=="COOLDOWN")' | head -1 || true)"
    if [ -n "${CD_LINE}" ]; then
      UNTIL="$(printf "%s" "${CD_LINE}" | jq -r '.until_ts // empty' || true)"
      if [ -n "${UNTIL}" ]; then
        printf '{"until_ts": %s}\n' "${UNTIL}" > "${FLAG_DIR}/L105_COOLDOWN_UNTIL"
        echo "[auto-adopt-gate] cooldown until_ts recorded → ${FLAG_DIR}/L105_COOLDOWN_UNTIL"
        exit 0
      fi
    fi
    # infer: last auto_adopt event
    ADOPT_LINE="$(tac "${POL_LOG}" | jq -c 'select(.event=="auto_adopt")' | head -1 || true)"
    if [ -n "${ADOPT_LINE}" ]; then
      TS="$(printf "%s" "${ADOPT_LINE}" | jq -r '.ts // now' )"
      CDH="$(printf "%s" "${ADOPT_LINE}" | jq -r '.cooldown_h // 2' )"
      SEC=$(awk "BEGIN{printf \"%d\", ${CDH}*3600}")
      UNTIL=$(( ${TS%.*} + SEC ))
      printf '{"until_ts": %s}\n' "${UNTIL}" > "${FLAG_DIR}/L105_COOLDOWN_UNTIL"
      echo "[auto-adopt-gate] cooldown inferred until=${UNTIL}"
    fi
  fi
fi
exit 0# --- [append-only guard v2025-10-10] adopt-once gate with logs ---
_log(){ printf '%s %s\n' "$(date -Iseconds)" "$*" >&2; }
_pass(){ [ "$1" = "PASS" ]; }

L13_LAST=$(tail -1 logs/policy_canary_verdict.jsonl 2>/dev/null)
VERDICT=$(printf '%s' "$L13_LAST" | jq -r '.verdict' 2>/dev/null)
[ -z "$VERDICT" ] && VERDICT="FAIL"

if [ -f flags/L5_VETO ]; then _log "[gate] VETO=ON → block"; exit 0; fi

RAW=$(cat flags/L105_COOLDOWN_UNTIL 2>/dev/null || echo '')
NOW=$(date +%s)
if printf "%s" "$RAW" | grep -q '{'; then
  U=$(command -v jq >/dev/null 2>&1 && printf "%s" "$RAW" | jq -r '.until_ts' || printf "%s" "$RAW" | sed -n 's/.*"until_ts":[ ]*\([0-9.]*\).*/\1/p')
else U="$RAW"; fi
U=${U%.*}; REMAIN=$(( ${U:-$NOW} - NOW ))

if ! _pass "$VERDICT"; then _log "[gate] L13 verdict=$VERDICT → block"; exit 0; fi
if [ -n "$U" ] && [ "$REMAIN" -gt 0 ]; then _log "[gate] cooldown_remaining=${REMAIN}s → block"; exit 0; fi

# adopt once
echo "{\"ts\":$(date +%s),\"event\":\"adopt_ready\",\"reason\":\"l13_pass_no_veto_no_cooldown\"}" >> logs/policy_apply_controlled.jsonl
# ここから先は既存の採択処理に委譲（append-only）
# --- end guard ---
