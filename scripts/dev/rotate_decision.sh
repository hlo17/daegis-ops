#!/usr/bin/env bash
set -euo pipefail
LEDGER="logs/decision.jsonl"
MAX=$((10*1024*1024)) # 10MB
[ -f "$LEDGER" ] || { echo "[rotate] no ledger"; exit 0; }
SZ=$(stat -c%s "$LEDGER" 2>/dev/null || echo 0)
if [ "$SZ" -ge "$MAX" ]; then
  mkdir -p logs
  cp -f "$LEDGER" "${LEDGER}.1"
  : > "$LEDGER"
  echo "[rotate] rotated to ${LEDGER}.1 (size=$SZ)"
else
  echo "[rotate] ok (size=$SZ < $MAX)"
fi