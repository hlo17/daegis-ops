#!/usr/bin/env bash
set -Eeuo pipefail
pgrep -f 'ops/factory/daemon.sh' >/dev/null || nohup bash ops/factory/daemon.sh >>/tmp/factory.daemon.log 2>&1 &
