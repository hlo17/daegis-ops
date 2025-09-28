#!/usr/bin/env bash
set -euo pipefail
FILE="$1"; shift || true
TS="$(date +"%Y-%m-%dT%H:%M:%S%z")"
REPO_ROOT="${HOME}/daegis"
DEST="${REPO_ROOT}/${FILE}"
mkdir -p "$(dirname "$DEST")"
{
  echo
  echo '---'
  echo "_appended: ${TS}_"
  cat
  echo
} >> "$DEST"
echo "[append_md] appended to ${FILE} at ${TS}"
