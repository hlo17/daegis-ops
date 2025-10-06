#!/usr/bin/env bash
set -euo pipefail

AM=${AM:-http://localhost:9093}

# クロスプラットフォームな日時計算
if command -v gdate >/dev/null 2>&1; then
  D=gdate
  START=$($D -u +"%FT%TZ")
  END=$($D -u -d "+2 min" +"%FT%TZ")
else
  D=date
  START=$($D -u +"%FT%TZ")
  # BSD date には -d がないので -v+2M を使う
  END=$($D -u -v+2M +"%FT%TZ")
fi

NONCE=$(date +%s)

jq -n --arg s "$START" --arg e "$END" --arg n "$NONCE" '[
  {"labels":{"alertname":"TestAlert","severity":"warn","instance":"manual","nonce":$n},
   "annotations":{"summary":"Manual test from API (nonce=" + $n + ")"},
   "startsAt":$s,"endsAt":$e}
]' | curl -sS -XPOST -H 'Content-Type: application/json' "$AM/api/v2/alerts" --data-binary @- \
  -o /dev/null -w 'status=%{http_code}\n'
