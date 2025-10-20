#!/usr/bin/env bash
set -Eeuo pipefail; CAPID="dash.snapshot"
. "$(dirname "$0")/../_lib.sh"
pre(){ prep; }
run(){
  bash scripts/dev/dashboard_lite.sh >/dev/null 2>&1 || true
  D="archives/$(date +%F)"; mkdir -p "$D"
  cp -f docs/runbook/dashboard_lite.md "$D/" 2>/dev/null || true
}
verify(){ tail -20 docs/runbook/dashboard_lite.md 2>/dev/null | grep -q "Auto-adopt gate" && ok "VERIFY OK dash.snapshot" || ng "VERIFY NG dash.snapshot"; }
rollback(){ :; }
[ "${PHASE:-all}" = all ] && { pre; lock; run; verify; } || true

