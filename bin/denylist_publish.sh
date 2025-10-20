#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"
DL="$ROOT/config/denylist.txt"
OUT="$ROOT/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/Denylist.md"
mkdir -p "$(dirname "$OUT")"

{
  echo '---'
  echo 'tags: [Daegis_Core_Six, ops]'
  echo "created: $(date -u +%FT%TZ)"
  echo "modified: $(date -u +%FT%TZ)"
  echo 'role: control'
  echo '---'
  echo '# Denylist (effective)'
  echo ''
  if [ -s "$DL" ]; then
    # コメント/空行は飛ばす
    grep -vE '^\s*(#|$)' "$DL" | sed 's/^/- /'
  else
    echo '_(empty)_'
  fi
  echo ''
  echo '```dataview'
  echo 'TABLE WITHOUT ID path'
  echo 'FROM "2_Areas/50_Daegis"'
  echo 'WHERE contains(file.path, "Daegis OS")'
  echo '```'
} > "$OUT"
