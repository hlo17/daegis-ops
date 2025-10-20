#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="$HOME/daegis/logs"
OUT_JSON="$OUT_DIR/halu_self_metrics.json"
REFLECT_FILE="$OUT_DIR/reflection.jsonl"
PROM_URL="http://127.0.0.1:9091/metrics"
HB_FILE="$HOME/daegis/flags/HALU_HEARTBEAT"

mkdir -p "$OUT_DIR" "$HOME/daegis/flags"

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- 心拍は必ず更新（set -eでも落ちないよう || true）
: > "$HB_FILE" || true
touch "$HB_FILE" || true

# --- metrics収集（空値ガード付き）
halu_up=$(curl -s "$PROM_URL" | awk '/^halu_up / {print $2}' || true)
sot_consistent=$(curl -s "$PROM_URL" | awk '/^daegis_sot_consistent / {print $2}' || true)
heartbeat_age=$(curl -s "$PROM_URL" | awk '/^halu_last_heartbeat_age_seconds / {print $2}' || true)

: "${halu_up:=0}"
: "${sot_consistent:=0}"
: "${heartbeat_age:=1e9}"

# --- スナップショットJSON
cat > "$OUT_JSON" <<JSON
{
  "timestamp": "$timestamp",
  "halu_up": $halu_up,
  "sot_consistent": $sot_consistent,
  "heartbeat_age": $heartbeat_age
}
JSON

# --- reflectionログは必ず存在
touch "$REFLECT_FILE"

append_reflection () {
  # $1=level $2=metric $3=value $4=threshold $5=note
  printf '{"ts":"%s","level":"%s","metric":"%s","value":%s,"threshold":%s,"note":"%s"}\n' \
    "$timestamp" "$1" "$2" "$3" "$4" "$5" >> "$REFLECT_FILE"
}

# 1) halu_up != 1（致命）
up_int="${halu_up%.*}"
if [ "${up_int:-0}" -ne 1 ]; then
  append_reflection "critical" "halu_up" "${halu_up}" "1" "exporter reports halu_up!=1"
fi

# 2) 心拍 >180s（警告）: set -eでも落ちない if構造
if awk "BEGIN{exit($heartbeat_age > 180 ? 0 : 1)}"; then
  append_reflection "warning" "halu_last_heartbeat_age_seconds" "${heartbeat_age}" "180" "heartbeat stale (>3m)"
fi

echo "[HaluMetrics] updated at $timestamp"
