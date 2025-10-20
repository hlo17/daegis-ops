#!/usr/bin/env bash
set -Eeuo pipefail; CAPID="asset.dlp_scan_repo"
. "$(dirname "$0")/../_lib.sh"
pre(){ prep; }
run(){
  grep -RInE --exclude-dir .git --exclude-dir .venv \
    "(sk-[A-Za-z0-9]{20,}|Bearer[ ]+[A-Za-z0-9._-]{10,}|-----BEGIN (RSA|EC) PRIVATE KEY-----)" . 2>/dev/null \
    | sed "s/\"/\\\"/g" \
    | awk -v ts="$(date +%s)" '{print "{\"ts\":"ts",\"event\":\"dlp_hit\",\"path\":\""$0"\"}"}' \
    >> logs/dlp_scan.jsonl || true
}
verify(){ tail -1 logs/dlp_scan.jsonl 2>/dev/null >/dev/null && ok "VERIFY OK dlp_scan_repo" || ng "VERIFY NG dlp_scan_repo"; }
rollback(){ :; }
[ "${PHASE:-all}" = all ] && { pre; lock; run; verify; } || true

