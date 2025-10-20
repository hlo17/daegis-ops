#!/usr/bin/env sh
# thin wrapper to the learn runner (append-only)
set -eu
ROOT="${ROOT:-$(pwd)}"
AUTO_TUNE_ALLOW_INTENTS="${AUTO_TUNE_ALLOW_INTENTS:-}" 
bash "${ROOT}/scripts/learn/auto_adopt_when_ready.sh"
exit 0