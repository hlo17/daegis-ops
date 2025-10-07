#!/usr/bin/env bash
set -euo pipefail

# === Daegis Grafana API Key Updater (works with /grafana UI; /api for local) ===
ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
ADMIN_PASS="${GRAFANA_ADMIN_PASS:-nknm}"

# API はローカル直アクセスで /api を使う（/grafana は UI 用）
URL_API_BASE="http://localhost:3000"

TTL=$((30*24*3600))   # 30 days
CONFIG="$HOME/.config/daegis.env"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT

echo "🔎 health: ${URL_API_BASE}/api/health"
curl -fsS "${URL_API_BASE}/api/health" > /dev/null

echo "🔑 creating API key (TTL=${TTL}s)…"
code=$(curl -sS -u "${ADMIN_USER}:${ADMIN_PASS}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"daegis-auto-$(date +%Y%m%d)\",\"role\":\"Admin\",\"secondsToLive\":${TTL}}" \
  -o "$TMP" -w "%{http_code}" \
  "${URL_API_BASE}/api/auth/keys" || true)

if [[ "$code" != "200" && "$code" != "201" ]]; then
  echo "❌ failed: HTTP=${code}"
  echo "response:"; cat "$TMP"; echo
  exit 2
fi

API_KEY="$(jq -r '.key // empty' < "$TMP")"
if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
  echo "❌ success but key missing"; cat "$TMP"; exit 3
fi

mkdir -p "$(dirname "$CONFIG")"
if grep -q '^GRAFANA_API_KEY=' "$CONFIG" 2>/dev/null; then
  sed -i "s|^GRAFANA_API_KEY=.*|GRAFANA_API_KEY=${API_KEY}|" "$CONFIG"
else
  echo "GRAFANA_API_KEY=${API_KEY}" >> "$CONFIG"
fi

echo "✅ saved: $CONFIG"
echo "   preview: ${API_KEY:0:8}…"
