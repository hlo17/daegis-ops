#!/usr/bin/env bash
set -Eeuo pipefail; CAPID="asset.snapshot_daily"
. "$(dirname "$0")/../_lib.sh"
pre(){ prep; }
run(){
  D="archives/$(date +%F)"; mkdir -p "$D"
  ( tar -czf "$D/logs.tgz" -C . logs >/dev/null 2>&1 ) || true
}
verify(){ [ -f "archives/$(date +%F)/logs.tgz" ] && ok "VERIFY OK snapshot_daily" || ng "VERIFY NG snapshot_daily"; }
rollback(){ :; }
[ "${PHASE:-all}" = all ] && { pre; lock; run; verify; } || true

