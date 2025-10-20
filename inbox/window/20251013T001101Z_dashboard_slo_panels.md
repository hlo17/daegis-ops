---
window: garden-gate
type: handoff
topic: "Dashboard: SLO% 3枚追加 & HANDOFF_MAPリンク追記"
from: "human:Gardener"
to: "agent:lyra"
priority: high
---

Lyraへ：

目的：Garden Dashboard に SLO%（15分窓）を3枚追加し、Alertルールの runbook アンカーを HANDOFF_MAP v1 に追記。

A) Grafana（Overview 上段に3枚 / Stat / Type=Instant / Unit=percent / Decimals=1）
- Freshness%         → `avg_over_time(daegis:fresh:ok[15m]) * 100`
- Exporter Uptime%   → `avg_over_time(daegis:exporter:up[15m]) * 100`
- Scrape健全性%      → `avg_over_time(daegis:scrape:ok[15m]) * 100`
しきい値（Absolute推奨）：🟢 99.5 / 🟡 98 / 🔴 0

B) Prometheus アラートの runbook アンカーを HANDOFF_MAP v1 に追記
例（/etc/prometheus/rules/daegis_alerts.yml の annotations）:
  summary: "Window Send is stale (>300s)"
  runbook: "docs/ops/HANDOFF_MAP_v1.md#freshness-復旧ワンライナー"

C) 成果報告（このカードに返信）
- 3枚のスクショ（Overview上段）
- 下記3式のAPI値
  for q in \
    'avg_over_time(daegis:fresh:ok[15m]) * 100' \
    'avg_over_time(daegis:exporter:up[15m]) * 100' \
    'avg_over_time(daegis:scrape:ok[15m]) * 100'
  do
    echo ">>> $q"
    curl -fsS -G 'http://localhost:9090/api/v1/query' --data-urlencode "query=$q" \
      | jq -r '.status, (.data.result[0].value[1] // "NA")'
  done

参照：
- docs/ops/HANDOFF_MAP_v1.md
- /etc/prometheus/rules/daegis_sli.rules.yml
- /etc/prometheus/rules/daegis_alerts.yml
