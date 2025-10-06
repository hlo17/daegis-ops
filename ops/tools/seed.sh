#!/bin/sh
set -eu
ROOT="$(cd "$(dirname "$0")/.."; pwd)"
mkdir -p "$ROOT/context"
BOOT="$ROOT/context/BOOTSTRAP.md"
OUT="$ROOT/context/SEED_NOW.md"

# 憲章の雛形（初回のみ）
[ -f "$BOOT" ] || cat > "$BOOT" <<'MD'
# Daegis Bootstrap Charter
- Architecture: Halu (core KB) + Sora (interface)
- Decisions live in `logbook/` (versioned Markdown).
- Sources of truth: Git history + Logbook.
MD

{
  echo "<!-- generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ') -->"
  echo "# Daegis Memory Seed"
  echo
  echo "## Bootstrap Charter"
  echo
  cat "$BOOT"
  echo
  if [ -f "$ROOT/context/HISTORY.md" ]; then
    echo "## Official History"
    echo
    sed -n '1,400p' "$ROOT/context/HISTORY.md"
    echo
  fi
  echo "## Latest Decisions"
  ls -1t "$ROOT"/logbook/*/*/*/*.md 2>/dev/null | head -20 | while IFS= read -r f; do
    echo
    echo "---"
    echo "### $(basename "$f")"
    sed -n '1,200p' "$f"
  done
} > "$OUT"

echo "$OUT"
