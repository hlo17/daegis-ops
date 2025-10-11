#!/usr/bin/env bash
set -euo pipefail
OUT="docs/chronicle/cron_snapshot.txt"
crontab -l | sed -n '1,200p' > "$OUT" || echo "(no crontab)" > "$OUT"
echo "[OK] cron snapshot -> $OUT"
