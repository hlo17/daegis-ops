#!/usr/bin/env sh
set -eu
OUT="logs/consensus_federated.jsonl"
NODES="${DAEGIS_NODES:-http://127.0.0.1:8080}"
mkdir -p "$(dirname "$OUT")"
for n in $(echo "$NODES" | tr ',' ' '); do
  # capture body + http status in a single call (quiet on errors)
  resp="$(curl -s -w '___HTTP:%{http_code}' "$n/consensus" 2>/dev/null || true)"
  code="${resp##*___HTTP:}"
  body="${resp%___HTTP:*}"
  # empty body -> record a placeholder and continue
  if [ -z "$body" ]; then
    echo "{\"node\":\"$n\",\"status\":${code:-0},\"raw\":\"(empty)\"}" >> "$OUT"
    continue
  fi

  # try to parse expected JSON snapshot; on failure record status + truncated raw body
  if echo "$body" | jq -cr '. as $c | .snapshot[]? | {"node":$c.node_id,"intent":.intent,"support":.support,"objection":.objection,"score":.score,"ts":$c.ts}' >> "$OUT" 2>/dev/null; then
    :
  else
    # fallback: keep status + first 240 chars of raw for debugging
    tr -d '\n' <<EOF | cut -c1-240 | sed 's/"/\\"/g' > /tmp/cf_raw.$$
$body
EOF
    RAW_SHORT="$(cat /tmp/cf_raw.$$ | tr -d '\n')"
    rm -f /tmp/cf_raw.$$
    echo "{\"node\":\"$n\",\"status\":${code:-0},\"raw\":\"${RAW_SHORT}\"}" >> "$OUT"
  fi
done
echo "[consensus federate] appended → $OUT"
exit 0

# patched at 2025-10-09T21:04:57Z
