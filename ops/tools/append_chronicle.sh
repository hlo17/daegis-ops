#!/usr/bin/env bash
# Usage:
#   append_chronicle.sh "短い見出し" <<'EOF'
#   本文（箇条書きなど自由）
#   EOF
set -euo pipefail
TITLE="${1:-Log}"
shift || true
TS_DATE="$(date +%Y-%m-%d)"
TS_ISO="$(date +"%Y-%m-%dT%H:%M:%S%z")"
FILE="${HOME}/daegis/Daegis Chronicle.md"
mkdir -p "$(dirname "$FILE")"
{
  echo
  echo "## ${TS_DATE} ${TITLE}"
  echo "_appended: ${TS_ISO}_"
  echo
  cat
  echo
} >> "$FILE"
echo "[append_chronicle] appended '${TITLE}' at ${TS_ISO}"
