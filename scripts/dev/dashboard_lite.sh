#!/usr/bin/env sh
set -eu
OUT="docs/runbook/dashboard_lite.md"
TS="$(date -u +%FT%TZ)"
echo "## Dashboard Lite — $TS" >> "$OUT"
echo "" >> "$OUT"

# decisions/holds
if [ -f logs/decision.jsonl ]; then
  total=$(wc -l < logs/decision.jsonl || echo 0)
  holds=$(jq -r '.ethics.verdict' logs/decision.jsonl 2>/dev/null | grep -c '^HOLD$' || echo 0)
  echo "- decisions: ${total}, holds: ${holds}" >> "$OUT"
else
  echo "- decisions: (no file)" >> "$OUT"
fi

# simbrain proposals
if [ -f logs/simbrain_proposals.jsonl ]; then
  echo "" >> "$OUT"; echo "### SimBrain proposals (tail 5)" >> "$OUT"
  tail -5 logs/simbrain_proposals.jsonl | sed 's/^/  /' >> "$OUT"
fi

# policy dry-run
if [ -f logs/policy_decision.jsonl ]; then
  wins=$(jq -r '.win' logs/policy_decision.jsonl 2>/dev/null | grep -c '^true$' || echo 0)
  tots=$(wc -l < logs/policy_decision.jsonl || echo 0)
  echo "- policy dry-run wins: ${wins}/${tots}" >> "$OUT"
fi

# shadow apply
if [ -f logs/policy_apply_shadow.jsonl ]; then
  echo "" >> "$OUT"; echo "### Shadow apply (tail 5)" >> "$OUT"
  tail -5 logs/policy_apply_shadow.jsonl | sed 's/^/  /' >> "$OUT"
fi

# canary/controlled (将来の証跡)
[ -f logs/auto_tune_canary.jsonl ] && { echo ""; echo "### Canary (tail 3)"; } >> "$OUT" && tail -3 logs/auto_tune_canary.jsonl | sed 's/^/  /' >> "$OUT" || true
[ -f logs/auto_tune_revoke.jsonl ] && { echo ""; echo "### Revokes (tail 3)"; } >> "$OUT" && tail -3 logs/auto_tune_revoke.jsonl | sed 's/^/  /' >> "$OUT" || true

echo "" >> "$OUT"
echo "_Appended by scripts/dev/dashboard_lite.sh_" >> "$OUT"
echo "[dash-lite] appended → $OUT"
