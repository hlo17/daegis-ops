#!/usr/bin/env bash
set -euo pipefail
ID="${1:?usage: advice_start <id>}"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
systemctl --user start "halu-exec@$ID.service"
