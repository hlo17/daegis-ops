#!/usr/bin/env bash
set -euo pipefail
. "$HOME/.config/daegis/relay.env" 2>/dev/null || true

: "${MQTT_HOST:=127.0.0.1}"
: "${MQTT_PORT:=1883}"
: "${MQTT_USER:=f}"
: "${MQTT_PASS:=nknm}"
: "${MQTT_PREFIX:=daegis/notify/}"
: "${MAX_CHARS:=400}"
: "${MAX_LINES:=12}"

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "[mqtt2slack] no SLACK_WEBHOOK_URL; DRYRUN=1"
  DRYRUN=1
else
  DRYRUN=0
fi

echo "[mqtt2slack] start h=$MQTT_HOST:$MQTT_PORT prefix=$MQTT_PREFIX dry=$DRYRUN"

# topic<tab>payload(生) で受ける
mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
  -t "${MQTT_PREFIX}#" -F '%t\t%p' \
| while IFS=$'\t' read -r topic payload; do
    short="${topic#"$MQTT_PREFIX"}"

    # ホワイトリスト（ノイズ抑制）
    case "$short" in
      cli|halu|oracle|scribe|alerts|manual) ;;
      *) continue ;;
    esac

    # 連投デデュープ（同一内容を5秒以内は捨てる）
    key="$topic"$'\t'"$payload"
    now="$(date +%s)"
    if [ "${LAST_KEY:-}" = "$key" ] && [ $((now - ${LAST_TS:-0})) -lt 5 ]; then
      continue
    fi
    LAST_KEY="$key"; LAST_TS="$now"

    # 行数・長さの安全丸め
    payload_trimmed="$(printf '%s\n' "$payload" | head -n "$MAX_LINES")"
    bytes=$(printf %s "$payload_trimmed" | wc -c)
    if [ "$bytes" -gt "$MAX_CHARS" ]; then
      payload_trimmed="$(printf %s "$payload_trimmed" | head -c "$MAX_CHARS")…"
    fi

    # Slack 1投稿（改行保持のためコードブロック）
    msg="[$short]
\`\`\`
$payload_trimmed
\`\`\`"

    if [ "$DRYRUN" = "1" ]; then
      echo "[dry] $short"
      continue
    fi

    json="$(printf '%s' "$msg" | jq -Rs '{text: .}')"
    if curl -fsS -X POST "$SLACK_WEBHOOK_URL" \
          -H 'content-type: application/json' -d "$json" >/dev/null; then
      echo "[posted] $short"
    else
      echo "[post-fail] $short"
    fi
  done
