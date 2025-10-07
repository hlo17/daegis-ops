#!/usr/bin/env bash
set -euo pipefail
. "$HOME/.config/daegis/halu.env"

sub() { mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$ASK_TOPIC/#" -F '%p'; }
pub() { mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" -t "$1" -m "$2"; }

handle() {
  local prompt="$1"
  # --- 外部AI呼び出し（OpenAI Chat Completions の例）---
  local req; req=$(jq -cn --arg m "${OPENAI_MODEL}" --arg p "$prompt" \
    '{model:$m,messages:[{role:"user",content:$p}],max_tokens:400}')
  local resp; resp=$(
    curl -fsS https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$req" | jq -r '.choices[0].message.content // "N/A"'
  )
  # 返却
  pub "$ANSWER_TOPIC" "$resp" || true
  pub "$NOTIFY_TOPIC" "[halu] $(echo "$resp" | tr '\n' ' ' | cut -c1-160)" || true
}

# メインループ
sub | while IFS= read -r payload; do
  # payload は平文 or JSON どちらでもOK（JSONなら .prompt を優先）
  prompt=$(jq -r '.prompt // empty' <<<"$payload" 2>/dev/null || true)
  [ -z "${prompt:-}" ] && prompt="$payload"
  handle "$prompt" || pub "$NOTIFY_TOPIC" "[halu] error"
done
