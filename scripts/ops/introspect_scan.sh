#!/usr/bin/env bash
set -euo pipefail
OUT="docs/chronicle/introspect_open.md"
TS="$(date -u +%FT%TZ)"
{
  echo "# Introspect Open Questions (as of $TS)"
  echo
  # open のみ抽出
  jq -c 'select(.status=="open")' logs/introspect.jsonl 2>/dev/null | \
  jq -rs '
    ( . // [] ) as $arr
    | if ($arr|length)==0
      then [ {id:"(none)", from:"-", to:"-", topic:"-", ts:"-", path:"-"} ]
      else $arr
      end
  ' | jq -r '.[] | "- **\(.topic)**  (#\(.id))\n  - from: \(.from) → to: \(.to)\n  - ts: \(.ts)\n  - reply: inbox/human_to_ai/\(.id).md\n"'
} > "$OUT"
echo "[scan] wrote $OUT"
