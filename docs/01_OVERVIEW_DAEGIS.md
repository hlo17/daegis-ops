# Daegis Overview
- Goal: AIオーケストレーション基盤（小さく安全に増築）
- Layers: infra / router / agents / observability / docs / security
- Dataflow: Slack/HTTP → Router → MQTT → Agents → Scribe → Docs

## Principles（WHY/DO/DON’T）
- DO: 最小PATCH / 可観測化優先 / 先に失敗テスト
- DON’T: 暗黙の設定 / 無監視のロングタスク
- WHY: 運用事故の最小化と改善速度の最大化
