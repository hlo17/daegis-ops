#!/usr/bin/env bash
set -euo pipefail
arch="$1"
tmp=$(mktemp -d)
tar -xzf "$arch" -C "$tmp"
sudo cp -a "$tmp"/* /etc/prometheus/
sudo systemctl daemon-reload
sudo systemctl restart prometheus
echo "[OK] Prometheus restored from $arch"
