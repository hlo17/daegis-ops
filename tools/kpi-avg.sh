#!/usr/bin/env bash
set -euo pipefail
file="${1:-/var/log/roundtable/orchestrate.jsonl}"
tail -n 400 "$file" | jq -s 'map(.latency_ms // 0) | if length==0 then 0 else add/length end'
