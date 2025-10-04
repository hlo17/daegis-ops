#!/usr/bin/env bash
set -euo pipefail
PREF="${1:?usage: mqtt-retain-clear <prefix>}"
H="${MQTT_HOST:-127.0.0.1}"; P="${MQTT_PORT:-1883}"
U="${MQTT_USER:-f}"; PW="${MQTT_PASS:-nknm}"
topics=$(
  timeout 1s mosquitto_sub -h "$H" -p "$P" -u "$U" -P "$PW" -t "$PREF/#" -v -C 1000 2>/dev/null \
  | awk '{print $1}' | sort -u
)
if [ -z "${topics}" ]; then
  echo "[info] no retained under $PREF"
  exit 0
fi
echo "[clear] retained under $PREF:"
echo "$topics" | sed 's/^/  - /'
while read -r t; do
  [ -n "$t" ] && mosquitto_pub -h "$H" -p "$P" -u "$U" -P "$PW" -t "$t" -r -n || true
done <<< "$topics"
echo "[done] $PREF"
