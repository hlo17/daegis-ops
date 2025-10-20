#!/usr/bin/env sh
# --- Daegis ops sanity combo ---
set -e
echo "[1/2] Evidence snapshot..."
bash scripts/dev/evidence_snapshot.sh || echo "snapshot failed"
echo "[2/2] Metrics probe..."
bash scripts/dev/metrics_probe.sh || echo "probe failed"
echo "--- Sanity check complete ---"
exit 0