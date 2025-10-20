#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
last=$(sed -n '$p' logs/prom/daegis_playground.prom 2>/dev/null | awk '{print $2+0}' || echo 0)
if [ "$last" -gt 0 ]; then
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  card="inbox/window/${ts}_playground_broken_links.md"
  cat > "$card" <<MD
---
window: garden-gate
type: review_request
topic: "Playground: 壊れリンク検出（$last件）"
from: "agent:playground"
to: "agent:scribe"
priority: normal
---
docs/chronicle 以下で $last 件の壊れリンクを検出。
期待物: 修正案(diff)の提案 / 影響範囲の列挙（50字以内）
参照:
- docs/agents/assistant_profile.md
- docs/agents/AGENTS.md
- docs/chronicle/plans.md
MD
  id=$(tools/window_open.sh "Windowカード: Playground壊れリンク($last)" "agent:scribe" "$card")
  echo "[gate] card opened id=$id ($card)"
fi
