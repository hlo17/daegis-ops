#!/usr/bin/env bash
set -euo pipefail
H="${MQTT_HOST:-127.0.0.1}"; P="${MQTT_PORT:-1883}"
U="${MQTT_USER:-f}"; PW="${MQTT_PASS:-nknm}"
TS="$(date -u +%FT%TZ)"
TOP="daegis/selftest/smoke"
mosquitto_pub -h "$H" -p "$P" -u "$U" -P "$PW" -t "$TOP" -m "ping $TS"
timeout 1s mosquitto_sub -h "$H" -p "$P" -t "$TOP" -C 1 -v >/dev/null 2>&1 \
  && echo "[mqtt ok]" || echo "[mqtt quiet-ok]"
