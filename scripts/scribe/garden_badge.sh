#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
mood=$(tac logs/worm/journal.jsonl 2>/dev/null | grep -m1 '"event":"mood_tag"' | sed -E 's/.*"mood":"([^"]+)".*/\1/')
badge="SILENCE"; case "$mood" in
 AWE) badge="GARDEN_PURPLE";; LOVE) badge="GARDEN_GOLD";; FEAR) badge="GARDEN_GREY";;
 JOY) badge="GARDEN_GREEN";; FLOW) badge="GARDEN_BLUE";; ANGER) badge="GARDEN_RED";;
 GRIEF) badge="GARDEN_NAVY";; TRANSCEND) badge="GARDEN_WHITE";;
esac
echo "dashboard_badge=$badge"
sed -i "1s/^/# badge:$badge\n/" docs/runbook/dashboard_lite.md 2>/dev/null || true
printf '{"ts":"%s","event":"garden_badge","badge":"%s"}\n' "$(date -u +%FT%TZ)" "$badge" >> logs/worm/journal.jsonl
