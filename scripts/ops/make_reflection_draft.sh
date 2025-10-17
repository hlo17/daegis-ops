#!/usr/bin/env bash
set -euo pipefail
SRC="logs/halu/eval_events.jsonl"
OUT="docs/chronicle/reflection_$(date -u +%Y%m%dT%H%M%SZ)_draft.md"
fail_top=$(tail -n 1000 "$SRC" 2>/dev/null | jq -r 'select(.outcome=="FAIL")|.reason' | sort | uniq -c | sort -nr | head -n5)
cat > "$OUT" <<MD
# Reflection Draft ($(date -u +"%Y-%m-%d %H:%M UTC"))
- Top FAIL reasons (recent 1000):
\`\`\`
$fail_top
\`\`\`
- Hypothesis:
- Proposed experiments:
- Guardrails: HUMAN.ok required / Quorum check
MD
echo "$OUT"
