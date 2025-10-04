#!/usr/bin/env bash
set -euo pipefail
echo "[ward-selftest] start at $(date -u +%FT%TZ)"

# 1) systemd failed units
if systemctl list-units --type=service --state=failed --no-legend | grep -q .; then
  echo "[units failed]"
  systemctl list-units --type=service --state=failed
else
  echo "[units ok]"
fi

# 2) relay check
if systemctl is-enabled daegis-sora-relay.service >/dev/null 2>&1; then
  echo "[warn] relay enabled"
else
  echo "[relay masked ok]"
fi

# 3) orchestrate health（JSON/素文字/フォールバック）
"$HOME/daegis/tools/rt-health.sh" || true
health_raw="$(curl -fsS http://127.0.0.1:8010/health 2>/dev/null || true)"
if echo "$health_raw" | jq -r .status 2>/dev/null | grep -q '^ok$'; then
  echo "[health ok: json]"
elif echo "$health_raw" | tr -d '"' | grep -q '^ok$'; then
  echo "[health ok: plain]"
else
  if curl -fsS -X POST http://127.0.0.1:8010/orchestrate \
        -H "content-type: application/json" -d '{"task":"ping"}' >/dev/null 2>&1; then
    echo "[health ok: orchestrate-fallback]"
  else
    echo "[health ng]"
  fi
fi

# 4) mosquitto bus（1秒で無音なら正常扱い）
timeout 1s mosquitto_sub -h 127.0.0.1 -p 1883 -t daegis/# -C 1 -v >/dev/null 2>&1 \
  && echo "[bus rx]" || echo "[bus quiet-ok]"

echo "[ward-selftest] done"
