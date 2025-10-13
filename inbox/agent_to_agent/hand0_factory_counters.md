---
window: garden-gate
type: handoff
topic: "Factory Counters v1（Dashboard Lite 4枚）"
from: "agent:lyra"
to: "agent:kai"
priority: high
---

Intent: Dashboard Lite に jobs_ok/fail/deny/dry を表示可能にする（Stat/Instant/Unit=None）。

Inputs:
- 読取: logs/factory_jobs.jsonl
- 書込: logs/prom/daegis_factory.prom, docs/ops/HANDOFF_MAP_v1.md（追記のみ）

Outputs:
- /metrics: daegis_factory_jobs_total{result="ok|fail|deny|dry"} <num>
- Grafana: `sum(daegis_factory_jobs_total{result="ok"})` が数値を返す
- HANDOFF_MAP_v1 に “Factory Counters” セクション追記

DoD:
- `curl -s :9205/metrics | grep '^daegis_factory_jobs_total'` が4行
- `sum(daegis_factory_jobs_total{result="ok"})` が数値
- ダッシュに4枚追加（Lyra指示別カードで実施可）

Constraints: DRY / sudo禁止 / 既存ファイルはappend-only / RBAC=ops:factory
Deadline: 24h（受領10分で着手連絡、4hで中間）
Rollback: logs/prom/daegis_factory.prom を直前版に戻す（WORM参照）

Autonomy:
- write: ["logs/prom/*", "docs/ops/*"]
- change: ["etc/prometheus/rules/*.yml"] (approval=Lyra)
- forbidden: ["systemd*", "secrets/*"]
