#!/usr/bin/env bash
set -euo pipefail
task="${1:?usage: cost-publish <task_id> <agent> <usd> <tokens>}"
agent="${2:?}"; usd="${3:?}"; tokens="${4:?}"
H="${MQTT_HOST:-127.0.0.1}"; P="${MQTT_PORT:-1883}"
U="${MQTT_USER:-f}"; PW="${MQTT_PASS:-nknm}"
ts="$(date -u +%FT%TZ)"
json="$(jq -cn --arg ts "$ts" --arg task "$task" --arg agent "$agent" --arg usd "$usd" --arg tokens "$tokens" \
        '{ts:$ts,task_id:$task,agent:$agent,usd:($usd|tonumber),tokens:($tokens|tonumber)}')"
mosquitto_pub -h "$H" -p "$P" -u "$U" -P "$PW" -t 'daegis/metrics/cost' -m "$json"
echo "[cost] $json"
