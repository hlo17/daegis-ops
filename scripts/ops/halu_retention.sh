#!/usr/bin/env bash
set -euo pipefail
find "$HOME/daegis/archives" -maxdepth 1 -type d -regex '.*/[0-9]{8}$' \
  | sort | head -n -7 | xargs -r rm -rf
