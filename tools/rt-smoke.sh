#!/usr/bin/env bash
set -euo pipefail
if command -v rt-health >/dev/null 2>&1; then
  rt-health >/dev/null
else
  SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -x "$SELF_DIR/rt-health.sh" ]; then
    "$SELF_DIR/rt-health.sh" >/dev/null
  elif [ -x "$SELF_DIR/rt-health" ]; then
    "$SELF_DIR/rt-health" >/dev/null
  else
    echo "[rt-smoke] no rt-health found" >&2
    exit 1
  fi
fi
curl -fsS -X POST "${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}" \
  -H "content-type: application/json" -d "{\"task\":\"daily test\"}" | jq -e . >/dev/null
echo "[rt-smoke ok]"
