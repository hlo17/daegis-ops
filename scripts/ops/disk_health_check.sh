#!/usr/bin/env bash
set -euo pipefail
th=10
use=$(df -P / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$use" -ge $((100-th)) ]; then
  ts=$(date -u +%FT%TZ)
  echo "{\"ts\":\"$ts\",\"event\":\"low_disk\",\"used_pct\":$use}" >> "$HOME/daegis/logs/worm/journal.jsonl"
fi
