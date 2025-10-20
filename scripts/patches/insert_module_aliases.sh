#!/usr/bin/env bash
set -euo pipefail
FILE="router/app.py"
[ -f "$FILE" ] || { echo "file $FILE not found; run from repo root"; exit 1; }
TS=$(date -u +%FT%H%M%SZ)
cp -v "$FILE" "${FILE}.bak_${TS}"
perl -0777 -pe '
  $s = $_;
  unless ($s =~ /_json\s*=/ || $s =~ /_json\s*=/) {
    $s =~ s{(\n(\s*)if path == "/chat" and request.method == "POST":\n)}
           {$1$2    # Guard: ensure module aliases exist in function locals to avoid UnboundLocalError\n$2    try:\n$2        _os\n$2    except NameError:\n$2        import os as _os\n$2    try:\n$2        _json\n$2    except NameError:\n$2        import json as _json\n$2    try:\n$2        _time\n$2    except NameError:\n$2        import time as _time\n$2\n}g;
  $_ = $s;
' -i "$FILE"
sed -n '676,708p' "$FILE" || true
echo
echo "---- git diff (router/app.py) ----"
git --no-pager diff -- "$FILE" | sed -n '1,240p' || true
