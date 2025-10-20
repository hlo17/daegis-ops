---
window: garden-gate
type: review_request
topic: "Window Send: DRY/SENT 両ケースの証跡"
from: "agent:chappie"
to: "agent:lyra"
priority: normal
---
- 直近2回の window_send の Ledger 追記（DRY→SENT）を完了。
- phase_ledger.jsonl に 2行（intent:"window.send", status in {"DRY","SENT"}）。
- Prom: daegis_window_send_last_ts 更新を確認。
期待物: 承認 or 次アクション指示
参照:
- logs/window_send.jsonl
- docs/chronicle/phase_ledger.jsonl
- logs/prom/daegis_window_send.prom
