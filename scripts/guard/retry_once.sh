#!/usr/bin/env bash
set -euo pipefail
# usage: retry_once <cmd...>
# 1回失敗したら 50–200ms ジッタ後に1回だけ再試行
if "$@"; then exit 0; fi
us=$(python3 - <<'PY';import random;print(int((0.05+random.random()*0.15)*1_000_000));PY)
usleep "${us}" || true
exec "$@"
