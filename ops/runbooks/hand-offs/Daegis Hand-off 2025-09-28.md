# Daegis Hand-off 2025-09-28

## Scope & Audience
- **Scope**: Haluパイプライン（Broker→Relay→Scribe→Ledger/Slack）安定化・運用基盤整備（Sentry/Runbook/GitHub）
- **Audience**: 次担当・ChatGPT（引き継ぎ前提）

## Next 48h Focus
- Alertmanager → Slack（#daegis-alerts）を1本貫通（最低1イベント）
- Proactive通知PoC：`up == 0` を即時通知する最初の価値アラート
- （余裕があれば）Scribeの**TTLベース重複抑止**の恒久化（当日スコープ or N分TTL）

## Known Risks / Watchlist
- 端末での**クォート崩れ**（zsh）→ Sentryは**安全クォート版**に統一
- 連続作業での**貼り付け事故** → “ブロック実行”ルールの厳守
- scribeの重複判定：PoC中は **DEDUPE_OFF=1**、恒久化は後段対応

## Snapshot（5行）
- **Sentry（観測ハーネス）**：relayログ→購読フォールバック→Ledger待ち（再試行付き）でGO/NO-GO判定
- **Scribe**：DEDUPE_OFF=1 を systemd drop-in で有効、起動ログに `DEDUPE_OFF=True` 表示
- **Ledger**：`answers-YYYYMMDD.jsonl` に id 反映・Sentryで待ち確認
- **Runbook**：`ops/runbooks/operations.md` に **Sentry本体を自動埋め込み**（BEGIN/ENDマーカー）
- **GitHub**：`hlo17/daegis-ops` 新設、Runbook/Notes/Sentry を push 済

## 直近の変更（確定）
- Sentry を**正式導入**（購読フォールバック＝安全クォート／`pat`方式）
- 実行粒度ルール（**ブロック実行 vs 行ごと**）を採用、クォート運用を標準化
- 文字化け対策（CRLF/BOM/ZWSP掃除＋`bash -n`）を固定手順化
- `ops/runbooks/*` と `ops/sentry/sentry.sh` 整備、`operations.md` に Sentry 自動同期
- GitHub リポ `daegis-ops` 作成、README と .gitignore 整備、push 完了
- `link_resolver.py` により `context_bundle.txt` 生成フローを確立（新チャット引き継ぎ用）

## Active Tasks
- [ ] Alertmanager → Slack (#daegis-alerts)：最小1件の貫通
- [ ] Proactive Engine PoC：`up == 0` の即時通知
- [ ] Scribe dedupe の恒久化（当日スコープ or TTL）、pre-dedupe除去の検討
- [ ] Runbook の週次見直し（Sentryブロック自動反映の継続確認）

## 参照（主要ノート / 実装物）
- Runbook: `ops/runbooks/operations.md`, `ops/runbooks/command-execution-guide.md`, `ops/runbooks/daegis-map.md`
- Sentry: `ops/sentry/sentry.sh`
- 共有: GitHub `hlo17/daegis-ops`
- 監視系（従来フェーズの継続管理）:
  - Grafana（/grafana/ サブパス/Caddy配下、Access経由）
  - Prometheus / Alertmanager（Slack配線作業中）
  - Caddy（/ → /grafana/ 308 ループ回避、/health=200）
  - Cloudflare Access（allow-self 優先、順序注意）

## Operational Notes
- **Terminal Hygiene**:
  - ヒアドキュメント・SSH内シェル・多段クォート・長置換は**ブロック実行**厳守
  - 単発の `export/chmod/bash -n/systemctl/journalctl` は**行ごとOK**
- **クォート規則**: 外側 `"..."` / 内側 `\"`。どうしても `'` が必要なら `'<lit>'"$VAR"'<'lit>'`
- **Sentry使い方**: `sentry "テキスト"`（`.zshrc` に関数済）

📌 **Status**: Haluパイプラインの観測・切り分けは安定。次は**通知の貫通**と**重複判定の恒久化**。
