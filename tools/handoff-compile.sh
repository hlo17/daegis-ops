#!/usr/bin/env bash
set -euo pipefail
RB="$HOME/daegis/ops/runbooks/Daegis-Runbook.md"
WD="$HOME/daegis/ops/ward/Daegis-Ward.md"
LG="$HOME/daegis/Daegis Ledger.md"
out="$(mktemp)"
{
  echo "## Roundtable Hand-off ($(date -u +%FT%TZ))"
  echo "### Ledger (latest 5)"; tail -n 5 "$LG" 2>/dev/null || true
  echo; echo "### Ward (latest 20 lines)"; tail -n 20 "$WD" 2>/dev/null || true
  echo; echo "### Runbook (headlines)"; grep -E '^#{1,3} ' "$RB" 2>/dev/null | head -n 20 || true
} > "$out"
mosquitto_pub -h 127.0.0.1 -p 1883 -u f -P nknm -t daegis/notify/scribe -m "$(sed 's/"/\\"/g' "$out")"
echo "[handoff] sent."
