#!/usr/bin/env bash
set -Eeuo pipefail
source ops/factory/_lib.sh

JOB_FILE="${1:?job json required}"
[[ ! -f "$JOB_FILE" ]] && { echo "NO_JOB"; exit 2; }

JOB_ID="$(jq -r '.job_id // "unknown"' "$JOB_FILE")"
ROLE="$(jq -r '.role // "scribe"' "$JOB_FILE")"
DRY="$(jq -r '.dry_run // false' "$JOB_FILE")"

echo "Starting job $JOB_ID, role=$ROLE, dry=$DRY"
journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" event="job_start")"

# Get command count
cmd_count=$(jq -r '.commands | length' "$JOB_FILE")
echo "Processing $cmd_count commands"

rc_total=0
for ((i=0; i<cmd_count; i++)); do
  step=$((i+1))
  cmd_str=$(jq -r ".commands[$i] | join(\" \")" "$JOB_FILE")
  echo "Step $step: $cmd_str"
  
  # Simple RBAC check - for demo, only allow bash and echo  
  if [[ "$cmd_str" == bash* ]] || [[ "$cmd_str" == echo* ]]; then
    echo "  ALLOWED"
  else
    echo "  DENIED"
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="deny" cmd="$cmd_str")"
    rc_total=126
    continue
  fi
  
  if [[ "$DRY" == "true" ]]; then
    echo "  DRY RUN OK"
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="dry_ok" cmd="$cmd_str")"
  else
    echo "  WOULD EXECUTE: $cmd_str"
    journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" step="$step" event="ok" cmd="$cmd_str")"
  fi
done

journal_append "$(json_line ts="$(now_ts)" id="$JOB_ID" event="job_end" rc="$rc_total")"
echo "Job completed with rc=$rc_total"
exit "$rc_total"
