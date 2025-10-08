#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://127.0.0.1:8080/metrics}"
code=$(curl -s -o /tmp/metrics.out -w "%{http_code}" "$URL" || true)
if [ "$code" = "200" ]; then
  echo "✅ /metrics 200"
  grep -c '^rt_latency_ms_bucket' /tmp/metrics.out || true
  exit 0
else
  echo "❌ /metrics $code"
  echo "Hint: pip install -r requirements-dev.txt  # dev only"
  exit 1
fi