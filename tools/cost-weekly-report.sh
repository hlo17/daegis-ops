#!/usr/bin/env bash
set -euo pipefail
H="${MQTT_HOST:-127.0.0.1}"; P="${MQTT_PORT:-1883}"
U="${MQTT_USER:-f}"; PW="${MQTT_PASS:-nknm}"
# 直近7日を learn_events.jsonl からざっくり集計（USD合計/agent別/件数）
FILE="$HOME/daegis/data/learn_events.jsonl"
if [ ! -f "$FILE" ]; then exit 0; fi
cut -d$'\n' -f1- "$FILE" | \
jq -s '
  . as $a
  | {
     n: ($a|length),
     usd_total: ($a|map(.cost.usd // 0)|add),
     by_agent: ($a|group_by(.chosen)|map({agent:(.[0].chosen//"unknown"),n:length,usd: (map(.cost.usd // 0)|add)}) )
    }' > /tmp/cost_week.json

msg="$(jq -r '"Cost weekly: n=\(.n)  usd_total=$\(.usd_total)  " +
                 ( .by_agent | map("\(.agent):n=\(.n),$=\(.usd)") | join("  ") )' /tmp/cost_week.json)"
mosquitto_pub -h "$H" -p "$P" -u "$U" -P "$PW" -t 'daegis/notify/scribe' -m "$msg"
echo "$msg"
