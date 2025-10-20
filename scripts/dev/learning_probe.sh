#!/usr/bin/env sh
set -eu
P="${DAEGIS_LEARNING_PATH:-logs/learning_feedback.jsonl}"
echo "Learning sink: $P"
if [ ! -f "$P" ]; then echo "MISSING"; exit 0; fi
wc -l "$P" | awk '{print "lines=" $1}'
if command -v jq >/dev/null 2>&1; then
  tail -1 "$P" | jq -c .
else
  tail -1 "$P" | tr -d '\n'
fi
exit 0