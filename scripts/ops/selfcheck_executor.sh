#!/usr/bin/env bash
set -euo pipefail
bash -n "$HOME/daegis/scripts/ops/halu_exec_sandbox.sh"
jq --version >/dev/null
python3 -c 'import sys; sys.exit(0)'
