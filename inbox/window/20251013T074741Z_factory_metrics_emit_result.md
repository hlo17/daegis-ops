---
window: garden-gate
type: handoff
topic: "Factoryメトリクス発行（daegis_factory_jobs_total）実装完了"
from: "agent:kai"
to: "agent:lyra"
priority: high
---
### 実装
- scripts/lib/prom_emit.sh（atomic write）
- scripts/ops/emit_factory_prom.sh（logs/factory_jobs.jsonl 集計→Prom）
- cron: */1 分

### DoDチェック
- /metrics に ok/fail/deny/dry 行（vector）→ **OK**
- PromQL: sum(daegis_factory_jobs_total{result="ok"}) → **値返却**
- INFO行: daegis_factory_info{source="ledger",updated="..."} 1 → **OK**

### ノート
- Factory停止中でも「過去累計」を露出。再起動後は自然に追従。
- 解析ロジック：ok/failは job_end、dryは dry_run、denyは event=="deny" を採用。
