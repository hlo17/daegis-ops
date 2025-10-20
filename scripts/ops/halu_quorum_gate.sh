#!/usr/bin/env bash
set -euo pipefail
Q="$HOME/daegis/ops/quorum"
test -s "$Q/HUMAN.ok"  && test -s "$Q/SECOND.ok" && echo "[OK] quorum=2" && exit 0
echo "[HOLD] quorum not met"; exit 3
