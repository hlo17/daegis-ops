#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
lane="${1:?lyra|chappie|kai}"

case "$lane" in
  lyra)   to="agent:lyra"    ;;
  chappie)to="agent:chappie" ;;
  kai)    to="agent:oracle"  ;;  # 12-3=Oracle=Kai
  *) echo "[ERR] unknown lane: $lane"; exit 2;;
esac

jid=$(tac logs/introspect.jsonl | jq -r 'select(.status=="open") | .id' | head -1)
[ -n "$jid" ] || { echo "[ERR] no open id"; exit 1; }
echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"event\":\"route\",\"id\":\"$jid\",\"to\":\"$to\"}" >> logs/window_send.jsonl
echo "[ok] routed $jid -> $to"
