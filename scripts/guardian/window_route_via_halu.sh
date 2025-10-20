#!/usr/bin/env bash
set -euo pipefail
CARD="${1:-}"
test -f "$CARD" || { echo "[ERR] card file required"; exit 2; }

ROOT="${HOME}/daegis"
BUS="${ROOT}/logs/halu/bus.jsonl"
mkdir -p "$(dirname "$BUS")"

# A) まずHaluのbusに「通過」を1行記録（WORM）
jq -n --arg ts "$(date -u +%FT%TZ)" --arg event "bus.card_routed" \
      --arg card "$(basename "$CARD")" \
      '{ts:$ts,agent:"halu",event:$event,card:$card}' >> "$BUS"

# B) その上で通常の送信（実際の宛先へ）
bash "${ROOT}/scripts/guardian/window_send.sh" "$CARD"
