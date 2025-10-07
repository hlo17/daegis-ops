#!/usr/bin/env bash
set -euo pipefail
. "$HOME/.config/daegis/oracle.env"

mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
  -t "$ASK_TOPIC/#" -v | while IFS= read -r line; do
  topic="${line%% *}"; payload="${line#* }"
  resp="$(curl -fsS -X POST "$ORCH_URL" -H 'content-type: application/json' \
           -d "$(printf '%s' "$payload" | jq -Rs '{task: .}')" || printf 'ERROR')"
  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "$ANSWER_TOPIC" -m "$resp" || true
  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "$NOTIFY_PREFIX" -m "oracle reply: $(printf '%s' "$resp" | jq -Rs .)" || true
  echo "[oracle-bridge] processed"
done
