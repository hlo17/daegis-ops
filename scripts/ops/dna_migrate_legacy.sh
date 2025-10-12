#!/usr/bin/env bash
set -euo pipefail
in="${1:-ops/ledger/agent_identity.jsonl}"
out="${2:-ops/ledger/agent_dna.jsonl}"
[ -f "$in" ] || { echo "[skip] no legacy ($in)"; exit 0; }
while IFS= read -r line; do
  [ -n "$line" ] || continue
  printf '%s\n' "$line" | jq -c '
    def nowiso: (now | strftime("%Y-%m-%dT%H:%M:%SZ"));
    {
      ts:      (.ts // nowiso),
      agent:   (.agent // .agent_id // "unknown"),
      kind:    "hash_rely",
      value:   (.hash_rely // .sha_root // empty),
      ratified_by: ["imported_legacy"],
      ext:     {"trust_tier":"legacy"}
    }'
done < "$in" >> "$out"
echo "[migrate] wrote -> $out"
