#!/usr/bin/env sh
set -eu
# Optional Slack notify for the latest Chronicle snapshot
OUT="docs/runbook/chronicle_weekly.md"
[ -f "$OUT" ] || { echo "[chronicle] no report yet"; exit 0; }
MSG="$(tail -n 30 "$OUT")"
echo "[chronicle] preview:"
printf "%s\n" "$MSG"
if [ -n "${CHRONICLE_SLACK_WEBHOOK:-}" ]; then
  printf '{"text":%s}\n' "$(printf '%s' "$MSG" | python - <<'PY'
import sys,json;print(json.dumps(sys.stdin.read()))
PY
)" \
   | curl -sS -X POST -H 'Content-Type: application/json' --data-binary @- "$CHRONICLE_SLACK_WEBHOOK" >/dev/null || true
  echo "[chronicle] slack: sent"
fi
exit 0