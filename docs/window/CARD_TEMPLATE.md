---
window: daegis
type: review_request   # review_request | handoff | decision
topic: "<短い件名>"
from: "human:AEGIS"
to: "agent:luna"       # agent:oracle.l13 / agent:scribe / external:chatgpt など
priority: normal       # low | normal | high
---
要旨（1〜3行）
- 添付: 相互参照するファイルへの相対パス
- 期待するアウトプット（例: diff/提案/チェックリスト）

参照:
- docs/agents/assistant_profile.md
- docs/agents/AGENTS.md
- docs/chronicle/plans.md
