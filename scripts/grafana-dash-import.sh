#!/usr/bin/env bash
set -euo pipefail
GF_USER="${GF_USER:-admin}"
GF_PASS="${GF_PASS:-admin123}"
FOLDER_UID="${FOLDER_UID:-daegis}"

for f in "$@"; do
  echo "[import] $f"
  jq -c --arg folder "$FOLDER_UID" '{dashboard: ., overwrite:true, folderUid:$folder}' "$f" \
  | curl -s -u "$GF_USER:$GF_PASS" -H 'Content-Type: application/json' \
      -X POST http://127.0.0.1:3000/api/dashboards/db \
      -d @- | jq .
done
