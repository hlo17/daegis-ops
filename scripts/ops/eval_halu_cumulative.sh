#!/usr/bin/env bash
set -euo pipefail
SRC="${SRC:-logs/halu/eval_events.jsonl}"
OUT="logs/prom/halu_eval_cum.prom"
mkdir -p "$(dirname "$OUT")"

# 全期間の累積（窓に依存しない）
TP=$(jq -r 'select(.outcome?) | (.outcome|ascii_downcase) | select(.=="pass") | 1' "$SRC" 2>/dev/null | wc -l | tr -d ' ')
TF=$(jq -r 'select(.outcome?) | (.outcome|ascii_downcase) | select(.=="fail") | 1' "$SRC" 2>/dev/null | wc -l | tr -d ' ')
TS=$(date +%s)

TMP="${OUT}.tmp.$$"
{
  echo '# TYPE daegis_halu_eval_cases_total counter'
  printf 'daegis_halu_eval_cases_total{result="pass"} %s\n' "$TP"
  printf 'daegis_halu_eval_cases_total{result="fail"} %s\n' "$TF"
  echo
  echo '# TYPE daegis_halu_textfile_timestamp_seconds gauge'
  echo "daegis_halu_textfile_timestamp_seconds $TS"
} > "$TMP"
mv -f "$TMP" "$OUT"
