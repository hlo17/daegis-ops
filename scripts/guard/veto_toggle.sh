#!/usr/bin/env sh
set -eu
CMD="${1:-status}"
mkdir -p flags
F=flags/L5_VETO
case "$CMD" in
  on)  date -u +%FT%TZ > "$F"; echo "[veto] ON → $F";;
  off) rm -f "$F"; echo "[veto] OFF";;
  *)   [ -f "$F" ] && echo "[veto] ON since $(cat "$F")" || echo "[veto] OFF";;
esac
exit 0
