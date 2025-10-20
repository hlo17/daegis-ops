---
window: garden-gate
type: review_request
topic: "DNA統合: schema/検証/運用ポリシー確認"
from: "human:Gardener"
to: "agent:oracle"   # 12-3 (Oracle系)に回す想定。必要なら宛先調整
priority: normal
---
対象: agent_dna.jsonl 統合（hash_rely / halu_rely / spirit_fingerprint）
確認事項:
- 目的/境界, フォーマット/検証, 運用/ライフサイクル, 合意形成
参照: docs/handbook/HANDOFF_MAP.md, ops/ledger/agent_dna.schema.json（予定）, ops/ledger/agent_identity.jsonl
期待物: Yes/No と修正案（JSON diff 可）
