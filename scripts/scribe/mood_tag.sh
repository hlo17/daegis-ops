#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
mood="${1:-SILENCE}"; tone="${2:-}"
note="${3:-}"
ts=$(date -u +%FT%TZ)
echo "- mood:$mood tone:${tone:-null} note:\"${note}\" ts:$ts" >> docs/chronicle/ledger.md
printf '{"ts":"%s","event":"mood_tag","mood":"%s","tone":"%s","note":"%s"}\n' "$ts" "$mood" "${tone:-}" "$note" >> logs/worm/journal.jsonl
