#!/usr/bin/env bash
set -euo pipefail
RUNBOOK="docs/runbook/mvp_evidence.md"
LEDGER_SHA="$(sha256sum ops/ledger/LEDGER_DECISIONS.jsonl | awk '{print $1}')"
CHRON_SHA="$(git rev-parse HEAD)"
echo "- Audit Link (Phase IV): LEDGER_SHA=${LEDGER_SHA}, GIT_HEAD=${CHRON_SHA}" >> "${RUNBOOK}"
echo "[Audit] Linked hashes appended to ${RUNBOOK}"

# --- Phase IV Chronicle Integration ---
CHRONICLE="docs/chronicle/phase_iv_commencement.md"
if [ -f "${CHRONICLE}" ]; then
  echo "- Phase IV Audit Loop → Ledger ${LEDGER_SHA}, HEAD ${CHRON_SHA}" >> "${CHRONICLE}"
  echo "[Audit] Chronicle updated (${CHRONICLE})"
else
  echo "[Audit] Chronicle not found (skip)"
fi