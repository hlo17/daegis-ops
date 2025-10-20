#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/daegis/logs"
SRC="$LOG_DIR/reflection.jsonl"
OUT_MD="$LOG_DIR/reflection_summary.md"
ARCHIVE_DIR="$LOG_DIR/reflection_summary"

mkdir -p "$ARCHIVE_DIR"

# 直近24hに限定（環境変数にエポック秒を渡して jq で参照）
export CUTOFF="$(date -u -d '24 hours ago' +%s)"
UTC_DATE="$(date -u +%F)"
NOW_ISO="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TMP="$(mktemp)"

# ヘッダ
{
  echo "# Halu Reflection Summary — ${UTC_DATE}"
  echo
  echo "_Generated at ${NOW_ISO} (UTC), last 24h_"
  echo
  echo '| Timestamp (UTC) | Level | Metric | Value | Threshold | Note |'
  echo '|---|---|---:|---:|---:|---|'
} > "$TMP"

# JSONL を jq で整形（{}など無効行は除外）
if test -s "$SRC"; then
  jq -r '
    select(type=="object")
    | select(has("ts") and has("level") and has("metric"))
    | ( .ts as $ts
        | ( (try ($ts|fromdateiso8601) catch 0) ) as $t
        | select($t >= (env.CUTOFF|tonumber))
        | [ $ts,
            .level,
            .metric,
            ( .value // "" ),
            ( .threshold // "" ),
            ( .note // "" | gsub("\n"; " ") )
          ] | @tsv
      )
  ' "$SRC" \
  | awk -F'\t' '{printf("| %s | %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5,$6)}' \
  >> "$TMP"
fi

# 反射が無ければメッセージ
if [ "$(wc -l < "$TMP")" -le 6 ]; then
  echo "| (no reflections in last 24h) |  |  |  |  |  |" >> "$TMP"
fi

# 保存（最新と日次アーカイブ）
mv "$TMP" "$OUT_MD"
cp "$OUT_MD" "$ARCHIVE_DIR/${UTC_DATE}.md"

echo "[HaluSummary] updated $OUT_MD and archived ${UTC_DATE}.md"
