#!/usr/bin/env sh
# --- Daegis Prometheus Rebind (Phase XVIII precheck) ---
set -eu
echo "[1/5] Stop any orphaned Prometheus process..."
# stop common names; ignore failures
sudo pkill -f "/bin/prometheus" 2>/dev/null || true
sudo pkill -f "[p]rometheus --" 2>/dev/null || true
sudo systemctl stop prometheus 2>/dev/null || true

echo "[2/5] Backup & write minimal scrape config"
CFG="/etc/prometheus/prometheus.yml"
sudo mkdir -p /etc/prometheus
if [ -f "$CFG" ]; then sudo cp -a "$CFG" "${CFG}.bak.$(date -u +%FT%TZ)"; fi
sudo tee "$CFG" >/dev/null <<'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'daegis'
    static_configs:
      - targets: ['localhost:8080']
EOF

echo "[3/5] Enable & start Prometheus (systemd)"
sudo systemctl daemon-reload || true
sudo systemctl enable prometheus --now || sudo systemctl start prometheus || true

echo "[4/5] Health & targets"
sleep 2
ready="$(curl -sf localhost:9090/-/ready 2>/dev/null || true)"
echo "${ready:-"⚠️ no response on :9090"}"
targets="$(curl -sf localhost:9090/api/v1/targets?state=active 2>/dev/null || true)"
if command -v jq >/dev/null 2>&1 && [ -n "$targets" ]; then
  echo "$targets" | jq '.data.activeTargets | length'
else
  # fallback: grep-count
  echo "$targets" | grep -c '"health"' || echo 0
fi

echo "[5/5] Status"
sudo systemctl is-active prometheus || true
echo "--- Rebind complete ---"
exit 0