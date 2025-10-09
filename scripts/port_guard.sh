#!/usr/bin/env bash
set -euo pipefail
BAD=$(ss -lntp 2>/dev/null | awk '$4 ~ /:(8080|9091)$/ {print $4" -> "$6}')
if [ -n "${BAD:-}" ]; then
  echo "[PORT GUARD] Port busy:"; echo "$BAD"; exit 1
fi
echo "[PORT GUARD] OK: 8080/9091 are free."