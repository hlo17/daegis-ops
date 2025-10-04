
## 開発環境ポリシー（Shell運用）
- updated: 2025-10-04T18:00:11Z
- principle: 実行は常に **bash --noprofile --norc -lc '…'**
- rationale: 完全な非対話・無菌環境で再現性を確保（AI生成コードを全マシンで同挙動に）
- interactive: 各自の軽量rcを許可（補完・履歴など最小限の快適性のみ）
- 禁止事項:
  - Starship等の重い初期化を自動起動に含めない
  - exit/return系トリガをrcに書かない
- 合言葉: 「**実行は素のbash、対話は好み**」が唯一の正

## 開発環境ポリシー（最終）
- updated: 2025-10-04T18:01:57Z
- **唯一の正**: 実行はつねに `bash --noprofile --norc -lc '…'`。対話は各自の**軽量rc**（重い初期化は不可）
- rationale: ローカル設定に依存しない**再現性**と**安定性**を担保
- 禁止: Starship 等の重い初期化の自動起動／rc内の exit/return トリガ／外部 eval
- 運用スニペット:
  - 直近ログ: `bash --noprofile --norc -lc 'ls -1t "/home/f/daegis/logs"/*.log 2>/dev/null | head -1 | xargs -r tail -n +1'`
  - スモーク: `bash --noprofile --norc -lc '"/home/f/daegis/tools/rt-smoke.sh"'`

### 実行テンプレ（コピペ可）
```bash
bash --noprofile --norc -lc '
  curl -fsS -X POST "http://127.0.0.1:8010/orchestrate"     -H "content-type: application/json" -d "{\"task\":\"daily test\"}" | jq -e .
'
```

### ヘルスチェック手順
1) **Roundtable**: /orchestrate に60連投 → 成功で [smoke-ok]  
2) **Mosquitto**: 127.0.0.1:1883 の LISTEN を確認  
3) **ログ**: `loglast` で直近 run の JSON を確認  

### トラブルシュート（抜粋）
- 退出トリガ疑い: `grep -nE "^[[:space:]]*(exit|return[[:space:]]+0)\b" ~/.bashrc || echo "[clean]"`
- GPG 非対話: `~/.gnupg` の perms 700/600、gpg.conf の `pinentry-mode loopback`

## Components (canonical)
- Core Agents → Halu, Grok, Perplexity, Gemini, ChatGPT, NotebookLM
- Interaction → Slack + (Halu Relay: OFF until Slack digest wired)
- Bus → Mosquitto :1883 (ACL=最小, WSS=OFF)
- Observability & Records → Prometheus, Alertmanager, Sentry, Logbook, Ledger, Ark
- Infrastructure → Raspberry, Caddy, Cloudflare Tunnel, Citadel

### Toggles (default)
Sentry=ON / WSS=OFF / ACAP=OFF / SlackDigest=OFF / HaluRelay=OFF

### Exec discipline
実行は常に `bash --noprofile --norc -lc '…'`。対話は軽量rc。logs/** は Git 管理外、dfsnap は REDACTED。

## Daegisプロジェクト全体像の再整理（2025-10-05）
**要約**: DaegisはAI騎士団を中心とした自律型情報処理システム。MQTT Busを神経系、Slackを円卓とする最小国家構想。進捗: M3完了、M4/M5進行中。弱点対処優先で、Halu Relay活性化を即時実施。  
Lexicon簡易版: Bus=メッセージ基盤、Ark=深層保管庫、ACAP=AI協調プロトコル。

### 次アクション（弱点対処・円卓開通）
- **即時(1h)**: Slack #daegis-roundtable 召集（ACAPテンプレ使用）。Halu Relay PoC再実行（MQTT→Slack）。
- **本日中**: ターミナルクリーンアップ（.bashrc最小化）と ACL 最小記述へ修正。
- **12時間内**: Alertmanager 貫通、Citadel P1（GPG注入）。
- **反省反映**: Runbookに「弱点レビュー章」追加、Obsidianに本整理を mdappend。

### 新規/拡張コンポーネント（セキュリティ・自動化強化）
- **watchdog + timers**: 監視・スケジュール（Sentry統合）🚧 → Observabilityへマージ
- **Daegis Ward**: Lint/Health ガード ✅（Docker経由）
- **Daegis Factory**: DAGタスク（plan→publish）🚧（Halu連携）
- **Daegis Citadel**: 秘密管理（P1: GPG）⏸
- **Daegis Ark**: ログアーカイブ（Merkle検証）⏸（30日後棚卸し）
- **Daegis Solaris/Luna**: ゲート/UI（Caddy/Tunnel）🚧（キャンバス統合）

> 依存: **Bus → Factory/Citadel**

### Daegis Memory Records（記憶）
- **Daegis Memory Core**: Logbook + Ledger（SSoT）✅（日次自動反映）
> 依存: **Scribe → Ark（長期保全）**

### Daegis Core Agents（中核）
- **Halu + (Halu Relay / Knowledge Engine)**: 議長・中継・RAG ✅/❌（Relay活性化優先）
> 依存: **Bus/Slack → 騎士団連鎖（Grok/Gemini等）**

### Daegis Infrastructure（基盤）
- **Raspberry Node**: 常駐ノード（systemd）✅
- **Bus/Mosquitto**: :1883 固定・ACL最小 ✅（新規追加統合）
- **Bridge/Tunnel/Caddy**: ゲート/トンネル/プロキシ 🚧
> 依存: **Node → 全コンポーネント**

### Daegis Observability（Sentry/Wardマージ）
- **Proactive Engine / Prometheus / Alertmanager / Grafana / Sentry** ✅/🚧（貫通テスト残）
> 依存: **Ward → Alertmanager（Slack通知）**

### Services & Tools（外部）
- **VS Code / GitHub / Docker / Cloudflare / OpenAI** ✅（Starship は⏸格下げ）
> 依存: **GitHub → Ledger/Runbook**

### Integration（外部連携）
- **Slack Integration**: 円卓UI（チャンネル群 + Relay bot）✅/❌（活性化鍵）
> 依存: **Bus → Core Agents**

### Vision Roadmap（M6-M9）
- **Sora / Zappie / ACAP**（M6:セキュリティ, M7:公開, M8:検索, M9:ゲート）⏸（新規ACAP統合）
> 依存: **全集大成 → 完全自動化**
