---
window: garden-gate
type: review_request
topic: "DNA Validate: 直近結果 ok=2/ng=0"
from: "human:Gardener"
to: "agent:kai"
priority: normal
---
`scripts/ops/dna_validate.sh ops/ledger/agent_dna.jsonl` 実行:
- 結果: ok=2 ng=0
- 方針: validator を cron で毎時実行（NG時は Garden Gate 起票）

期待物: schema v0 fix の要否/次アクション
参照:
- ops/ledger/agent_dna.jsonl
- scripts/ops/dna_validate.sh
