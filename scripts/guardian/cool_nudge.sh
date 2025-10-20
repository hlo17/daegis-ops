#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"; HUB="$ROOT/garden/hub"; INBOX="$ROOT/inbox/ai_to_human"
f="$HUB/@current"
age=99999
[ -f "$f" ] && age=$(( ( $(date +%s) - $(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f") )/60 ))
[ $age -lt 480 ] && exit 0  # 8h以内ならスキップ

ts=$(date -u +%FT%TZ)
msg="[Trellis] nudge: set focus? (last=${age}m) $ts"
printf "# Trellis Nudge\n\n%s\n" "$msg" > "$INBOX/trellis_nudge_$(date +%s).md"
