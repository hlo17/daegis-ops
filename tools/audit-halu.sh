#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/daegis/ops/ward/audit-halu-$(date +%Y%m%d-%H%M%S).md"
{
  echo "# Halu Audit ($(date -Iseconds))"
  echo
  echo "## tree"
  find "$HOME/halu" -maxdepth 2 -print | sed -n '1,120p'
  echo
  echo "## backups (latest)"
  ls -lh "$HOME/daegis/ark/backups"/halulog.*.tgz 2>/dev/null | tail -3
} > "$OUT"
[ -f "$HOME/daegis/ops/ward/Daegis-Ward.md" ] && { echo; echo "- see: $(basename "$OUT")"; } >> "$HOME/daegis/ops/ward/Daegis-Ward.md"
[ "$(uname)" = "Darwin" ] && open -R "$OUT" || true
echo "[wrote] $OUT"
