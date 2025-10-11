#!/usr/bin/env sh
# Evidence Snapshot (Phase V V0.2 / VI.1 / VII V0.4)
# - Safe: no crash, no new deps, append-only usage
# - Exit 0 even on partial failures
set +e

TS="$(date -u +%FT%TZ)"
INTENTS="${DAEGIS_INTENTS:-chat_answer,other}"
NODES="${DAEGIS_NODES:-http://127.0.0.1:8080}"

# --- A) /chat → headers (first 20)
HDRS="$(curl -si -X POST :8080/chat -H 'Content-Type: application/json' -d '{"q":"evidence-snapshot"}' 2>/dev/null | sed -n '1,20p')"

# --- B) decision.jsonl tail (mini JSON)
LEDGER_MINI=""
if [ -f logs/decision.jsonl ]; then
  if command -v jq >/dev/null 2>&1; then
    LEDGER_MINI="$(tail -1 logs/decision.jsonl | jq -c '{intent:.intent_hint, ethics:.ethics, provider:.provider, consensus_guard:.consensus_guard, tuning:.tuning}')"
  else
    LEDGER_MINI="$(tail -1 logs/decision.jsonl 2>/dev/null)"
  fi
fi

# --- C) /metrics (state + daegis_* excerpt)
METRIC_LINE="$(curl -s :8080/metrics 2>/dev/null | head -2)"
METRICS_EXCERPT="$(curl -s :8080/metrics 2>/dev/null | grep -E '^daegis_(compass|consensus|sla_suggested_ms)_' | head)"

# --- D) /hash JSON
HASH_JSON="$(curl -s :8080/hash 2>/dev/null)"
[ -z "$HASH_JSON" ] && HASH_JSON="{}"

# --- E) Hash-Relay SUMMARY (tail -1)
HR_SUMMARY=""
if [ -f scripts/dev/hash_relay.sh ]; then
  HR_SUMMARY="$(bash scripts/dev/hash_relay.sh 2>/dev/null | tail -1)"
fi

# --- F) Review Gate tail
GATE_TAIL="$(bash scripts/dev/review_gate.sh 2>/dev/null | tail -5)"

# --- G) Append to Runbook
mkdir -p docs/runbook
{
  echo "## Evidence Snapshot — ${TS}"
  echo ""
  echo "**INTENTS:** \`${INTENTS}\`  |  **NODES:** \`${NODES}\`"
  echo ""
  echo "### A) /chat → headers (first 20 lines)"
  echo '```txt'
  [ -n "$HDRS" ] && echo "$HDRS" || echo "(no headers)"
  echo '```'
  echo ""
  echo "### B) decision.jsonl tail (mini)"
  echo '```json'
  [ -n "$LEDGER_MINI" ] && echo "$LEDGER_MINI" || echo "{}"
  echo '```'
  echo ""
  echo "### C) /metrics state + excerpt"
  echo '```txt'
  [ -n "$METRIC_LINE" ] && echo "$METRIC_LINE" || echo "(no response)"
  [ -n "$METRICS_EXCERPT" ] && echo "$METRICS_EXCERPT"
  echo '```'
  echo ""
  echo "### D) /hash"
  echo '```json'
  echo "$HASH_JSON"
  echo '```'
  echo ""
  echo "### E) Hash-Relay SUMMARY"
  echo '```txt'
  [ -n "$HR_SUMMARY" ] && echo "$HR_SUMMARY" || echo "(hash_relay.sh missing or no output)"
  echo '```'
  echo ""
  echo "### F) Review Gate tail"
  echo '```txt'
  [ -n "$GATE_TAIL" ] && echo "$GATE_TAIL" || echo "(review_gate output empty)"
  echo '```'
  echo ""
  echo "> Notes: env changes require restart; /metrics shows \"Prometheus dormant\" without prometheus_client."
  echo ""
} >> docs/runbook/mvp_evidence.md

exit 0