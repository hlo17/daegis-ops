#!/usr/bin/env bash
set -euo pipefail
file="${1:-/var/log/roundtable/orchestrate.jsonl}"
tail -n 500 "$file" | jq -r '[.[]?|{t:(.t//.time),ms:(.latency_ms//0),task:(.task//"")}]|sort_by(.ms)|reverse| .[0:5][] | "\(.ms)ms\t\(.task)"'
