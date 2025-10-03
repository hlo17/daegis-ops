#!/usr/bin/env bash
set -euo pipefail
VAULT_BASE="$(ls -d "$HOME/Library/Mobile Documents"/iCloud*obsidian*/Documents/Daisy 2>/dev/null | head -n1)"
CHRON_DIR="$VAULT_BASE/2_Areas/50_Daegis/Daegis Chronicle"
TODAY="$(date +%F)"
SRC="$CHRON_DIR/Daegis Chronicle ${TODAY}.md"

REPO="$HOME/daegis"
DST_DIR="$REPO/ops/runbooks/chronicles"
DST="$DST_DIR/Daegis Chronicle ${TODAY}.md"

[ -f "$SRC" ] || { echo "Chronicle not found: $SRC" >&2; exit 1; }
mkdir -p "$DST_DIR"
cp -f "$SRC" "$DST"
sed -i '' $'s/\r$//' "$DST" 2>/dev/null || true
LC_ALL=C perl -0777 -pe 's/\x{200B}|\x{FEFF}//g' -i "$DST" 2>/dev/null || true
cd "$REPO"
git add "$DST"
git commit -m "Chronicle: mirror ${TODAY}"
git push
echo "Mirrored: $DST"
