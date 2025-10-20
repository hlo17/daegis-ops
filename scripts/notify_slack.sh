#!/usr/bin/env bash
set -euo pipefail
WEBHOOK_URL="$HOME/daegis/state/slack_webhook_url"
MSG="${1:-}"

if [ ! -s "$WEBHOOK_URL" ]; then
  echo "❌ Slack webhook URLが未設定: echo <URL> > $WEBHOOK_URL" >&2
  exit 1
fi

URL=$(cat "$WEBHOOK_URL")
payload=$(jq -nc --arg text "$MSG" '{"text":$text}')

curl -s -X POST -H 'Content-type: application/json' \
     --data "$payload" "$URL" >/dev/null 2>&1 || true
