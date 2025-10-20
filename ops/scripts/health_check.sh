#!/usr/bin/env bash
set -euo pipefail
echo "🔍 Daegis Health Check"
echo "Phase: $(cat ~/daegis/docs/chronicle/phase_tag.txt)"
echo "Halu state: $(cat ~/daegis/flags/L7_HALU_STATE)"
echo -n "LowPassRate: "
curl -s http://127.0.0.1:9091/metrics | grep -E '^daegis_low_pass_rate' || echo "n/a"

echo "Targets:"
curl -s http://127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | "\(.labels.job)\t\(.health)\t\(.lastError)"'

echo "Halu metrics:"
curl -s http://127.0.0.1:9091/metrics | grep -E '^(halu_up|daegis_sot_consistent|halu_last_heartbeat_age_seconds)' || echo "n/a"
