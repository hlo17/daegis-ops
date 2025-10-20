#!/usr/bin/env bash
set -euo pipefail
now=$(date +%s); keep=3600
mkdir -p "$HOME/daegis/queue/quarantine"
for f in "$HOME/daegis/queue/approved"/*.json; do
  [ -e "$f" ] || continue
  m=$(stat -c %Y "$f"); (( now-m > keep )) && mv -f "$f" "$HOME/daegis/queue/quarantine/"
done
