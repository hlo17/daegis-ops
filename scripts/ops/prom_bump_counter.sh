#!/usr/bin/env bash
set -euo pipefail
METRIC="${1:?metric name}"; FILE="${2:?prom file}"
DIR="$(dirname "$FILE")"; TMP="$FILE.tmp.$$"
mkdir -p "$DIR"
OLD=0
if [ -f "$FILE" ]; then
  OLD="$(awk -v m="$METRIC" '$1==m{v=$2} END{print (v+0)}' "$FILE" 2>/dev/null || echo 0)"
fi
NEW=$((OLD+1))
{
  echo "# HELP $METRIC counter"
  echo "# TYPE $METRIC counter"
  echo "$METRIC $NEW"
} > "$TMP"
mv -f "$TMP" "$FILE"
echo "$NEW"
