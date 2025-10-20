#!/usr/bin/env bash
set -euo pipefail
PROM="$HOME/daegis/logs/prom/halu_intent.prom"
base=$(awk '/^daegis_halu_intent_exec_total/{print $2+0}' "$PROM" 2>/dev/null || echo 0)
bash "$HOME/daegis/scripts/ops/halu_intent_propose.sh"
bash "$HOME/daegis/scripts/ops/halu_intent_execute.sh" reflect_digest_hourly
now=$(awk '/^daegis_halu_intent_exec_total/{print $2+0}' "$PROM" 2>/dev/null || echo 0)
if [ "$now" -ge $((base+1)) ]; then echo "[PASS] intent counter increased: $base -> $now"; exit 0; fi
echo "[FAIL] counter did not increase: $base -> $now"; exit 2
