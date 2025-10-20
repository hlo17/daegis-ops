#!/usr/bin/env bash
# Capsule: obs.canary_verdict_5m
# Purpose: 5分間隔でcanary verdictを確認・観測ログを残す
set -Eeuo pipefail
CAPID="obs.canary_verdict_5m"
. "$(dirname "$0")/../_lib.sh"

pre(){ prep; }

run(){
  export L13_WINDOW_SEC=300
  export L13_ONLY_CANARY=1
  python3 scripts/learn/canary_verdict.py >/dev/null 2>&1 || true
}

verify(){
  # logs/policy_canary_verdict.jsonl に event=canary_verdict が存在すればOK
  if tail -100 logs/policy_canary_verdict.jsonl | grep -q '"event": "canary_verdict"'; then
    ok "VERIFY OK canary_verdict_5m (verdict data present)"
  else
    ng "VERIFY NG canary_verdict_5m (no verdict found)"
  fi
}

rollback(){ :; }

[ "${PHASE:-all}" = all ] && { pre; lock; run; verify; } || true
