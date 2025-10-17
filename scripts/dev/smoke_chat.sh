#!/usr/bin/env bash
set -euo pipefail
curl -sS -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -d '{"q":"ping"}' \
  | jq -e '.message=="ok"' >/dev/null
echo "[OK] /chat smoke passed"
