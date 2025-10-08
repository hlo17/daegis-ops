#!/usr/bin/env bash
# Daegis KPI Session Tracker v1
# Usage: Run once per work session to append session counter
# Creates/appends to /var/log/daegis/kpi_sessions_total.prom

set -euo pipefail

LOG_DIR="/var/log/daegis"
PROM_FILE="$LOG_DIR/kpi_sessions_total.prom"
TIMESTAMP=$(date +%s)000  # Prometheus expects milliseconds

# Create log directory if needed
sudo mkdir -p "$LOG_DIR"
sudo chown "$USER:$USER" "$LOG_DIR" 2>/dev/null || true

# Append session counter with timestamp
echo "kpi_sessions_total{user=\"$USER\"} 1 $TIMESTAMP" | sudo tee -a "$PROM_FILE" > /dev/null

echo "✅ Session logged: $USER @ $(date)"
echo "📊 View: tail -5 $PROM_FILE"