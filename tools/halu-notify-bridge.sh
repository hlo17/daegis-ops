#!/usr/bin/env bash
set -euo pipefail
H=127.0.0.1; P=1883; U=halu; PW="${PW_HALU:-PUT-STRONG-HALU-PASS}"
IN="daegis/events/halu/answer"; OUT="daegis/notify/halu"
mosquitto_sub -h $H -p $P -u $U -P $PW -t "$IN" -v | while IFS= read -r line; do
  payload="${line#* }"
  # 120字に収めて通知（雑に要約）
  short=$(printf '%s' "$payload" | tr '\n' ' ' | cut -c1-120)
  mosquitto_pub -h $H -p $P -u $U -P $PW -t "$OUT" -m "[halu] $short"
done
