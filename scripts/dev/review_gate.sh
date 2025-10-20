#!/usr/bin/env bash
set -euo pipefail

echo "=== Review Gate: API Validation ==="

# 1) Port Guard / 8080 存在確認（いずれかOK）
if curl -fsS -o /dev/null http://127.0.0.1:8080/ >/dev/null 2>&1 \
 || ss -lntp | grep -q ':8080'; then
  echo "Port Guard: [OK] 8080 service running"
else
  echo "Port Guard: [FAIL] 8080 not responding"
  exit 1
fi

# 2) /chat headers
if curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
   -H 'Content-Type: application/json' -d '{"user":"gate","content":"gate"}' \
   | tr -d '\r' | grep -qi '^x-episode-id:'; then
  echo "/chat Headers: [OK] x-episode-id present"
else
  echo "/chat Headers: [FAIL] header missing"
  exit 1
fi

# 3) Prometheus hints（グループ名に依存しない横断マッチ）
HINTS="$(curl -s http://127.0.0.1:9091/api/v1/rules \
  | jq -r '.data.groups[]? .rules[]? | .annotations.hint? // empty')"

if [ -n "$HINTS" ]; then
  # safe_fallback を含む行だけ抜粋（無ければ全表示）
  SAFE=$(printf "%s\n" "$HINTS" | grep -i 'safe_fallback' || true)
  if [ -n "$SAFE" ]; then
    echo "Prometheus Hints: [OK]"
    printf "%s\n" "$SAFE"
  else
    echo "Prometheus Hints: [WARN] hint present but no safe_fallback:"
    printf "%s\n" "$HINTS"
  fi
else
  echo "Prometheus Hints: [WARN] no hints via API"
  # ダイアグ（現在の rule_files と group 概況）
  echo "--- DIAG: rule_files ---"
  curl -s http://127.0.0.1:9091/api/v1/status/config \
    | jq -r '.data.yaml' | grep -A1 -B1 rule_files || true
  echo "--- DIAG: groups ---"
  curl -s http://127.0.0.1:9091/api/v1/rules \
    | jq -r '.data.groups[]?.name' || true
fi

# Count hints safely
HINT_COUNT=$(printf "%s\n" "$HINTS" | grep -c . 2>/dev/null || echo "0")
echo "[SAFE] hints = $HINT_COUNT"

echo
echo "GATE: PASS"

# 4) Quorum SAFE Integration
OUT=$(bash scripts/guard/quorum_safe.sh | tail -1 || true)
echo "[QUORUM] $OUT"

# --- Compass metrics presence (Phase IV) ---
if curl -s :9091/metrics | grep -q 'daegis_compass_intents_total'; then
  echo "[Compass] metrics present: OK"
else
  echo "[Compass] metrics present: MISSING"
fi

# --- Phase V V1: Metrics labeling (ACTIVE/DORMANT) ---
METRICS_BODY=$(curl -s http://127.0.0.1:8080/metrics 2>/dev/null || echo "")
if echo "$METRICS_BODY" | grep -q '# HELP'; then
  echo "[Compass] metrics: ACTIVE"
elif echo "$METRICS_BODY" | grep -q 'Prometheus dormant'; then
  echo "[Compass] metrics: DORMANT"
else
  echo "[Compass] metrics: UNKNOWN"
fi

# consensus gauge presence (optional)
CS=$(curl -s http://127.0.0.1:8080/metrics || true)
if printf '%s' "$CS" | grep -q '^daegis_consensus_score{'; then
  echo "[Consensus] score: PRESENT"
else
  echo "[Consensus] score: ABSENT"
fi

# Hash-Relay (real check)
if [ -n "${DAEGIS_NODES:-}" ]; then
  HR="$(bash scripts/dev/hash_relay.sh | tail -1 2>/dev/null || true)"
  echo "[Hash-Relay] ${HR#SUMMARY }"
fi
