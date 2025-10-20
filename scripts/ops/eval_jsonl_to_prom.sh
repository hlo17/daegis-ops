#!/usr/bin/env bash
set -euo pipefail

# === config ===
WINDOW_MIN=${WINDOW_MIN:-5}
SRC="${SRC:-logs/halu/eval_events.jsonl}"
OUT="logs/prom/halu_eval.prom"
mkdir -p "$(dirname "$OUT")"

if [[ ! -s "$SRC" ]]; then
  echo "[WARN] SRC not found or empty: $SRC" >&2
  # それでも空のメトリクスは出す（監視的に便利）
fi

# 直近 WINDOW_MIN 分の下限（UTC epoch）
SINCE=$(date -u -d "-${WINDOW_MIN} min" +%s)
# PASS / FAIL 件数（outcome を小文字化して判定）
PASS=0
FAIL=0

if [[ -f "$SRC" ]]; then
  PASS=$(jq -r --argjson s "$SINCE" '
    select(.t? and (.t|fromdateiso8601) >= $s)
    | (.outcome|ascii_downcase) as $o
    | select($o=="pass")
    | 1
  ' "$SRC" 2>/dev/null | wc -l | tr -d ' ')

  FAIL=$(jq -r --argjson s "$SINCE" '
    select(.t? and (.t|fromdateiso8601) >= $s)
    | (.outcome|ascii_downcase) as $o
    | select($o=="fail")
    | 1
  ' "$SRC" 2>/dev/null | wc -l | tr -d ' ')
fi

# 理由別 FAIL 集計
tmp_reason=$(mktemp)
if [[ -f "$SRC" ]]; then
  jq -r --argjson s "$SINCE" '
    select(.t? and (.t|fromdateiso8601) >= $s)
    | (.outcome|ascii_downcase) as $o
    | select($o=="fail")
    | (.reason // "unknown")
  ' "$SRC" 2>/dev/null \
  | awk '{c[$0]++} END{for (k in c) printf "%s\t%d\n", k, c[k]}' > "$tmp_reason" || true
fi
TS=$(date +%s)

{
  echo '# TYPE daegis_halu_eval_cases_window_total gauge'
  printf 'daegis_halu_eval_cases_window_total{result="pass",window="%sm"} %d\n' "$WINDOW_MIN" "$PASS"
  printf 'daegis_halu_eval_cases_window_total{result="fail",window="%sm"} %d\n' "$WINDOW_MIN" "$FAIL"

  echo
  echo '# TYPE daegis_halu_eval_cases_reason_window_total gauge'
  if [[ -s "$tmp_reason" ]]; then
    while IFS=$'\t' read -r reason n; do
      esc=$(printf '%s' "$reason" | sed 's/"/\\"/g')
      printf 'daegis_halu_eval_cases_reason_window_total{result="fail",reason="%s",window="%sm"} %d\n' "$esc" "$WINDOW_MIN" "$n"
    done < "$tmp_reason"
  fi

  echo
  echo '# TYPE daegis_halu_textfile_timestamp_seconds gauge'
  echo "daegis_halu_textfile_timestamp_seconds $TS"
} > "$OUT"

rm -f "$tmp_reason" 2>/dev/null || true

# debug
echo "[DBG] window=${WINDOW_MIN}m since=${SINCE} PASS=${PASS} FAIL=${FAIL}" >&2
echo "[DBG] wrote $OUT (bytes=$(stat -c%s "$OUT" 2>/dev/null || echo 0))" >&2
