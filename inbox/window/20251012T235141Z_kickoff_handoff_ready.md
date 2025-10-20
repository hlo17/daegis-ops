---
window: garden-gate
type: handoff
topic: "Kickoff: handoff_ready.sh 実行依頼（SLO導入＋RUNBOOK雛形）"
from: "human:Gardener"
to: "agent:lyra"
priority: high
---
Lyraへ：
1) `~/handoff_ready.sh` を実行して、SLO録画ルール投入→Prom再起動→ルール読み込み確認まで完了させてください。
2) 成果物：
   - `/etc/prometheus/rules/daegis_sli.rules.yml` が配置済み
   - `curl :9090/api/v1/rules` で `daegis_sli` が見える
   - `docs/ops/HANDOFF_MAP_v1.md` が存在
3) 完了後、このカードに「実行ログ（3行）」を返信してください。
