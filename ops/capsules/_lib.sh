#!/usr/bin/env bash
set -Eeuo pipefail
ok(){ echo "[OK] $*"; }
ng(){ echo "[NG] $*"; }
lock(){ mkdir -p /tmp/daegis_lock; exec 9<>"/tmp/daegis_lock/${CAPID:-unknown}.lock"; flock -n 9 || { ok "lock-skip ${CAPID:-unknown}"; exit 0; }; }
prep(){ cd ~/daegis || exit 1; source .venv/bin/activate 2>/dev/null || true; export PYTHONPATH="$PWD"; }
