#!/usr/bin/env sh
set -eu
# Write alert to local log and optionally Slack webhook
MSG="${1:-(no message)}"
TS="$(date -u +%FT%TZ)"
mkdir -p logs
echo "[$TS] $MSG" >> logs/alerts.log
if [ -n "${ALERT_SLACK_WEBHOOK:-}" ]; then
  # JSON-escape and POST to Slack Incoming Webhook
  printf '{"text":%s}\n' "$(printf '%s' "$MSG" | python -c 'import json,sys;print(json.dumps(sys.stdin.read()))')" \
    | curl -sS -X POST -H 'Content-Type: application/json' --data-binary @- "$ALERT_SLACK_WEBHOOK" >/dev/null || true
fi
echo "[alert] $MSG"
exit 0