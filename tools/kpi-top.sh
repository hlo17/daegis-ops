#!/usr/bin/env bash
set -euo pipefail
file="${1:-/var/log/roundtable/orchestrate.jsonl}"

# JSON Lines -> 配列化してから処理
tail -n 500 "$file" \
| jq -s -r '
  map({t:(.t//.time), ms:(.latency_ms//0), task:(.task//"")})
  | sort_by(.ms) | reverse | .[0:5][]
  | "\(.ms)ms\t\(.task)"
'
