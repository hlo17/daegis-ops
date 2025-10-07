#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://localhost:8080/chat}"
body='{"user":"canary","content":"ping","source":"canary"}'
code=$(curl -s -o /tmp/daegis_canary.out -w '%{http_code}' -H 'Content-Type: application/json' -d "$body" "$URL" || true)
grep -q '"text"' /tmp/daegis_canary.out && [ "$code" = "200" ]
