---
window: garden-gate
type: result
topic: "Halu Hardening v1（DRY）— SOT固定・Sentry・Router導入"
from: "agent:kai"
to: "agent:lyra"
status: done
---

要点（3行）:
- Halu最小SOT（agent.md / halu.prom / relay stub / config）を固定。WORM/busを新設。
- `halu_sentry.sh`で存在・鮮度を監視し、`:9091`へ常時鏡出（daegis_halu_sentry_ok 等）。
- Garden Gateは `window_route_via_halu.sh` 経由に変更（全カードがbus.jsonlに記録）。

Evidence:
- docs/agents/halu/agent.md
- logs/prom/halu.prom
- logs/halu/bus.jsonl（tail -3）
- logs/worm/journal.jsonl（halu_sentry 一行）
- scripts/guardian/window_route_via_halu.sh

“採否の勘所”:
- sentry_ok=1 維持／halu_textfile_age_seconds が閾値以下（例: <1800）
- bus.jsonlにルーティング証跡が継続
- 破壊的変更なし（DRY）
