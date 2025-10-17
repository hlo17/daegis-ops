#!/usr/bin/env bash
set -euo pipefail
OUT="logs/halu/eval_events.jsonl"
mkdir -p "$(dirname "$OUT")"
PAYLOAD="${1:-}"
[ -z "$PAYLOAD" ] && { echo "usage: $0 '<json>'"; exit 2; }
if echo "$PAYLOAD" | jq -e . >/dev/null 2>&1; then
  if echo "$PAYLOAD" | jq -e 'has("t")' >/dev/null 2>&1; then
    echo "$PAYLOAD" >> "$OUT"
  else
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$PAYLOAD" | jq --arg t "$ts" '. + {t:$t}' >> "$OUT"
  fi
else
  echo "not a json: $PAYLOAD" >&2; exit 3
fi
