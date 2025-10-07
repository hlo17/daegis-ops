#!/usr/bin/env bash
set -euo pipefail
TS=$(date -u +%Y%m%dT%H%M%SZ)
SRC="${HALU_LOG_DIR:-$HOME/halu/train/logs}"
DST="${HALU_SNAP_DIR:-$HOME/daegis/snapshots/archive}"
mkdir -p "$DST"
OUT="$DST/halu-logs-$TS.tar.gz"
tar -C "$SRC" -czf "$OUT" . 2>/dev/null || tar -czf "$OUT" -T /dev/null
# 30日超を削除
find "$DST" -name 'halu-logs-*.tar.gz' -mtime +30 -type f -delete || true
# 通知
MQTT_HOST=${MQTT_HOST:-127.0.0.1}
MQTT_PORT=${MQTT_PORT:-1883}
MQTT_USER=${MQTT_USER:-f}
MQTT_PASS=${MQTT_PASS:-Temp-1234}
mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
  -t 'daegis/halu/notify' -m "{\"backup\":\"ok\",\"file\":\"$OUT\",\"ts\":\"$TS\"}" || true
