#!/usr/bin/env bash
set -euo pipefail
ID=$(date +%Y%m%d_%H%M%S)-$RANDOM
FILE="$HOME/daegis/queue/inbox/$ID.json"
mkdir -p "$HOME/daegis/queue/inbox" "$HOME/daegis/logs"

# 引数があればそのまま、無ければ jq で妥当なJSONを生成
if [ $# -gt 0 ]; then
  payload="$1"
else
  payload=$(jq -cn --arg task viz '{task:$task, args:[]}')
fi

# JSON妥当性を検査してから保存
echo "$payload" | jq -c . > "$FILE"

printf '{"ts":"%s","event":"enqueue","id":"%s"}\n' "$(date -u +%FT%TZ)" "$ID" \
 | flock -x "$HOME/daegis/logs/queue.log.lock" tee -a "$HOME/daegis/logs/queue.log" >/dev/null

echo "$ID"
