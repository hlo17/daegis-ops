#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
LED="$ROOT/docs/ledger/halu.jsonl"
MET="$ROOT/logs/prom/halu_reflection_summary.prom"

iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# 要約メトリクスと最新サマリ行から、短い一文を作る
TOTAL=$(awk '/^daegis_halu_reflection_summary_total_1h/{print $2+0}' "$MET" 2>/dev/null || echo 0)
TOP=$(tail -n1 "$ROOT/docs/ledger/halu.jsonl" | jq -r '.top_intents|join("/")' 2>/dev/null || echo "")

NOTE="last1h reflections=${TOTAL}; top=${TOP:-n/a}"
echo "{\"t\":\"$(iso)\",\"act\":\"memo\",\"why\":\"hourly reflection\",\"note\":\"${NOTE}\",\"stage\":\"L3\"}" >> "$LED"
echo "[OK] memo → ledger :: $NOTE"
