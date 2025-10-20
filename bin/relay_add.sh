#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
REL="$ROOT/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/Relay"
AGENT="${1:?agent name e.g. Lera}"
LINK="${2:?wiki link e.g. [[brief/ferment_2025-10-14T09:00:00Z.md]]}"
NOTE="$REL/Relay ${AGENT}.md"

mkdir -p "$REL"
ts="$(date -u +%FT%TZ)"                    # UTC固定
printf -- "- %s %s\n" "$ts" "$LINK" >> "$NOTE"
echo "[relay_add] appended -> $NOTE"
