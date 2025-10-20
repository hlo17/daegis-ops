#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"
BRIEF="$ROOT/bridges/obsidian/mirror/docs_chronicle/brief"
OUT="$ROOT/bridges/obsidian/mirror/docs_chronicle/summary.md"
TZ=:UTC
today=$(date -u +%F)

echo "## Daily Brief — ${today}Z" >> "$OUT"
echo "" >> "$OUT"
# その日の ferment_* を収集
found=0
while IFS= read -r -d '' f; do
  ttl=$(grep -m1 '^# ' "$f" | sed 's/^# //')
  echo "- ${ttl}  ($(basename "$f"))" >> "$OUT"
  found=1
done < <(find "$BRIEF" -type f -name "ferment_${today}T*.md" -print0 | sort -z)
[ $found -eq 1 ] && echo "" >> "$OUT" || echo "_(no entries)_\n" >> "$OUT"
