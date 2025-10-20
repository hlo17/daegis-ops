#!/usr/bin/env bash
set -euo pipefail
# .env をそのまま source（export付き）で安全読込
set -a
. /home/f/daegis/relay/.env
set +a
msg="${1:-}"
[ -z "$msg" ] && { echo "usage: slack_webhook_post.sh 'message'"; exit 2; }
curl -sS -X POST -H 'Content-type: application/json' \
  --data "$(jq -rn --arg t "$msg" '{text:$t}')" \
  "$SLACK_WEBHOOK_URL" >/dev/null
