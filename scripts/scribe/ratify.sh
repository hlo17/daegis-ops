#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
entry="${1:-latest}"
who="${2:-chatgpt13-2}"
ts=$(date -u +%FT%TZ)
echo "{\"ts\":\"$ts\",\"entry\":\"$entry\",\"ratified_by\":\"$who\"}" >> docs/chronicle/ratifications.jsonl
echo "ratified: $entry by $who"
