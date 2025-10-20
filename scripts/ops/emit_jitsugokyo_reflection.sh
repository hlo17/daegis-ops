#!/usr/bin/env bash
set -euo pipefail

PICK_JSON=$("$HOME/daegis/scripts/ops/jitsugokyo_pick.py")

T=$(echo "$PICK_JSON" | jq -r '.t')
ID=$(echo "$PICK_JSON" | jq -r '.pick.id')
VIRT=$(echo "$PICK_JSON" | jq -r '.pick.virtue')
JP=$(echo "$PICK_JSON" | jq -r '.pick.jp')
EN=$(echo "$PICK_JSON" | jq -r '.pick.en')
RULE=$(echo "$PICK_JSON" | jq -r '.pick.rule')

# 1) reflection.jsonl（自己参照語 + 実語教の句）
REF="$HOME/daegis/logs/reflection.jsonl"
mkdir -p "$(dirname "$REF")"
MSG="昨日の私のふるまいを振り返り、『$JP』（$EN）を当てはめて修正点を1つ記す。実行規則：$RULE。"
echo "{\"ts\":\"$T\",\"type\":\"reflection\",\"virtue\":\"$VIRT\",\"canon\":\"Jitsugokyo:$ID\",\"message\":\"$MSG\"}" >> "$REF"

# 2) Prom（徳カウンタ＋鮮度）
PROM="$HOME/daegis/logs/metrics/ethics.prom"
TS=$(date +%s)
{
  echo "# HELP daegis_ethics_event_total count by virtue"
  echo "# TYPE daegis_ethics_event_total counter"
  echo "daegis_ethics_event_total{virtue=\"$VIRT\"} 1"
  echo "# HELP daegis_ethics_textfile_timestamp_seconds last emit time"
  echo "# TYPE daegis_ethics_textfile_timestamp_seconds gauge"
  echo "daegis_ethics_textfile_timestamp_seconds $TS"
} > "$PROM"

echo "[emit] ${VIRT} / $ID — appended reflection & metrics."
