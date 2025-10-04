#!/usr/bin/env bash
set -euo pipefail
health_raw="$(curl -fsS http://127.0.0.1:8010/health 2>/dev/null || true)"
if echo "$health_raw" | jq -r .status 2>/dev/null | grep -q '^ok$'; then
  echo "[health ok: json]"
elif echo "$health_raw" | tr -d '"' | grep -q '^ok$'; then
  echo "[health ok: plain]"
else
  if curl -fsS -X POST http://127.0.0.1:8010/orchestrate \
        -H "content-type: application/json" -d '{"task":"ping"}' >/dev/null 2>&1; then
    echo "[health ok: orchestrate-fallback]"
  else
    echo "[health ng]"
    exit 1
  fi
fi
