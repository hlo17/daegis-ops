#!/usr/bin/env bash
set -euo pipefail
IMG="$HOME/daegis/records/kpi.png"
: "${SLACK_BOT_TOKEN:?need SLACK_BOT_TOKEN}"
: "${SLACK_CHANNEL:?need SLACK_CHANNEL (e.g. #daegis-brief or CXXXX)}"
[ -f "$IMG" ] || { echo "no image: $IMG"; exit 1; }
curl -fsS -X POST \
  -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  -F "channels=$SLACK_CHANNEL" \
  -F "title=HALU KPI" \
  -F "initial_comment=HALU KPI snapshot" \
  -F "file=@${IMG}" \
  https://slack.com/api/files.upload >/dev/null
echo "[ok] uploaded to $SLACK_CHANNEL"
