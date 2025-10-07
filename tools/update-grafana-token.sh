#!/usr/bin/env bash
set -euo pipefail

# === Daegis Grafana Service Account Token Updater (Grafana >= 12) ===
ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
ADMIN_PASS="${GRAFANA_ADMIN_PASS:-nknm}"

# serve_from_sub_path = true かつ root_url = .../grafana/ なので、APIは /grafana/api 配下を叩く
API_BASE="http://localhost:3000/grafana/api"

TTL=$((30*24*3600))   # 30 days
CONF="$HOME/.config/daegis.env"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT

echo "health check"; curl -fsS "${API_BASE}/health" > /dev/null

# 1) Service Account を作成（既存なら200/409系→拾い直し）
SA_NAME="daegis-auto"
echo "👤 ensure service account: ${SA_NAME}"
code=$(curl -sS -u "${ADMIN_USER}:${ADMIN_PASS}" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"${SA_NAME}\",\"role\":\"Admin\"}" \
  -o "$TMP" -w "%{http_code}" \
  "${API_BASE}/serviceaccounts" || true)

if [[ "$code" != "200" && "$code" != "201" && "$code" != "409" ]]; then
  echo "❌ create SA failed (HTTP=${code})"; cat "$TMP"; exit 2
fi

# ID を取得（新規作成 or 既存一覧から）
SA_ID="$(jq -r '.id? // empty' <"$TMP")"
if [[ -z "$SA_ID" ]]; then
  # 既存から検索
  curl -sS -u "${ADMIN_USER}:${ADMIN_PASS}" "${API_BASE}/serviceaccounts/search?query=${SA_NAME}" > "$TMP"
  SA_ID="$(jq -r '.serviceAccounts[] | select(.name=="'"${SA_NAME}"'") | .id' <"$TMP")"
fi
[[ -n "$SA_ID" ]] || { echo "❌ service account id not found"; cat "$TMP"; exit 3; }
echo "🔑 SA id=${SA_ID}"

# 2) Token を発行
TOK_NAME="daegis-auto-$(date +%Y%m%d)"
echo "🔐 create token: ${TOK_NAME} (TTL=${TTL}s)"
code=$(curl -sS -u "${ADMIN_USER}:${ADMIN_PASS}" \
  -H 'Content-Type: application/json' \
  -d "{\"name\":\"${TOK_NAME}\",\"secondsToLive\":${TTL}}" \
  -o "$TMP" -w "%{http_code}" \
  "${API_BASE}/serviceaccounts/${SA_ID}/tokens" || true)

if [[ "$code" != "200" && "$code" != "201" ]]; then
  echo "❌ create token failed (HTTP=${code})"; cat "$TMP"; exit 4
fi

TOKEN="$(jq -r '.key // .token // empty' <"$TMP")"
[[ -n "$TOKEN" ]] || { echo "❌ token missing"; cat "$TMP"; exit 5; }

# 3) .env に保存（GRAFANA_API_TOKEN）
mkdir -p "$(dirname "$CONF")"
if grep -q '^GRAFANA_API_TOKEN=' "$CONF" 2>/dev/null; then
  sed -i "s|^GRAFANA_API_TOKEN=.*|GRAFANA_API_TOKEN=${TOKEN}|" "$CONF"
else
  echo "GRAFANA_API_TOKEN=${TOKEN}" >> "$CONF"
fi
echo "✅ saved to $CONF : ${TOKEN:0:8}…"
