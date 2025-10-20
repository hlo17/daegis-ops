#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"; ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT="$ROOT/inbox/window/reflect_digest_${ISO}.md"
SUM=$(awk '/^daegis_halu_reflection_summary_total_1h/{print $2+0}' \
      "$ROOT/logs/prom/halu_reflection_summary.prom" 2>/dev/null || echo 0)
TOP=$(tac "$ROOT/docs/ledger/halu.jsonl" | jq -rc 'select(.act=="reflect.summarize")|.top_intents|join("/")' | head -n1)
mkdir -p "$(dirname "$OUT")"
printf "# Reflect Digest (%s UTC)\n\n- total: %s\n- top: %s\n" "$ISO" "$SUM" "${TOP:-n/a}" > "$OUT"
echo "{\"t\":\"$ISO\",\"act\":\"intent.deliver.dry\",\"id\":\"reflect_digest_hourly\",\"path\":\"${OUT}\"}" >> "$ROOT/docs/ledger/halu.jsonl"
echo "{\"ts\":$(date +%s),\"agent\":\"halu\",\"event\":\"intent.deliver.dry\",\"path\":\"${OUT}\"}" >> "$ROOT/logs/halu/bus.jsonl"
echo "[OK] deliver.dry -> $OUT"
