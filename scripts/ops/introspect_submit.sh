#!/usr/bin/env bash
set -euo pipefail
# usage: introspect_submit.sh "<from>" "<to>" "<topic>" "<body>" [tag1,tag2...]
FROM="${1:?from}"; TO="${2:?to}"; TOPIC="${3:?topic}"; BODY="${4:?body}"
TAGS="${5:-}"
TS="$(date -u +%FT%TZ)"
ID="$(printf '%s' "$FROM$TO$TOPIC$TS" | sha256sum | awk '{print substr($1,1,12)}')"
MSG_FILE="inbox/ai_to_human/${TS}_${ID}.md"
printf "# %s\n\nfrom: %s\nto: %s\nid: %s\nts: %s\n\ntopic: %s\n\n%s\n" \
  "$TOPIC" "$FROM" "$TO" "$ID" "$TS" "$TOPIC" "$BODY" > "$MSG_FILE"
jq -nc --arg id "$ID" --arg from "$FROM" --arg to "$TO" --arg topic "$TOPIC" \
       --arg body "$BODY" --arg tags "$TAGS" --arg ts "$TS" \
       '{id:$id,from:$from,to:$to,topic:$topic,body:$body,
         tags: ( ($tags|split(",") ) // [] ),
         status:"open", ts:$ts}' >> logs/introspect.jsonl
echo "[submit] $ID  → $MSG_FILE"
