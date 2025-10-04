#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/rt-health.sh" >/dev/null
curl -fsS -X POST "${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}" \
  -H "content-type: application/json" -d '{"task":"daily test"}' | jq -e . >/dev/null
echo "[rt-smoke ok]"
