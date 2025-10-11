#!/usr/bin/env sh
set -eu
OUT="docs/runbook/chronicle_weekly.md"
mkdir -p "$(dirname "$OUT")"
TS="$(date -u +%FT%TZ)"
echo "## Chronicle snapshot — $TS" >> "$OUT"
echo "" >> "$OUT"
echo "### Key metrics" >> "$OUT"
echo "" >> "$OUT"
# decisions
if [ -f logs/decision.jsonl ]; then
  total=$(wc -l < logs/decision.jsonl || echo 0)
  holds=$(jq -r '.ethics.verdict' logs/decision.jsonl 2>/dev/null | grep -c '^HOLD$' || echo 0)
  echo "- decisions: ${total}, holds: ${holds}" >> "$OUT"
else
  echo "- decisions: 0 (no file)" >> "$OUT"
fi
# policy dry-run
if [ -f logs/policy_decision.jsonl ]; then
  wins=$(jq -r '.win' logs/policy_decision.jsonl 2>/dev/null | grep -c '^true$' || echo 0)
  totalp=$(wc -l < logs/policy_decision.jsonl || echo 0)
  echo "- policy dry-run wins: ${wins}/${totalp}" >> "$OUT"
fi
# alerts
if [ -f logs/alerts.log ]; then
  echo "- alerts (last 10):" >> "$OUT"
  tail -10 logs/alerts.log | sed 's/^/  /' >> "$OUT" || true
fi
# consensus federated sample
if [ -f logs/consensus_federated.jsonl ]; then
  echo "" >> "$OUT"
  echo "### Consensus federated (tail 3)" >> "$OUT"
  tail -3 logs/consensus_federated.jsonl | sed 's/^/  /' >> "$OUT" || true
fi
echo "" >> "$OUT"
echo "_Appended by scripts/dev/chronicle_weekly.sh_" >> "$OUT"
echo "" >> "$OUT"
echo "[chronicle] appended → $OUT"
exit 0