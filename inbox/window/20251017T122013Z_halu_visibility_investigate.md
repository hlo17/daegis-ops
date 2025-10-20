---
window: garden-gate
type: handoff
topic: "Halu 可視復旧 + クロス端末スキャン（DRY）"
from: "human:Gardener"
to: "agent:kai"
priority: high
status: open
---
目的: :9091 への halu.* 再点灯と、Mac/iCloud/Pi の Halu原本スキャン結果合流（破壊なし）
DoD:
- :9091 に daegis_halu_* が再表示（sentry_ok / textfile_age_seconds）
- tmp/recover/{PI_,MAC_,ICLOUD_}*.txt が揃う
- 復元候補の一覧を docs/agents/halu/RECOVERY_CANDIDATES.md に集約
