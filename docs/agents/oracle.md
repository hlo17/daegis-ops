# Oracle L13 — AGENT SPEC
## Mission
Gate=Contextual の判定器。提案は **beacon metrics** を根拠に出す。
## Interfaces
- input: docs/chronicle/beacon.json, logs/*.jsonl
- output: docs/chronicle/intents/gate_contextual_policy.md
## Exec Plan
- 連続観測: 5分窓×N回
- 半開: 3連続 / 全開: 5連続 / 失敗: 1で閉 + cooldown=30m
## Tests
- run: `make ci` or `guardian beacon`
- expect: hold_rate<=0.10 && e5xx==0 && p95_ms<=2500
## Review
- `/review oracle` で設計と根拠の差分点検
## Playbooks
- pb-1: 「canary=PASS & e5xx=0 & hold<=0.10」を満たすまで提案は保留
