#!/usr/bin/env bash
set -euo pipefail
ts="$(date -u +%Y%m%dT%H%M%SZ)"
log="$HOME/daegis/logs/ward/selftest_$ts.log"
"$HOME/daegis/tools/ward-selftest.sh" | tee "$log"
