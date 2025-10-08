# Daegis · Copilot Instructions (v1)
**Scope:** このレポ内で“最小・可視・可逆”の変更だけを提案/生成する。まず `docs/copilot/README.md` を入口にして Ground Truth を参照。矛盾があれば *ask first*。

## Core Rules
- **No new runtime deps/services**（例: Redis, DB, 外部SaaS）を勝手に追加しない。必要なら**提案 → 承認待ち**。
- **Ask before destructive changes**（削除/改名/大量生成/フォーマット一括）は必ず事前確認。
- **Router defaults (/chat)**: 60s **in-memory** cache / 3.0s timeout→**504** / `X-Cache: HIT|MISS` を付与。既存 `rt_*` は非破壊で維持。
- 変更は **≤2ファイル / ≤80行** を目安。観測（メトリクス/ログ/テスト）を伴う。

## Where to Read First
- `docs/copilot/README.md`（index → Ground Truthへ誘導）
- パターン例: `router/app.py`, `router/chat_cache_timeout.py`
- 監視: `ops/monitoring/**`（Prometheus/Grafana/alerts）
- ランブック: `ops/runbooks/**`
- 検証: `scripts/verify_chat_patch.sh`

## Output Format (when proposing changes)
1) **Plan**（3行）
2) **Patch**（最小差分 / 触るファイルを明示）
3) **Tests**（先に2本：cache_hit / timeout_504 等）
4) **KP**（リスク/ロールバック/次アクション）

## Dev Workflows (examples)
- **/chat 検証**: `./scripts/verify_chat_patch.sh`（MISS→HIT→504→/metricsの確認。trapで自動停止）
- **Prometheus**: 変更後に `promtool check config` / `promtool check rules`
- **Grafana**: JSONは `${DS_PROMETHEUS}` プレースホルダのまま。Import後にDSをUIで選択。

## Metrics & Alerts (router)
- 既存: `rt_requests_total`, `rt_latency_ms(_bucket)`, `rt_cache_hits_total`, `rt_cache_misses_total`
- P95: `histogram_quantile(0.95, sum by (le)(rate(rt_latency_ms_bucket[5m])))`
- 代表アラート（目安）:
  - 5xx率: `sum(rate(router_chat_errors_total[5m])) / sum(rate(rt_requests_total{route="/chat"}[5m])) > 0.01 for 5m`
  - P95>3s: 上記P95 > 3000 (ms) for 5m

## Ask-First Triggers
- 依存追加 / 大規模生成 / 既存ダッシュボードの上書き / CIやSecrets構成の変更
- RouterのI/Fやlabel破壊、メトリクス名変更

> Follow these to stay useful, safe, and fast.
