# Daegis Handoff — 20251002

## Scope & Audience
 **Scope**: Haluパイプライン（Broker→Relay→Scribe→Ledger/Slack）安定化・運用基盤整備（Sentry/Runbook/GitHub）。E2Eフロー（Mac→Pi→result publish）の確立と次フェーズ移行。端末連携（Mac実務/iPad発想）と通知貫通。
 **Audience**: 次担当・ChatGPT（引き継ぎ前提）。

## 現在完了
 **E2Eフロー確立**：Mac→(WSS/SSH)→Pi mosquitto→`gemini_runner.py`→`researchlistener.sh`→`runresearch.sh`→結果カードpublish。
 **常駐化**：`geminirunner.service` / `daegisresearchlistener.service` / `researchfactory.service` が稼働中。
 **安定化完了**：Mosquitto復旧、不可視文字クレンジング、JSON構文エラー根治、task_id抽出/ACK/DAG起動、reject通知経路。
 **運用基盤**：Sentry観測ハーネス（relayログ→Ledger待ち）、Scribe DEDUPE_OFF=1 dropin、Ledger id反映、Runbook自動埋め込み、GitHub push済（hlo17/daegisops）。
 **端末連携**：Mac=実務/検証、iPad=発想/会話。Universal Controlで並行作業。
 **PoC完了**: MacとPi間のエンドツーエンドワークフロー確立。承認メッセージ(approve/reject)がワーカーを起動し、結果を返す確認。
 **システム安定化**: researchfactory.service起動ループ、runresearch.sh JSONエラーなどPi側バグ解消。
 **Sentry（観測ハーネス）**: relayログ→購読フォールバック→Ledger待ち（再試行付き）でGO/NOGO判定。
 **Scribe**: DEDUPE_OFF=1 systemd dropin有効、起動ログ`DEDUPE_OFF=True`表示。
 **Ledger**: `answersYYYYMMDD.jsonl`にid反映・Sentry待ち確認。
 **Runbook**: `ops/runbooks/operations.md`にSentry自動埋め込み（BEGIN/ENDマーカー）。
 **GitHub**: `hlo17/daegisops`新設、Runbook/Notes/Sentry push済。
 **link_resolver.py**: `context_bundle.txt`生成フロー確立（新チャット引き継ぎ用）。
 **link_resolver.py**: `context_bundle.txt`生成フロー確立（新チャット引き継ぎ用）。

## 次にやる
 **通知貫通**: Alertmanager → Slack #daegisalerts（最低1イベント）。
 **Proactive PoC**: `up == 0`の即時通知（価値アラート）。
 **Scribe dedupe恒久化**: TTL/N分スコープ方式再設計。
 **DAG拡張**: ResearchFactory DAGのSynth/QAステージ実装。
 **AutoQA**: ルーブリック確定・スコア根拠ログ追加。
 **UI**: `daegis/ui/*`でresult/status Webカード常時表示。
 **Citadel設計**: 機密管理システム（鍵/シークレット集中管理）。
 **WSS購読/SSHトンネル運用定着**: Handoff/Opsに反映。
 **Runbook週次見直し**: Sentryブロック自動反映継続確認。

## 現在のリスク
 **topic名不一致**: `plan/req`などでワーカー無反応。
 **JSON壊れ**: listener側で弾かれる（`jq e .`必須）。
 **ACL/パスワード不整合**: 更新後再起動・権限確認徹底。
 **クォート崩れ**: zsh heredoc/SSH経由（Sentry安全版統一）。
 **重複判定**: PoC中DEDUPE_OFF=1のため恒久化必要。
 **連続作業貼り付け事故**: 「ブロック実行」ルール徹底。
 **実装フェーズ移行**: 新たな技術課題予測。


📌 **Status**: Orchestratorは「最小成功で流し続ける」方針に移行。ダイジェストは09:05定時、SlackはWebhook注入待ち。  
（直近: ok=2 / error=0, p95=Data insufficient(n=3)）

# Daegis Hand-off（最新版）

## 現在完了していること
- Roundtable Orchestrator
  - route_wrap + **mw_log** により `/orchestrate` の JSONL 追記が安定（1req=1行）。  
  - **no_proposals → 200 最小レス**のフォールバックで500断続を止血。  
  - `orchestrate.jsonl` に **status/latency_ms** を記録し、後続KPIに供給。
- Digest バッチ
  - `/usr/local/bin/rt-digest.sh` 実装（ok/error集計・p95算出、n<50は “Data insufficient”）。  
  - `rt-digest.service/timer` 導入、**09:05 + Persistent=true** で日次実行。  
  - 手動実行で出力確認済み。
- フィルタ/設定
  - 検索フィルタ JSON（`/etc/roundtable/search_filter.v1.json`）の **「出典」前スペースを修正**。  
  - 監視ノイズ低減のため `RT_DEBUG_ROUTES=0` を既定。

## 次にやること（優先順）
1. `/etc/roundtable/rt.env` に **SLACK_WEBHOOK_URL** を設定 → `systemctl restart rt-digest.timer`。  
2. **投稿チャンネル確定**（#daegis-roundtable / #daegis-alerts のどちらかに集約）。  
3. ログ件数が **n≥50** になり次第、p95 を定常評価に格上げ（グラフ化はその後）。  
4. 検索トリガー検出（allow/deny + ヒステリシス）を Digest 拡張へ統合。  
5. 仲裁/投票まわりの例外監視を継続（フォールバック長期稼働の健全性確認）。

## 現在のリスク
- **ログ件数不足**により p95 の統計的信頼性が未達。  
- **Slack Webhookの保管**は平文リスクあり → 所有者/権限制御（600/640）と `UMask=002`。  
- **フォールバック常用**は根治ではない → 投票/圧縮の upstream 改修計画を別途進行。

## Ops Quick Ref
- 手動Digest: `/usr/local/bin/rt-digest.sh`  
- タイマー: `systemctl status rt-digest.timer`  
- JSONL末尾: `grep -E '"source'[[:space:]]*:" /var/log/roundtable/orchestrate.jsonl | tail`

## DAG（監視フェーズ）
RT Agents → Orchestrator(/orchestrate) → **mw_log**(JSONL) → **digest.sh**(集計) → **systemd timer(09:05)** → Slack通知


## Snapshot（5行）
 **Sentry**: relayログ→購読フォールバック→Ledger待ち（再試行付き）GO/NOGO。
 **Scribe**: DEDUPE_OFF=1 dropin有効、ログ`DEDUPE_OFF=True`。
 **Ledger**: `answersYYYYMMDD.jsonl` id反映・Sentry待ち。
 **Runbook**: `ops/runbooks/operations.md` Sentry自動埋め込み。
 **GitHub**: `hlo17/daegisops` Runbook/Notes/Sentry push済。

## Active Tasks
 [ ] Alertmanager → Slack (#daegisalerts)最小1件貫通。
 [ ] Proactive Engine PoC: `up == 0`即時通知。
 [ ] Scribe dedupe恒久化（当日スコープ/TTL）、prededupe除去検討。
 [ ] Runbook週次見直し（Sentry自動反映継続）。

## 参照（主要ノート / 実装物）
 Runbook: `ops/runbooks/operations.md`, `ops/runbooks/commandexecutionguide.md`, `ops/runbooks/daegismap.md`
 Sentry: `ops/sentry/sentry.sh`
 共有: GitHub `hlo17/daegisops`
 監視系: Grafana（/grafana/ Caddy配下、Access経由）、Prometheus/Alertmanager（Slack配線中）、Caddy（/→/grafana/ 308回避、/health=200） 、Cloudflare Access（allowself優先）。

## Operational Notes
 **Terminal Hygiene**: ヒアドキュメント・SSH内シェル・多段クォート・長置換はブロック実行厳守。単発`export/chmod/bash n/systemctl/journalctl`は行ごとOK。
 **クォート規則**: 外側`"... "` / 内側`\"`。`'`必要時`'<lit>'"$VAR"'<'lit>'`。
 **Sentry使い方**: `sentry "テキスト"`（.zshrc関数済）。
 **WSS購読**: `npx mqtt subscribe h mqtt.daegisphronesis.com p 443 protocol wss t '<topic>' u factory P 'nknm'`
 **SSHトンネル（Mac→Pi 1883）**: `ssh N L 1883:127.0.0.1:1883 roundtable`
 **疎通テスト（Piローカル）**: `mosquitto_pub h 127.0.0.1 p 1883 u f P 'nknm' t 'daegis/test' m 'pong'`
 **映像連携**: USBC直結、給電別口（MagSafe/純正AC）分離（発熱低減）。
 **Universal Control**: 隣接配置＋Edge越え基本動作維持。不安定時: 同一Apple ID/WiFi/Bluetooth/Handoff ON、再起動→再ログイン。

Ops Quick Ref（運用ワンライナー）
    •    staging 起動＋待機＋スモーク：/tmp/staging_up_and_smoke.sh
    •    lint（インストール不要）：~/monitoringstaging/scripts/lint.sh
    •    docs 出力：source ~/daegis/ops/tools/mdio.sh ; mdput / mdappend
    •    構成表示：tree a I '.git|node_modules|__pycache__' L 3 ~/monitoringstaging
    •    端末連携：映像＝USBC直結／給電＝MagSafe等で分離（発熱低減）。Universal Controlは「隣接配置＋Edge越え」。不安定時：同一Apple ID・WiFi/Bluetooth/Handoff ON→再起動。
    
## ResearchFactory DAG 雛形（要約）
 入力: `daegis/factory/research/out`（runnerからの承認済みタスク）
 段階: `plan → fanout → synth → qa → publish`
 中間トピック: `<stage>/req` / `<stage>/res`（JSONスキーマはHandoff「DAG仕様」参照）
 失敗時: `daegis/status/research` に `{task_id, stage, reason, at}` をQoS1/retainで通知
 完了: `daegis/factory/research/result` にカードJSON（retain）



## 付録
## 付録: 運用メモ：実行ブロックの頼み方テンプレ

**どう頼めば一撃で用意できるか（定型フレーズ）**

### 1) 単一ファイルを“上書き”（mdput）
 「**Handoff を最新版で上書き。mdputブロックで返して**」
   保存先をObsidianにしたい → 「**Obsidian保管庫へ**」を付ける
   明示的なファイル名 → 「**`Daegis Handoff YYYYMMDD.md`へ**」

### 2) 単一ファイルに“追記”（mdappend）
 「**Ledger に以下を追記。mdappendブロックで返して**」
   追記本文を続けて貼る or 「**本文も生成して**」

### 3) 4ファイル一括（Handoff=上書き / Chronicle, Ledger, Map=追記）
 「**handoff/chronicle/ledger/map の4つ、Handoffは上書き・他は追記の実行ブロックを**」
   出力先（ローカル or Obsidian）も指示可

### 4) Pi 直実行（ユニット＋スクリプト配置→起動）
 「**Pi直実行版（ssh無・ローカル）の heredoc で、researchfactory.service と research_factory.py を配置＆起動するブロックを**」

### 5) SSH 経由で Pi に配布（Mac→Pi）
 「**ssh roundtable 'bash s' 形式で、<ファイルA>/<ファイルB> を配布＆ systemd reload→restart までやるブロックを**」

### 6) Ledger の“末尾日付→差分”を自動生成して追記
 「**Daegis Ledger.md** の末尾日付を抽出し、それ以降の確定事項を  
  `YYYYMMDD: 決定 — 一言の根拠` の行で出して。重複/撤回はマージ。」

### 7) WSS/トンネル/疎通テストの運用テンプレ
 「**WSS購読／SSHトンネル張る/切る／疎通テストのコマンド集を `Ops Notes.md` に追記する mdappend を**」

**ショートカット例**
 「**Handoff を最新版で上書き。mdputで**」
 「**Ledgerに今日ぶんを3行追記。mdappendで**」
 「**handoff/chronicle/ledger/map の4つ、Handoff上書き・他は追記の実行ブロックを**」
 「**Pi直：researchfactory.service と script の配置〜起動まで一撃ブロックを**」

## Ledger差分テンプレ（自動化プロンプト）
> 「**Daegis Ledger.md** の末尾日付を抽出し、それ以降の確定事項を  
> `YYYYMMDD: 決定 — 一言の根拠` の行で出して。重複/撤回はマージ。」

## チャット移行：初回メッセージテンプレ
 1通目：四文書の役割（Map/Chronicle/Handoff/Ledger）と運用原則の要約  
 2通目：**最新 Handoff 全文**（本ドキュメント）  
 3通目：**Ledger 直近差分（末尾日付→今日まで）**


## 運用メモ（2025-10-02）

- Daegis Docs 4本（Hand-off / Ledger / Chronicle / Map）は、構造を自動抽出できるよう最小整形を実施。
  - Ledger: 日付表記を `YYYY-MM-DD:` に統一。
  - Chronicle: M0〜M9 の章見出しを付与。
  - Hand-off: 「現在完了 / 次にやる / 現在のリスク」を必ず節として明示。
  - Map: 変更なし。
- 今後、`newchat handoff | pbcopy` で新チャット冒頭サマリーを生成する際、この構造を前提に自動抽出が行われる。
- サマリー化の中心は **Hand-off**。Ledger/Chronicle/Map は追記・更新のみを行い、統合時にHand-offへ吸い込む。
- 運用ルール：
  - **日常更新**: コピー → `⌃⌥⌘H` （または `handoff-update`）。
  - **新チャット移行**: `newchat handoff | pbcopy` → 冒頭に貼り付け。
  - **月末**: Ledger は30日超過部分をサマリー化し軽量化。
