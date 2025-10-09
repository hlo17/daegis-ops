#!/usr/bin/env bash
set -euo pipefail

FLAG_FILE="ops/policy/mode.safe"
COMPASS_FILE="ops/policy/compass.json"

# Read compass constraints (with fallback)
get_p95_threshold() {
    if command -v jq >/dev/null 2>&1 && [[ -f "$COMPASS_FILE" ]]; then
        jq -r '.constraints.p95_ms // 3000' "$COMPASS_FILE" 2>/dev/null || echo 3000
    else
        echo 3000
    fi
}

case "${1:-}" in
    --enable)
        mkdir -p "$(dirname "$FLAG_FILE")"
        touch "$FLAG_FILE"
        echo "SAFE MODE: ON"
        ;;
    --disable)
        rm -f "$FLAG_FILE"
        echo "SAFE MODE: OFF"
        ;;
    "")
        # Check metrics and recommend if needed
        P95_THRESHOLD=$(get_p95_threshold)
        
        if ! METRICS=$(curl -s http://127.0.0.1:8080/metrics 2>/dev/null); then
            echo "metrics unavailable; no action"
            exit 0
        fi
        
        if [[ "$METRICS" == *"prometheus_client not installed"* ]]; then
            echo "metrics unavailable; no action"
            exit 0
        fi
        
        # Extract bucket counts (simple grep approach)
        LE_2_5=$(echo "$METRICS" | grep 'rt_latency_ms_bucket{.*le="2.5"' | tail -1 | awk '{print $2}' || echo "0")
        LE_INF=$(echo "$METRICS" | grep 'rt_latency_ms_bucket{.*le="+Inf"' | tail -1 | awk '{print $2}' || echo "1")
        
        if [[ "$LE_INF" -gt 0 ]]; then
            RATIO=$(awk "BEGIN {printf \"%.2f\", $LE_2_5 / $LE_INF}")
            if awk "BEGIN {exit ($RATIO < 0.95)}"; then
                echo "RECOMMEND SAFE MODE (p95 ratio: $RATIO)"
            else
                echo "metrics OK (p95 ratio: $RATIO)"
            fi
        else
            echo "insufficient metrics data"
        fi
        ;;
    *)
        echo "Usage: $0 [--enable|--disable]"
        echo "  --enable   Enable safe mode"
        echo "  --disable  Disable safe mode" 
        echo "  (no args)  Check metrics and recommend"
        exit 1
        ;;
esac