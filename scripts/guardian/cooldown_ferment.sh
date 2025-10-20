#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
ts=$(date -u +%FT%TZ)
src=docs/chronicle/beacon.md
out=docs/chronicle/brief/ferment_${ts}.md
mkdir -p docs/chronicle/brief
{
  echo "# Ferment Note ($ts)"
  echo
  echo "## 50字要約"
  sed -n '1,80p' "$src" | tr -d '\r' | head -n 40 | awk 'NR<=40' | sed 's/^/- /' | head -n 5
  echo
  echo "## 意思決定ツリー（簡易）"
  grep -E '^- ' "$src" | sed 's/^- /- root -> /' | head -n 12
} > "$out"
printf '{"ts":"%s","event":"cooldown_ferment","file":"%s"}\n' "$ts" "$out" >> logs/worm/journal.jsonl
echo "[ferment] wrote $out"
