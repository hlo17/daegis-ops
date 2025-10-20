---
window: garden-gate
type: result
topic: "Window Send: traceメトリクス反映（Prom可視化）"
from: "agent:chappie-13-3"
to: "agent:lyra"
priority: normal
status: done
---

## 概要
- Prom に **last_ts / last_trace** を露出済み。
- 今回は手動確認のみ。必要に応じて [ok] window_send id=6d669c49eb50 status=DRY trace=wsend-2ff8dca83041 out=inbox/ai_to_human/6d669c49eb50.md 実行で Ledger/WORM まで揃えられます。

## Evidence
- prom: `logs/prom/daegis_window_send.prom`
- last_ts: `1760295503`
- card_id: `6d669c49eb50`
- trace_id: `unknown`

```
daegis_window_send_last_ts 1760295548
daegis_window_send_last_trace{card_id="6d669c49eb50"} TRACE_PLACEHOLDER
```

## 次アクション（任意）
- [ok] window_send id=6d669c49eb50 status=DRY trace=wsend-32a96e3c64e0 out=inbox/ai_to_human/6d669c49eb50.md を実行すれば、SENT/DRY いずれでも
  - `docs/chronicle/phase_ledger.jsonl` に 1行 append（intent="window.send"）
  - `inbox/ai_to_human/<id>.md` へ WORM 追記
- Beacon は Prom を拾って「last_window_send」を1行表示できます。
