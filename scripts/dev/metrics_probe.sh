#!/usr/bin/env sh
set -e
url="${1:-http://127.0.0.1:8080/metrics}"
out="$(curl -sf "$url" || true)"
if echo "$out" | grep -q '^daegis_'; then
  echo "$out" | grep '^daegis_' | head -20
else
  echo "Prometheus dormant or unavailable"
fi
exit 0