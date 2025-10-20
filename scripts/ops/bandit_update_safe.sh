#!/usr/bin/env bash
set -euo pipefail
LOCK=/home/f/daegis/state/.policy.lock
exec flock -x "$LOCK" /usr/bin/env python3 /home/f/daegis/scripts/ops/bandit_update.py
