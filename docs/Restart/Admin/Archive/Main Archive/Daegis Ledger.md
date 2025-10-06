---
tags:
  - Memory_Records
aliases:
created: 2025-09-27 04:15
modified: 2025-10-04 00:20
Describe: "Decision Scribe、決定台帳: 判断や合意を“1行ずつ”追記していく一次原本（後でLogbook等に反映）"
Function: MQTT経由で流れてくる決定情報をMarkdown等に自動保存するロガー。Logbookと連携して「決定履歴」を確実に残す
Derivative from: "[[Master Map]]"
Export: python3 ~/daegis/ops/bin/mdput_clip.py "Daegis Ledger.md" --clean --from-clip
---

## Core & Naming (命名・体系整理)
- 2025-09-27: コンポーネント命名整理 — Mosquitto → Daegis Bus、Decision Scribe → Daegis Ledger、Raspberry Pi常駐 → Daegis Raspberry Node、監視カテゴリ → Daegis Observability。
- 2025-09-27: 情報体系を再編（Memory Records / Core Agents / Infrastructure / Observability / Services & Tools / Integration / Vision Roadmap / Daegis Lexicon）。
- 2025-09-27: ハンドオフ運用を確立（Daegis AI Handoff + Daegis Ledgerの2本柱）。
- 2025-09-28: Decision Frameに「迷ったらSentryで観測」「NOGO基準」を明文化。
- 2025-09-28: タスク欄を「Active Tasks」に統一。

## Infra & Monitoring (インフラ・監視)
- 2025-09-27: Grafanaを /grafana サブパスで本稼働、Cloudflare Access適用。
- 2025-09-27: Prometheus DataSourceを既定化、Infraダッシュボード整備。
- 2025-09-27: Caddy設定固定化（/grafana リバプロ、/health応答、rootリダイレクト無効）。
- 2025-09-27: Grafana admin パスワード強化。
- 2025-09-28: Alertmanager → Slack #daegisalerts 配線テスト成功。
- 2025-09-28: Prometheus 設定事故復旧。
- 2025-09-29: Mosquitto設定を最小化・復旧。passwd/ACL再生成。
- 2025-09-30: Mosquitto ACLに result/status を追加。
- 2025-10-02: Mosquitto再起動後の認証/ACL不整合を解消。

## Ops & Tools (運用・ツール)
- 2025-09-28: Sentry導入、Relay→Fallback→LedgerでGO/NOGO判定。
- 2025-09-28: 引用・クォート規則標準化、文字化け対策、Runbook体系整備。
- 2025-09-28: ops/sentry/sentry.sh 運用開始。GitHubリポジトリ hlo17/daegisops 初期化。
- 2025-09-29: gemini_runner.py 不可視文字除去、全.pyをクレンジング。
- 2025-09-29: researchlistener.sh を systemd 常駐化、ACK処理追加。
- 2025-09-30: runresearch.sh に resultカード生成とMQTT publish実装。
- 2025-09-30: gemini_runner.py systemd常駐化。UI factoryresult.html導入。
- 2025-09-30: SSHトンネル（Mac→Pi 1883）確立。researchfactory.service 常駐化。
- 2025-09-30: System Topology更新（Solaris/Luna/Ark編入）。
- 2025-09-30: E2Eワークフロー完成（Mac↔Pi）。
- 2025-10-02: staging_up_and_smoke.sh に env_file 検査追加。scripts/lint.sh 作成。
- 2025-10-02: Pi SSH恒常運用化。外部モニタの映像/給電分離。Mac+iPad併用ポリシー導入。Map v3.6更新。

## 月次サマリー (2025-09-30)
- Grafana/Caddy/Cloudflare Access による外部公開の最小構成確立。
- Prometheus + Grafana による可視化基盤整備。
- Daegis Bus（Mosquitto）導入と認証/ACL設定。
- 意思決定記録を Daegis Ledger に統合、ハンドオフ運用確立。
- Sentry観測ループ構築、Slack通知・GitHub・Runbook体制整備。

## 更新メモ
- 2025-10-02: Ledger統合・重複除去・月次サマリー追加。次アクション：Alertmanager Slack貫通恒久化、Scribe dedupe。
- 2025-10-03: Mosquitto起動成功・認証テスト完了。
- 2025-10-03: Citadel P1暗号化成功・公開鍵配布（keyid=36EBC7AE5C425521）。
- 2025-10-03: Halu Relay Event Subscriptions有効化、双方向中継テスト成功、halu_relay.py復旧。
- 2025-10-03: 円卓RT MVP接続・モック投票E2E成功。次アクション：Slack連携・実API結線。
- 2025-10-03: orchestrate.jsonl 拡張フィールド追記の _orch_log2 導入。
- 2025-10-03: no_proposals フォールバック＋ASGI mw_log 導入で観測安定化。
- 2025-10-04: rt-digest.sh / service / timer 導入（09:05定時配信）。search_filter.v1.json修正。
- 2025-10-04: RT_DEBUG_ROUTES=0 を既定化。Slack Webhookを環境変数注入方式へ統一。
/Users/f/daegis/docs/Daegis Ledger.md

## 2025-10-04 JST — Staging Compose 稼働ポート確定
- Prometheus (staging): http://<Pi>:9091
- Grafana (staging):    http://<Pi>:3001
- 方針: 踏み台(staging)は本番を一切変更しない。検証→PR→本番反映の順に固定。
- 影響範囲: 監視・可視化の動作検証は staging で実施。Alert/Provisioning は Git 管理下で差分管理。
### 2025-10-04 JST — Slash受け口 稼働
- 受け口: `POST https://<relay>/slack/roundtable`（stagingは `http://<Pi>:8123/slack/roundtable`）
- 役割: Slack Slash `/roundtable` → Roundtable `/orchestrate` 中継、結果を #daegis-roundtableへ投稿
- Service: `rt-slash.service`（venv運用）、Health: `/health`

2025-10-04: MQTT 認証/ACL修正 — 接続拒否を解消し、bot_oracle の publish/subscribe を許可。
2025-10-04: tell-*.sh 相関IDワンライナー採用 — デバッグと相関トレースを高速化。
2025-10-04: Oracle verdict モード導入 — 出力監査の一貫性確保。
2025-10-05: FastAPI slack2mqtt 導入/常駐 — Slack Slash を MQTT へブリッジ。
2025-10-05: Cloudflare named tunnel “bridge” — bridge.daegis-phronesis.com を FastAPI に終端。
2025-10-05: 評価スキーマ固定（✅/🛠/❌ + reason） — 集計と将来学習を前提に標準化。
2025-10-05: 短期方針決定：RAG→評価固定→来週LoRA — コスト最小で品質改善のループ開始。

