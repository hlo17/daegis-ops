#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
B=docs/chronicle/beacon.json
P=ops/factory/policies.d/narrative_triggers.json
[ -f "$B" ] && [ -f "$P" ] || exit 0
mood=$(tac logs/worm/journal.jsonl 2>/dev/null | grep -m1 '"event":"mood_tag"' | sed -E 's/.*"mood":"([^"]+)".*/\1/')
hr=$(jq -r '.KPI.hold_rate // 1' "$B")
if jq -e '.[] | select(.id=="awe_research_boot")' "$P" >/dev/null 2>&1; then
  thr=$(jq -r '.[]|select(.id=="awe_research_boot")|.when.hold_rate_max' "$P")
  if [ "${mood:-}" = "AWE" ] && awk "BEGIN{exit !($hr < $thr)}"; then
    ts=$(date -u +%Y%m%dT%H%M%SZ)
    card="inbox/window/${ts}_awe_boot.md"
    cat > "$card" <<MD
---
window: garden-gate
type: review_request
topic: "AWE: 自発研究の提案（hold=$hr）"
from: "agent:oracle"
to: "agent:oracle"
priority: normal
---
AWE状態かつ hold_rate<$thr。短期リサーチの起動を提案。
intent: play.explore
参照:
- docs/agents/assistant_profile.md
- ops/policy/emotion_codex.yml
- docs/chronicle/plans.md
MD
    tools/window_open.sh "Windowカード: AWE自発研究" "agent:oracle" "$card" >/dev/null
    echo "[narrative] AWE trigger opened: $card"
  fi
fi
