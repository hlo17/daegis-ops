#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"
PROP="$ROOT/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/Denylist_Proposals.md"
DL="$ROOT/config/denylist.txt"
TMP="$(mktemp)"

[ ! -f "$PROP" ] && { echo "Proposals not found: $PROP" >&2; exit 1; }
mkdir -p "$(dirname "$DL")"
touch "$DL"

# チェック済みだけ抽出
grep -E '^- \[x\] ' "$PROP" | sed -E 's/^- \[x\] ([^ ]+) .*/\1/' > "$TMP"

# 既存と突合して新規だけ追記
while IFS= read -r p; do
  grep -qxF "$p" "$DL" || echo "$p" >> "$DL"
done < "$TMP"

echo "[denylist_apply] updated $DL"
rm -f "$TMP"
