#!/usr/bin/env bash
set -euo pipefail
base="${1:-http://127.0.0.1:8080}"
echo "→ induce timeout"
code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$base/chat" \
       -H 'Content-Type: application/json' -d '{"q":"slow","delay":4}')
echo "HTTP: $code (expect 504)"
echo "→ check metrics"
mcode=$(curl -s -o /tmp/metrics.out -w "%{http_code}" "$base/metrics" || true)
echo "/metrics HTTP: $mcode"
if [ "$mcode" != "200" ]; then
  echo "Hint(dev): pip install -r requirements-dev.txt"
  exit 0
fi
grep -E 'rt_latency_ms_bucket|rt_cache_(hits|misses)_total' /tmp/metrics.out || true