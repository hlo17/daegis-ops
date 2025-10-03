#!/usr/bin/env bash
set -euo pipefail
WARD_OUT=${WARD_OUT:-/tmp/ward-out}
/home/f/daegis/roundtable/venv/bin/python ~/daegis/ops/wardctl.py
docker exec staging-prometheus-1 kill -HUP 1
echo "[ward-apply] reloaded rules. current:"
curl -fsS http://127.0.0.1:9091/api/v1/rules \
| jq -r '.data.groups[].rules[]?.name' | paste -sd',' -
