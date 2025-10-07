#!/usr/bin/env bash
set -euo pipefail
ROOT="${HOME}/daegis"
TS="$(date +%F)"
OUT="${ROOT}/snapshots/releases/${TS}"
mkdir -p "${OUT}"

# 正本6文書だけを安全コピー（存在チェック付き）
for f in \
  "Daegis Hand-off.md" \
  "Daegis Guidelines.md" \
  "Daegis Map.md" \
  "Daegis Ledger.md" \
  "Daegis Chronicle.md" \
  "brief.md"
do
  src="${ROOT}/docs/${f}"
  if [ -f "${src}" ]; then
    cp -a "${src}" "${OUT}/"
  fi
done
echo "snapshot -> ${OUT}"
