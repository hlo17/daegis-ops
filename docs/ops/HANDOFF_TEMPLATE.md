---
window: garden-gate
type: handoff
topic: "<短い目的>"
from: "agent:lyra"
to: "agent:kai"
priority: normal
---

Intent: <1行で“何をできるようにするか”>
Inputs:
- 読取: <paths...>
- 書込: <paths...>
Outputs:
- <生成物のパス/PromQLでの観測方法>

DoD（検収手順）:
- <OK判定のコマンド/PromQL/パネルの見え方>

Constraints: <DRY/禁則/RBAC等>
Deadline/SLA: <例: 24h / 受領10分で着手連絡 / 4h中間>
Rollback: <戻し方>
Autonomy:
- write: ["logs/prom/*", "docs/ops/*"]
- change: ["etc/prometheus/rules/*.yml"] (approval=Lyra)
- forbidden: ["systemd*", "secrets/*"]
