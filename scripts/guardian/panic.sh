#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
echo "[panic] making immediate WORM snapshot + beacon + commit"
bash "$ROOT/scripts/dev/dashboard_lite.sh" || true
bash "$ROOT/scripts/guardian/beacon.sh" || true
git add docs/chronicle/beacon.* docs/runbook/dashboard_lite.md flags/* 2>/dev/null || true
PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m "panic: emergency snapshot" || true
git push || true
echo "[panic] done"
