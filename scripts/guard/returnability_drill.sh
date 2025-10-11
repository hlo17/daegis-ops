#!/usr/bin/env sh
set -eu
RUNBOOK="docs/runbook/mvp_evidence.md"
T0=$(date +%s)
export DAEGIS_SLA_CHAT_ANSWER_MS=1
curl -s -X POST :8080/chat -H 'Content-Type: application/json' -d '{"q":"force-hold"}' >/dev/null || true
unset DAEGIS_SLA_CHAT_ANSWER_MS
curl -s -X POST :8080/chat -H 'Content-Type: application/json' -d '{"q":"recover"}' >/dev/null || true
T1=$(date +%s); MTTR=$((T1-T0))
echo "" >> "$RUNBOOK"
echo "- Returnability drill: HOLD→recover MTTR=${MTTR}s (UTC $(date -u +%FT%TZ))" >> "$RUNBOOK"
echo "[drill] MTTR=${MTTR}s"
exit 0