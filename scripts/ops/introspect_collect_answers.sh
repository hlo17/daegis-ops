#!/usr/bin/env bash
set -euo pipefail
changed=0
while read -r line; do
  [ -z "$line" ] && continue
  id="$(jq -r '.id' <<<"$line")"
  [ "$id" = "null" ] && continue
  ans="inbox/human_to_ai/${id}.md"
  if [ -s "$ans" ]; then
    # 既存openレコードをansweredへ更新行として追記（append-only）
    fts="$(date -u +%FT%TZ)"
    jq -nc --argjson base "$line" --arg ap "$ans" --arg ts "$fts" '
      $base + {status:"answered", answer_path:$ap, answered_at:$ts}
    ' >> logs/introspect.jsonl
    changed=1
  fi
done < <(jq -c 'select(.status=="open")' logs/introspect.jsonl 2>/dev/null || true)
[ "$changed" = "1" ] && echo "[collect] answered entries appended"
