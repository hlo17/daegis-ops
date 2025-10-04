#!/usr/bin/env bash
set -euo pipefail
"$HOME/daegis/tools/logrun.sh" rt-smoke -- \
  bash -lc 'curl --fail -sS -X POST "${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}" \
    -H "content-type: application/json" -d "{\"task\":\"daily test\"}" | jq -e .'
