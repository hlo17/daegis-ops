#!/usr/bin/env bash
set -euo pipefail
OBSID="$HOME/Obsidian/2_Areas/50_Daegis/Daegis Hand-off"
REPO="$HOME/daegis"
TODAY="$(date +%F)"
SRC="$OBSID/Daegis Hand-off ${TODAY}.md"
DST_DIR="$REPO/ops/runbooks/hand-offs"
DST="$DST_DIR/Daegis Hand-off ${TODAY}.md"

[ -f "$SRC" ] || { echo "Hand-off not found: $SRC" >&2; exit 1; }
mkdir -p "$DST_DIR"
cp -f "$SRC" "$DST"
sed -i '' $'s/\r$//' "$DST" 2>/dev/null || true
LC_ALL=C perl -0777 -pe 's/\x{200B}|\x{FEFF}//g' -i "$DST" 2>/dev/null || true
cd "$REPO"
git add "$DST"
git commit -m "Hand-off: mirror ${TODAY}"
git push
echo "Mirrored: $DST"
