#!/usr/bin/env bash
set -euo pipefail
LOG="$HOME/daegis/logs/reflection.jsonl"
mkdir -p "$(dirname "$LOG")"
if [ $# -gt 0 ]; then
  PAYLOAD="$*"
else
  ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  MSG="昨日の私の判断を振り返り、改善点を記録する"
  PAYLOAD="{\"ts\":\"$ISO\",\"message\":\"$MSG\",\"type\":\"reflection\"}"
fi
echo "$PAYLOAD" >> "$LOG"
echo "[emit] reflection appended."
