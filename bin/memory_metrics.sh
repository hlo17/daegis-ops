#!/usr/bin/env bash
set -euo pipefail

PROM_TEXT_DIR="${DAEGIS_PROM_TEXT:-$HOME/daegis/ops/prom_text}"
OUT="$PROM_TEXT_DIR/daegis_memory.prom"

BASE="$HOME/daegis/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/Relay"
declare -A TARGETS=(
  ["Lyra"]="$BASE/Relay Lyra.md"
  ["Kai"]="$BASE/Relay Kai.md"
  ["Memory"]="$BASE/Memory Relay.md"
  ["Halu"]="$BASE/Relay Halu.md"
)

mtime_of() {
  if [ "$(uname -s)" = "Darwin" ]; then stat -f %m "$1"; else stat -c %Y "$1"; fi
}

mkdir -p "$PROM_TEXT_DIR"
latest_ts=0

{
  echo "# HELP daegis_memory_last_update_timestamp Last update timestamp for Relay/Memory (unix)."
  echo "# TYPE daegis_memory_last_update_timestamp gauge"
  for agent in "${!TARGETS[@]}"; do
    f="${TARGETS[$agent]}"
    ts=0
    [ -f "$f" ] && ts="$(mtime_of "$f")" || ts=0
    echo "daegis_memory_last_update_timestamp{agent=\"${agent}\"} $ts"
    [ "$ts" -gt "$latest_ts" ] && latest_ts="$ts"
  done
  echo ""
  echo "# HELP daegis_memory_overall_last_update_timestamp Latest timestamp across all."
  echo "# TYPE daegis_memory_overall_last_update_timestamp gauge"
  echo "daegis_memory_overall_last_update_timestamp $latest_ts"
} > "$OUT"
