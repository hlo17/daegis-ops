#!/usr/bin/env bash
set -euo pipefail
host="${1:-local}"  # local or round-table
case "$host" in
  local)  bash -lc 'mkdir -p ~/daegis/ark/backups; tar czf ~/daegis/ark/backups/halulog.$(date +%F).tgz -C ~/daegis/ark logbook' ;;
  round-table) ssh round-table 'bash -lc "mkdir -p ~/daegis/ark/backups; tar czf ~/daegis/ark/backups/halulog.$(date +%F).tgz -C ~/daegis/ark logbook"' ;;
  *) echo "usage: $(basename "$0") [local|round-table]"; exit 2 ;;
esac
echo "[done] backup on $host"
