\
#!/usr/bin/env bash
set -euo pipefail
# 使い方: bash tools/show-bytes.sh <file>
hexdump -C "$1" | sed -n '1,80p'
