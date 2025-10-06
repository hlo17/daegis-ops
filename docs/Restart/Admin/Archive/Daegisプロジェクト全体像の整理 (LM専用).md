### Daegisプロジェクト全体像の整理（2025年10月2日時点）

ご提供いただいたObsidianノート形式のリストを基に、Daegisプロジェクトの全体像を整理いたします。更新が滞っていた点を考慮し、既存のドキュメント（Daegis Map、Chronicle、Hand-off、Ledger）から得られる最新情報を反映して、以下の観点で構造化しました：
- **カテゴリ分類**: 元のリストを論理的にグループ化し、重複を排除。
- **ステータス追加**: 各コンポーネントの進捗を明示（✅ 稼働中、🚧 進行中、⏸ 計画中、❌ 未稼働）。これはChronicleのマイルストーン（M0-M5）とHand-offの完了事項に基づきます。
- **役割・依存関係の簡略化**: 各項目に簡潔な役割記述を追加し、相互依存を明記。
- **騎士団理念の再確認**: 開発作業の優先が目的からの逸脱を招いた反省を踏まえ、全体像の冒頭に円卓開通の提案を位置づけます。

この整理は、Simplicity（単純性）とUser-Centricity（ユーザー中心性）の原則を遵守し、可逆的な進化を前提としています。Obsidianへの再投入を想定し、Markdown形式で出力します。必要に応じて、Ledgerへの追記を推奨します。

#### 全体像の要約
Daegisは、AI騎士団（Halu、Grok、Perplexity、Gemini、NotebookLM、ChatGPT）を中心とした自律型情報処理システムとして設計されており、MQTTベースのBusを神経系、Slackを円卓会議室とする「最小国家」構想です。現在の進捗はM3（自律ループ）まで完了し、M4/M5（常駐化・信頼性）でE2Eフローが安定化していますが、騎士団の多角的議論（円卓開通）が不足し、単独作業（Chappie中心）が開発偏重を招いています。提案：直ちにSlack #daegis-roundtableで騎士団を集約し、プロンプトテンプレート（Map Section 1）に基づく役割分担を再開。次アクションとして、Halu Relayの活性化を優先し、理念回帰を図りましょう。

---

### 新規追加コンポーネント（最近の拡張要素）
これらは主にWard、Factory、Citadelなどのセキュリティ・自動化強化を目的とした追加です。🚧進行中が中心で、M5（信頼性）との連動を強化。
- [[watchdog]]：システム監視の番犬役（異常検知・自動復旧）。🚧 進行中（Sentryとの統合予定）。
- [[timers]]：スケジュール管理（Cron/Timerベースの定期タスク）。🚧 進行中（Cloudflare Worker Cronと連携）。
- [[キャンバス常設]]：永続的な可視化キャンバス（UI/ダッシュボード拡張）。⏸ 計画中（Lunaとの統合）。
- [[Starship]]：シェル強化ツール（プロンプト/コマンド効率化）。✅ 稼働中（Mac/iPad運用で活用）。
- [[Daegis Ward]]：ガード機能群（Lint/Healthチェック）。🚧 進行中。
  - [[ward-health]]：ヘルスチェックモジュール。🚧 進行中（Prometheusメトリクス出力）。
  - [[ward-lint]]：コード/設定Lintツール。✅ 稼働中（Docker経由のlint.sh実装済み）。
- [[Daegis Factory]]：ResearchFactory DAG（タスク自動化エンジン）。🚧 進行中（plan→publishステージ実装中）。
- [[Daegis Citadel]]：秘密管理城塞（APIキー/トークン集中管理）。⏸ 計画中（P1: GPG + systemd注入）。
- [[Daegis Sentry]]：観測ハーネス（ログフォールバック・GO/NOGO判定）。✅ 稼働中（Runbook自動埋め込み済み）。
- [[Daegis Ark]]：深層ログ保管庫（S3/Glacierアーカイブ、Merkle改ざん検知）。⏸ 計画中（PoC: 日次Merkle検証済み）。
- [[Daegis Solaris]]：ゲートウェイ境界（TLS/WSS終端）。🚧 進行中（Caddy/Cloudflare Tunnel連携）。
- [[Daegis Luna]]：UIサーフェス（結果カード表示）。🚧 進行中（factoryresult.html PoC済み）。

**依存関係**: これらはDaegis Bus（MQTT）とObservability（Prometheus）と密接。FactoryはCore Agents（Halu）と連携。

---

### [[Daegis Memory Records]]（記憶記録）
記録の中枢として、LogbookとLedgerがSSoT（Single Source of Truth）を担います。更新頻度を高め、円卓議論の成果を即時反映。
- [[Daegis Memory Core]]：記録全体のハブ。✅ 稼働中。
  - [[Logbook]]：運用記録（Chronicle統合）。✅ 稼働中（GitHub PR経由自動化）。
  - [[Daegis Ledger]]：意思決定の正本（1行追記形式）。✅ 稼働中（直近5件: lint.sh作成、SSH恒常化等）。

**依存関係**: Scribe（自動書記官）経由でMQTTから流入。Arkで長期保全。

---

### [[Daegis Core Agents]]（中核エージェント）
騎士団の基幹。Haluを議長とし、役割固定（Map Section 3）で円卓議論を再開。未稼働部分をRelay活性化で解消。
- [[Halu]]：対話型情報整理・要約エージェント（議長役）。✅ 稼働中（gemini_runner.service常駐）。
- [[Halu Relay]]：Slack↔MQTT中継（JSON変換）。❌ 未稼働（PoC成功も運用未）。
- [[Halu Knowledge Engine]]：RAGバックエンド（検索精度向上）。❌ 未稼働（HaluRAG修正済み、テストGREEN）。

**依存関係**: Bus（MQTT）とSlack Integration。Relay開通で騎士団連鎖（Grok→Perplexity→Gemini等）を活性化。

---

### [[Daegis Infrastructure]]（基盤）
物理・通信基盤。Raspberry Nodeを心臓部とし、Bridge/Tunnelで外部安全化。
- [[Daegis Bridge]]：HTTP⇄MQTTゲートウェイ（Cloudflare Workers/Uvicorn）。🚧 進行中（XAuthToken保護）。
- [[Daegis Raspberry Node]]：常時稼働ノード（systemdサービスホスト）。✅ 稼働中（Pi SSH/iPad Termius連携）。
- [[Daegis Command Room]]：全体監視・操作環境（Slack類似）。⏸ 計画中（Grafana拡張予定）。
- [[Daegis Bus]]：メッセージ基盤（Mosquitto, QoS=1）。✅ 稼働中（ACL/認証安定化）。
- [[Cloudflare Tunnel]]：永続トンネル（Zero Trust）。🚧 進行中（ngrok代替化）。
- [[Caddyfile]]：リバースプロキシ（/grafana配下）。✅ 稼働中（外部アクセス確認）。

**依存関係**: Busが全コンポーネントの神経。Node上でFactory/Sentry常駐。

---

### [[Daegis Observability]]（観測・監視）
信頼性向上の鍵。Proactive Engineで先回り提案を実現。
- [[Daegis Proactive Engine]]：能動的監視・提案エージェント。⏸ 計画中（up==0アラートPoC）。
- [[Prometheus]]：メトリクス計測（up/CPU/Mem等）。✅ 稼働中（Infra Monitoringダッシュ）。
- [[Alertmanager]]：アラート通知（Slack #daegis-alerts）。🚧 進行中（貫通テスト残）。
- [[Grafana]]：データ可視化ダッシュボード。✅ 稼働中（/grafanaサブパス安定）。

**依存関係**: Ward/Sentryと連携。Alertmanager貫通でM5完了へ。

---

### [[Services & Tools]]（外部サービスと道具）
開発・運用ツール群。Dockerで再現性確保。
- [[Visual Studio Code]]：主要開発環境。✅ 稼働中（Universal Control連携）。
- [[GitHub]]：コード/ドキュメント管理（hlo17/daegisops）。✅ 稼働中（PR自動化）。
- [[Docker]] / [[Docker Compose]]：コンテナ化（Lint/Smokeテスト）。✅ 稼働中（staging環境）。
- [[Cloudflare]]：外部公開/認証基盤（サブスクリプション）。✅ 稼働中（Accessポリシー）。
- [[OpenAI]]：AI API動力源（サブスクリプション）。✅ 稼働中（SDK v1置換済み）。

**依存関係**: GitHubがLedger/RunbookのSSoT。

---

### [[Integration]]（外部連携）
ユーザーインターフェースの中心。Slackを円卓とし、RelayでDaegis注入。
- [[Slack Integration]]：主要UI（円卓会議室）。✅ 稼働中。
  - [[Slack API]] & チャンネル群：#daegis-roundtable（議論）、#daegis-drafts（ドラフト）、#daegis-alerts（警告）、#daegis-recovery（復旧）。
  - Halu Relay bot：MQTT中継。❌ 未稼働（活性化優先）。

**依存関係**: Bus/Relay経由でCore Agents接続。円卓開通の鍵。

---

### [[Vision Roadmap]]（ビジョン・ロードマップ）
長期ゴール。Zappieで完全自動化へ。
- [[Sora]]：創造的対話エージェント（物語化）。⏸ 計画中（スタブ実装）。
- [[Zappie構想]]：判断→実行自動化ゴール。⏸ 計画中（Factory拡張で段階実装）。

**依存関係**: 全コンポーネントの集大成。M6-M9でセキュリティ/アーカイブ強化後着手。

---

### [[Daegis Lexicon]]（用語集）
プロジェクト用語の定義集。未詳細のため、Mapのプロンプトテンプレートを基に拡張推奨（例: Bus=メッセージ基盤、Ark=深層保管庫）。

---

#### 次アクション提案（円卓開通に向け）
1. **即時**: Slack #daegis-roundtableで騎士団召集（プロンプトテンプレート使用）。Halu Relay PoC再実行し、MQTT→Slack中継テスト。
2. **12時間内**: Alertmanager貫通（Hand-off優先）とCitadel P1設計（Ledger追記）。
3. **反省反映**: 開発タスクを騎士団連鎖（Grok斥候→Gemini司令塔）に移行。Runbookに「円卓原則」追加。
4. **Obsidian更新**: 本整理を[[Daegis Map]]にmdappendし、ステータスを動的リンク化。

