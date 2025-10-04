#!/usr/bin/env bash
set -euo pipefail
echo "== Roundtable smoke x60 =="
ok=1
for i in {1..60}; do
  bash -lc 'curl -fsS -X POST "${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}" \
    -H "content-type: application/json" -d "{\"task\":\"daily test\"}" | jq -e . >/dev/null' \
  || { ok=0; echo "[fail at] $i"; break; }
  sleep 1
done
[ "$ok" -eq 1 ] && echo "[smoke-ok] 60/60" || echo "[smoke-ng]"

echo "== Mosquitto listen :1883 =="
ss -ltnp | awk '$4 ~ /:1883$/ {print}'

echo "== Latest log =="
ls -1t "$HOME/daegis/logs"/*.log 2>/dev/null | head -1 | xargs -r tail -n +1 || echo "[no logs]"
