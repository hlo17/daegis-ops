#!/usr/bin/env sh
set -eu
OUT="logs/consensus_federated.jsonl"
NODES="${DAEGIS_NODES:-http://127.0.0.1:8080}"
mkdir -p logs
for n in $(echo "$NODES" | tr ',' ' '); do
  body="$(curl -s "$n/consensus" 2>/dev/null || true)"
  [ -z "$body" ] && continue
  echo "$body" | jq -cr '. as $c | .snapshot[]? | {"node":$c.node_id,"intent":.intent,"support":.support,"objection":.objection,"score":.score,"ts":$c.ts}' 2>/dev/null \
    >> "$OUT" || echo "{\"node\":\"$n\",\"raw\":\"$(printf %s "$body" | tr -d '\n' | cut -c1-120)\"}" >> "$OUT"
done
echo "[consensus federate] appended → $OUT"
exit 0