#!/usr/bin/env bash
# Minimal RAG PoC: search local corpus (archives, docs, logs) and POST context+query to /chat
# Usage: ./scripts/dev/rag_poc.sh "your question here"
set -euo pipefail

QUERY="${1:-What is Halu?}"
MAX_SNIPPETS=${MAX_SNIPPETS:-3}
OUT_TMP="/tmp/rag_poc.$$"
SEARCH_DIRS=("archives" "docs" "logs")

collect_snippets() {
  local q="$1"
  local limit=$2
  local snippets_file="$3"
  : > "$snippets_file"
  if command -v rg >/dev/null 2>&1; then
    rg -n --no-heading --context 0 --max-columns 200 --ignore-case --hidden --glob '!node_modules' --glob '!*.git/*' "$q" "${SEARCH_DIRS[@]}" 2>/dev/null \
      | head -n $((limit*3)) \
      | sed -n '1,300p' >> "$snippets_file" || true
  else
    for d in "${SEARCH_DIRS[@]}"; do
      if [ -d "$d" ]; then
        grep -RIn --line-number --exclude-dir='.git' --exclude='*.db' -i "$q" "$d" 2>/dev/null | head -n $((limit*3)) >> "$snippets_file" || true
      fi
    done
  fi
}

SNIPPETS_FILE="$OUT_TMP.snippets"
collect_snippets "$QUERY" "$MAX_SNIPPETS" "$SNIPPETS_FILE"

if [ -s "$SNIPPETS_FILE" ]; then
  CONTEXT=$(awk 'NR<=30{print}' "$SNIPPETS_FILE" | sed 's/"/\\"/g' | sed -e 's/^/  /')
else
  CONTEXT=""
fi

PROMPT="Context snippets (local search):\n$CONTEXT\n\nUser question:\n$QUERY\n\nInstructions: Answer concisely and, if using the context, mention the filenames/lines. If no relevant context, say so."

echo "=== RAG PoC: composed prompt ===" >&2
echo -e "$PROMPT" >&2
echo "=== end prompt ===" >&2

if command -v jq >/dev/null 2>&1; then
  PAYLOAD=$(jq -n --arg q "$PROMPT" '{q:$q}')
else
  PAYLOAD=$(printf '{"q":"%s"}' "$(printf '%s' "$PROMPT" | sed ':a;N;$!ba;s/\n/\\n/g;s/"/\\"/g')")
fi

if ! curl -sS --max-time 3 http://127.0.0.1:8080/ >/dev/null 2>&1; then
  echo "ERROR: router at http://127.0.0.1:8080/ not reachable. Start via VS Code Task: 'Uvicorn (copilot-exec)'" >&2
  rm -f "$SNIPPETS_FILE"
  exit 2
fi

TMPRESP="/tmp/rag_poc_resp.$$"
curl -sS -w "\nHTTP_STATUS:%{http_code}\n" -X POST http://127.0.0.1:8080/chat -H 'Content-Type: application/json' -d "$PAYLOAD" -o "$TMPRESP" || true
cat "$TMPRESP"
echo
grep -n "HTTP_STATUS" "$TMPRESP" || true
rm -f "$SNIPPETS_FILE" "$TMPRESP"
