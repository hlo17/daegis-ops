#!/usr/bin/env sh
set -eu
URL="${1:-http://127.0.0.1:8080/metrics}"
BODY="$(curl -s "$URL" || true)"

status="UNKNOWN"
printf '%s' "$BODY" | grep -q '^# HELP' && status="ACTIVE"
printf '%s' "$BODY" | grep -q 'Prometheus dormant' && status="DORMANT"

echo "== Daegis Metrics Probe =="
echo "Endpoint: $URL"
echo "Status  : $status"
echo "--- compass intents (sample) ---"
printf '%s\n' "$BODY" | grep -E '^daegis_compass_intents_.*_total' | head -5 || true
echo "--- consensus score (sample) ---"
printf '%s\n' "$BODY" | grep -E '^daegis_consensus_score\{.*\} ' | head -5 || true

if [ "$status" = "DORMANT" ]; then
  echo "Hint: prometheus_client not active. (Dormant is OK in dev)"
fi