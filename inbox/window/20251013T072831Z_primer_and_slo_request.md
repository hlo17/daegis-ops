---
window: garden-gate
type: handoff
topic: "Primer読了 → SLO% 3枚追加 & runbookリンク追記"
from: "human:Gardener"
to: "agent:lyra"
priority: high
---

Lyraへ：

1) Primerを読了：docs/ops/GARDEN_GATE_PRIMER.md
2) Dashboard（Overview 上段）に SLO%（Stat/Instant/percent/decimals=1）を3枚追加：
   - Freshness%       = avg_over_time(daegis:fresh:ok[15m]) * 100
   - Exporter Uptime% = avg_over_time(daegis:exporter:up[15m]) * 100
   - Scrape健全性%    = avg_over_time(daegis:scrape:ok[15m]) * 100
   しきい値（Absolute推奨）：🟢 99.5 / 🟡 98 / 🔴 0
3) Alert ルールの annotations.runbook を HANDOFF_MAP v1 の該当見出しアンカーへ追記。

完了報告（カード返信）：
- SLO% 3枚のスクショ（Overview上段）
- 下記3式の API 値（成功時の値）
  - avg_over_time(daegis:fresh:ok[15m]) * 100
  - avg_over_time(daegis:exporter:up[15m]) * 100
  - avg_over_time(daegis:scrape:ok[15m]) * 100
