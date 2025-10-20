#!/usr/bin/env sh
set -eu
# Read-only push of decision ledger to an audit node
DEST="${DEST:-pi5:/var/daegis/logs}"   # e.g. user@host:/path
SRC="logs/decision.jsonl"
if [ ! -f "$SRC" ]; then echo "[audit] missing $SRC"; exit 0; fi
rsync -av --mkpath --inplace "$SRC" "$DEST"/ || true
ssh "${DEST%%:*}" "sha256sum ${DEST#*:}/decision.jsonl" 2>/dev/null || true
echo "[audit] federate done → $DEST"
exit 0