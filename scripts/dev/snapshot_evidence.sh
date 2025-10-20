#!/usr/bin/env bash
set -euo pipefail

RUNBOOK="docs/runbook/mvp_evidence.md"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

BRANCH="$(git rev-parse --abbrev-ref HEAD || echo 'unknown')"
COMMIT="$(git log -1 --oneline || echo 'unknown')"
TAG_LINE="$(git describe --tags --abbrev=0 2>/dev/null || echo 'no-tag')"

echo "=== Evidence Snapshot @ $TS ==="
echo "Branch: $BRANCH"
echo "Commit: $COMMIT"
echo "Tag:    $TAG_LINE"

echo "---- Headers (HIT expected) ----"
HDRS="$(curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -d '{"q":"snapshot"}' \
  | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-episode-id)' || true)"
echo "$HDRS"

echo "---- Ledger (last line) ----"
LEDGER_LAST="$(tail -1 logs/decision.jsonl 2>/dev/null || echo 'ledger: (empty)')"
echo "$LEDGER_LAST"

echo "---- Alert hints (:9091) ----"
HINTS="$(curl -s http://127.0.0.1:9091/api/v1/rules | jq -r \
  '.data.groups[] | select(.name=="daegis-kpi") | .rules[] | select(.name | test("Chat")) | .annotations.hint' 2>/dev/null || true)"
[ -z "${HINTS}" ] && HINTS="(no hints or Prometheus not running)"

mkdir -p "$(dirname "$RUNBOOK")"
{
  echo "## Evidence Snapshot — $TS"
  echo "- Branch: $BRANCH"
  echo "- Commit: $COMMIT"
  echo "- Tag: $TAG_LINE"
  echo ""
  echo "### Headers"
  echo '```'
  echo "$HDRS"
  echo '```'
  echo ""
  echo "### Decision Ledger (last)"
  echo '```json'
  echo "$LEDGER_LAST"
  echo '```'
  echo ""
  echo "### Alert Hints (:9091)"
  echo '```'
  echo "$HINTS"
  echo '```'
  echo ""
} >> "$RUNBOOK"

echo "Appended snapshot to $RUNBOOK"