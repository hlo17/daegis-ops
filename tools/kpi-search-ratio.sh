#!/usr/bin/env bash
set -euo pipefail
file="${1:-/var/log/roundtable/orchestrate.jsonl}"
all=$(tail -n 400 "$file" | jq -r '.task? // empty' | awk 'NF' | wc -l)
hit=$(tail -n 400 "$file" | jq -r '.task? // empty' | awk 'NF' | grep -E -i '(search|調べて)' | wc -l)
[ "$all" -eq 0 ] && { echo "0% (0/0)"; exit 0; }
printf "%s%% (%s/%s)\n" "$(( 100*hit/all ))" "$hit" "$all"
