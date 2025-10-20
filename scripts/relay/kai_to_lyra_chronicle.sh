#!/usr/bin/env bash
set -euo pipefail

LOG="$HOME/daegis/logs/factory_ops.jsonl"
OUT="$HOME/daegis/logs/chronicle.jsonl"
STATE="$HOME/daegis/state/last_levelup_hash"
NOTIFY="$HOME/daegis/scripts/notify_slack.sh"

mkdir -p "$(dirname "$OUT")" "$(dirname "$STATE")"

# factory_ops から最後の halu_levelup を1件だけ安全に抽出
last=$(awk '/"event":"halu_levelup"/{line=$0} END{if(line) print line}' "$LOG" 2>/dev/null || true)
[ -z "$last" ] && exit 0

# JSON 妥当性チェック
echo "$last" | jq -e . >/dev/null 2>&1 || exit 0

# 重複判定（内容ハッシュで）
hash=$(printf "%s" "$last" | sha1sum | awk '{print $1}')
prev=$(cat "$STATE" 2>/dev/null || true)
[ "$hash" = "$prev" ] && exit 0

# Chronicle に転送（Kai→Lyra）
echo "$last" | jq -c '. + {"relay":"Kai→Lyra"}' >> "$OUT"

# Slack 通知（あれば）
if [ -x "$NOTIFY" ]; then
  lvl=$(echo "$last" | jq -r '.level // "L?"')
  ts=$(echo "$last"  | jq -r '.ts    // ""')
  "$NOTIFY" "🚀 Halu level up to *${lvl}*  (${ts}) — see Chronicle"
fi

# 既読印
echo "$hash" > "$STATE"
