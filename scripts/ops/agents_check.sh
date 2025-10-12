#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
missing=0
for f in docs/agents/*.md; do
  for h in "Mission" "Exec Plan" "Tests"; do
    grep -q "^## $h" "$f" || { echo "NG: $f missing [$h]"; missing=1; }
  done
done
ts=$(date -u +%FT%TZ); mkdir -p logs/worm
echo "{\"ts\":\"$ts\",\"event\":\"agents_check\",\"missing\":$missing}" >> logs/worm/journal.jsonl
[ $missing -eq 0 ] && echo "OK: agents spec looks complete." || exit 1
