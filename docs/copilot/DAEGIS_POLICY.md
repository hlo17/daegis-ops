# Daegis Copilot 運用ルール（v1）
- 入口: `docs/copilot/README.md`。矛盾は **ask first**。
- **Scope厳守**: 指定ファイル以外は触らない。
- **No new runtime deps/services**（Redis/DB/SaaS）禁止。必要なら「提案→許可待ち」。
- 破壊的変更（削除/改名/大量生成/一括整形）は **事前確認**。
- Router /chat 既定: 60s **in-memory** cache / 3.0s timeout→**504** / `X-Cache: HIT|MISS`、既存 `rt_*` 非破壊で維持。
- 出力形式: **Plan / Patch / Tests / KP** を必ず含める。
- 重要パス: `router/app.py`, `router/chat_cache_timeout.py`, `ops/monitoring/**`, `scripts/verify_chat_patch.sh`
- 実行の是非: 可逆なローカル検証はOK（uvicorn、promtool、jq）。外部公開・破壊系は **ask first**。
- 変更サイズ目安: ≤2ファイル / ≤80行（観測/テスト付き）。

## Devコマンド例
- Router検証:
  python3 -m uvicorn router.app:app --host 0.0.0.0 --port 8080
  curl -s :8080/metrics | grep -E 'rt_latency_ms_bucket|rt_cache_(hits|misses)_total'
- Prometheus: promtool check config <file> / promtool check rules <dir>
- Grafana: JSONは ${DS_PROMETHEUS} を使い、UIDはハードコードしない（ImportはUIで設定）。
