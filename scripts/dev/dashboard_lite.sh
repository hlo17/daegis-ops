#!/usr/bin/env bash
set -euo pipefail
ROOT="${DAEGIS_ROOT:-$HOME/daegis}"
cd "$ROOT"
OUT="docs/runbook/dashboard_lite.md"
mkdir -p "$(dirname "$OUT")"

{
  echo "### KPI (fixed)"
  if [ -f logs/policy_canary_verdict.jsonl ]; then
    tac logs/policy_canary_verdict.jsonl \
      | jq -r 'select(.event=="canary_verdict") | "  verdict=\(.verdict) p95_ms=\(.p95_ms//"NA") hold_rate=\(.hold_rate//"NA") e5xx=\(.e5xx//"NA") window=\(.window_sec//"NA")s"' \
      | head -1
  else
    echo "  verdict=NA p95_ms=NA hold_rate=NA e5xx=NA window=NA"
  fi
  if [ -f logs/policy_apply_controlled.jsonl ]; then
    tac logs/policy_apply_controlled.jsonl | head -200 \
      | jq -r 'select(.event=="adopt_block") | 1' | wc -l | awk '{printf("  adopt_block_last200=%s\n",$1)}'
  else
    echo "  adopt_block_last200=0"
  fi
} >> "$OUT"

echo "[ok] wrote KPI to $OUT"
