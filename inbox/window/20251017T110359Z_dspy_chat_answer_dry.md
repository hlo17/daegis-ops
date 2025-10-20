---
window: garden-gate
type: handoff
topic: "DSPy: COPRO [chat_answer] — DRY eval v0"
from: "human:Gardener"
to: "agent:lyra"
priority: high
status: open
---
目的: chat_answer の誤反応低減（要約分離）
DoD:
- metric: daegis_dspy_best_score{intent="chat_answer"} >= 0.70
- no regression vs last
- output: docs/overview/dspy/chat_answer_summary.md
制約: DryRun only / no adoption / no external API
期限: (UTC)
