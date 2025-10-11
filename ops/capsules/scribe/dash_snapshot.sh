#!/usr/bin/env bash
set -euo pipefail
bash scripts/dev/dashboard_lite.sh
d="archives/$(date +%F)"
mkdir -p "$d"
cp docs/runbook/dashboard_lite.md "$d/"
echo "[OK] dashboard snapshot -> $d/dashboard_lite.md"
