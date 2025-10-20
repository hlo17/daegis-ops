#!/usr/bin/env bash
set -Eeuo pipefail
LOG=${LOG:-/tmp/factory.daemon.log}
PIDF=${PIDF:-/tmp/factory.daemon.pid}
case "${1:-status}" in
start)
pgrep -f 'ops/factory/daemon.sh' >/dev/null && { echo "running"; exit 0; }
nohup bash ops/factory/daemon.sh >>"$LOG" 2>&1 & echo $! > "$PIDF"
echo "started pid=$(cat "$PIDF") log=$LOG"
;;
stop)
pkill -f 'ops/factory/daemon.sh' >/dev/null 2>&1 || true
rm -f "$PIDF"; echo "stopped"
;;
restart) bash "$0" stop; sleep 1; bash "$0" start ;;
status)  pgrep -f 'ops/factory/daemon.sh' >/dev/null && echo "running" || echo "stopped" ;;
*) echo "usage: daemon_ctl.sh {start|stop|restart|status}" ;;
esac
