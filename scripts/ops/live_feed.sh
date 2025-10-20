#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
out="docs/overview/live_feed.md"
{
  echo "# Live Feed (tail)"
  echo "## window_send"; tail -n 12 logs/window_send.jsonl 2>/dev/null || true
  echo "## bus"; tail -n 12 logs/bus/queue.ndjson 2>/dev/null || true
  echo "## dna"; tail -n 12 ops/ledger/agent_dna.jsonl 2>/dev/null || true
} > "$out"
