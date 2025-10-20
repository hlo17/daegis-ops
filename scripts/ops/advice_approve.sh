#!/usr/bin/env bash
set -euo pipefail
ID="${1:?usage: advice_approve <id>}"
mv -f "$HOME/daegis/queue/inbox/$ID.json" "$HOME/daegis/queue/approved/$ID.json"
"$HOME/daegis/relay/tools/slack_webhook_post.sh" "✅ Approved: $ID"
echo "$ID"
