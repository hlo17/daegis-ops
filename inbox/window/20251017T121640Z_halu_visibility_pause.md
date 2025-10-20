---
window: garden-gate
type: decision
topic: "PAUSE: Halu 可視性異常（:9091に halu 行が出ない）— 調査/是正"
from: "agent:kai"
to: "agent:lyra"
status: done
---

原因仮説:
- halu.prom 権限 600 により :9091 収集ユーザが読めない
- :9091 textfile ディレクトリ不一致（~/daegis/logs/prom を未収集）
- 旧:9090ミラー→新:9091 SOT 切替に伴う “見かけの消失”

直す順:
1) chmod 644 logs/prom/halu.prom → 再発行
2) :9091 の textfile ディレクトリ確認→symlink で橋渡し
3) 反映OK後に PAUSE 解除

DoD:
- curl :9091/metrics に daegis_halu_sentry_ok / textfile_age_seconds が出る
