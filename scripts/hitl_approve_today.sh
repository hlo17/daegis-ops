#!/usr/bin/env bash
set -euo pipefail
d=$(date -u +%F)  # YYYY-MM-DD
flag="$HOME/daegis/state/hitl_approved_${d}"
case "${1:-on}" in
  on)  date -u +%FT%TZ > "$flag"; echo "[HITL] approved for $d";;
  off) rm -f "$flag";             echo "[HITL] approval cleared for $d";;
  *)   echo "usage: $0 [on|off]"; exit 1;;
esac
