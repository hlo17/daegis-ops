#!/usr/bin/env bash
set -euo pipefail
file="${1:-/var/log/roundtable/orchestrate.jsonl}"

# 一度だけ tail → jq して配列化
lines="$(tail -n 400 "$file")"
all=$(printf "%s\n" "$lines" | jq -r '.task? // empty' | awk 'NF' | wc -l)
hit=$(printf "%s\n" "$lines" | jq -r '.task? // empty' | awk 'NF' | grep -E -i '(search|調べて)' | wc -l)
[ "${all:-0}" -eq 0 ] && { echo "0% (0/0)"; exit 0; }
printf "%s%% (%s/%s)\n" "$(( 100*hit/all ))" "$hit" "$all"
