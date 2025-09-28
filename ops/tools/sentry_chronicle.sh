#!/usr/bin/env bash
set -euo pipefail
MSG="${*:-(no message)}"
TS="$(date +"%Y-%m-%dT%H:%M:%S%z")"
echo "[SENTRY] ${TS} ${MSG}"
# 関数ではなく実体スクリプトを直呼び
CHRONICLE_TOOL="${HOME}/daegis/ops/tools/append_chronicle.sh"
bash "$CHRONICLE_TOOL" "Sentry" <<EOF2
${MSG}
EOF2
