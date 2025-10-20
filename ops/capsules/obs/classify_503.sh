#!/usr/bin/env bash
set -Eeuo pipefail; CAPID="obs.classify_503"
. "$(dirname "$0")/../_lib.sh"
pre(){ prep; }
run(){ python3 scripts/learn/decision_enrich.py >/dev/null 2>&1 || true; }
verify(){ tail -1 logs/decision_enriched.jsonl 2>/dev/null | jq -e ".status,.route" >/dev/null 2>&1 && ok "VERIFY OK classify_503" || ng "VERIFY NG classify_503"; }
rollback(){ :; }
[ "${PHASE:-all}" = all ] && { pre; lock; run; verify; } || true

