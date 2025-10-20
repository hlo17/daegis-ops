#!/usr/bin/env bash
set -euo pipefail
LEDGER="logs/decision.jsonl"
COUNT="${1:-10}"
[ -f "$LEDGER" ] || { echo "[episodes] no ledger ($LEDGER)"; exit 0; }
TAIL="$(tail -n "$COUNT" "$LEDGER")"
if command -v jq >/dev/null 2>&1; then
  echo "$TAIL" | jq -r '. | "\(.episode_id)  \(.corr_id)  @\(.decision_time)"'
else
  # very simple jsonl parser (episode_id, corr_id, decision_time)
  echo "$TAIL" | awk -F'"' '
    { eid=""; cid=""; d=""; 
      for(i=1;i<=NF;i++){ if($i=="episode_id"){eid=$(i+2)}; if($i=="corr_id"){cid=$(i+2)} }
    }
    { match($0,/\"decision_time\"\s*:\s*([0-9\.]+)/,m); if(m[1]!=""){d=m[1]} }
    { printf "%s  %s  @%s\n", eid, cid, d }'
fi