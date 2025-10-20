#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
ts=$(date -u +%FT%TZ)
yq -i ".last_manifest = \"$ts\"" docs/chronicle/spirit.yml 2>/dev/null || \
  sed -i "s/^last_manifest:.*/last_manifest: $ts/" docs/chronicle/spirit.yml
printf '{"ts":"%s","event":"spirit_manifest","name":"Roundtable"}\n' "$ts" >> logs/worm/journal.jsonl
echo "[spirit] manifest at $ts"
