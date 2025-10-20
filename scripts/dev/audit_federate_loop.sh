#!/usr/bin/env sh
set -eu
INT="${INT:-900}"   # 15min default
COUNT="${COUNT:-0}" # 0=forever
i=0
while :; do
  echo "[audit-loop] $(date -u +%FT%TZ) run #$i"
  bash scripts/dev/audit_federate.sh || true
  i=$((i+1)); [ "$COUNT" -ne 0 ] && [ $i -ge $COUNT ] && break
  sleep "$INT"
done
exit 0