# 📜 Daegis Map — unified v3.7（秘書型エンジン＋役割分担・統合版）
**title**: "📜 Daegis Map — unified v3.7"  
**modified**: 2025-10-04  
**note**: v3.6を再編。**恒久レイヤ（Map）**と**運用規範（Guidelines）**を分離し、境界面・責務・RACIを明確化。/orchestrate の“最小成功”原則・観測キー契約・Slack集約を恒久ルールとして固定。

> 原則：**Map＝恒久ルール（境界・責務・RACI）**、閾値やワンライナーは **Guidelines/Ops Notes** 側へ。  
> AIが**ルール追記が必要**と判断した場合、**回答末尾に追記提案（対象ファイル明記）**を付す。

---

## 0) Guiding Principles & 現在地
1. **Simplicity**：最小構成を優先。複雑化は最後。  
2. **User-Centricity**：マスターの認知負荷最小化。  
3. **Evolution**：可逆・小さな変更の連続。

**レイヤ位置**: L4 騎士団（役割固定） ↔ L5 司令室（Slack集約）  
**進捗**: M3 自律ループ✅ / M4 常駐化🚧 / M5 信頼性🚧 / M6 セキュリティ（未）  
**直近フォーカス（12h）**: ①秘書型7行報告の定着 ②/​orchestrate 観測・最小成功 ③Slack集約

---

## 1) Boundary（恒久の境界面）
- **FastAPI** `/orchestrate`（POST）  
  - **ASGI middleware（mw_log）**：毎リクエストで JSONL 追記（source=`"mw_log"` / keys: `ts,source,status,latency_ms,task,coordinator,arbitrated.summary_len`）。  
  - **route_wrap**：ハンドラを包み込み、**最小成功**で流す（握り潰さない）。  
  - **orchestrate_patch**：仲裁・投票の本流。  
- **診断ルート**：`/rt_routes`, `/rt_patch_alive`, `/health`（RT_DEBUG_ROUTES≠本番）。  
- **Slack Webhook**  
  - `#daegisalerts`（アラート＝**だいじ**）  
  - `#daegisaidrafts`（ドラフト集約）  
  - `#daegisroundtable`（周知・決定共有）  
- **Timer → Service**：`rt-digest.timer` → `rt-digest.service` → **Digest投稿（任意）**。  
- **Observability**：Prometheus / Grafana / Alertmanager（Slack）。

---

## 2) Responsibilities（恒久の責務）
- **最小成功の担保**：`orchestrate_patch` / `route_wrap`（`no_proposals` 等は 200+最小レスで流す）。  
- **観測ログの一元化**：`mw_log` が `/var/log/roundtable/orchestrate.jsonl` に追記（契約キー固定）。  
- **Slack 集約**：ドラフト→`#daegisaidrafts`、警報→`#daegisalerts`、共有→`#daegisroundtable`。  
- **Secrets/設定のSSOT**：**systemd drop-in**（`/etc/systemd/system/<unit>.d/override.conf`）。`.env`は参照のみ。  
- **Ledger/Chronicle 更新**：**決定はLedger**、時系列はChronicle、**Hand-offは常に上書き**。

---

## 3) RACI（恒久）
- **A（承認）**：Master  
- **R（実行）**：Gemini（司令塔）、ChatGPT（実装）  
- **C（助言）**：Perplexity（検証）、NotebookLM（整合監査）  
- **I（共有）**：Grok（斥候）  
- **承認表記**：🟢承認 / 🟡保留 / 🔴差戻し（Slackで明示）

---

## 4) Roundtable Roles（固定役割・標準連鎖）
- **Grok（斥候＋鍛冶屋補助）**：最新論点≤5件＋一次ソース名、簡易PoC断片。  
- **Perplexity（検証官）**：出典付き比較（3案×長短所×採用基準）。  
- **Gemini（司令塔）**：意思決定案（推奨1／代替1／保留1）。  
- **NotebookLM（記憶の番人）**：整合OK/NG＋抵触箇所（Ledger/Map）。  
- **ChatGPT（鍛冶師・実装）**：実装前チェックリスト（環境/権限/依存/実行粒度）。  
**標準連鎖**：Grok → Perplexity → Gemini → NotebookLM → ChatGPT（`#daegisaidrafts` に集約）。

---

## 5) Operating Topology（恒久）
Client → Caddy/Proxy → FastAPI(/orchestrate)
└─ ASGI mw_log → route_wrap → orchestrate_patch → arbitrator
└→ JSONL (/var/log/roundtable/orchestrate.jsonl)
Timer(rt-digest.timer) → rt-digest.service → Slack(#daegisroundtable)
Prometheus → Alertmanager → Slack(#daegisalerts) → (Halu Relay 再開時 L5集約)

---

## 6) Security & Config（恒久）
-　**MQTT**：外部直公開しない（WSS経由のみ）。最小権限ユーザ（`f`,`factory`）。将来＝TLS/8883＋ClientCert。  
- **systemd**：`UMask=002`、ログは 0664、`/var/log/roundtable` は 0775（グループ共有）。  
- **Tokens**：Bridge/API は XAuthToken 必須（ローテーション前提）。  
- **Data**：PII/資格情報は**保存しない**。30日越えは要約化→Ark（S3/Glacier）へ。

---

## 7) “最小成功” & 観測キー契約（恒久）
- **最小成功**：`status:"ok"` / `arbitrated.summary_len:0` / `note:"fallback:no_proposals"` を返すパスを常備。  
- **キー契約（JSONL 不変）**：`ts, source, status, latency_ms, task, coordinator, arbitrated.summary_len`。  
- **Digest 既定**：N=400、n<50 は `Data insufficient (n=…)` と明記（Slack文言は Guidelines 側）。

---

## 8) ResearchFactory（恒久スキーマ）
- **段階**：`plan → fanout → synth → qa → publish`  
- **I/O トピック**：`daegis/factory/research/<stage>/{req|res}`  
- **メッセージ基底**：  
  - `task_id`（相関ID, 必須）  
  - `stage`（列挙）  
  - `payload`（段階依存）  
  - `meta {by, ts}`  
- **失敗通知**：`daegis/status/research`（QoS=1/retain）。  
- **完了通知**：`daegis/factory/research/result`（カードJSON, QoS=1/retain）。

---

## 9) Slack 集約設計（恒久）
- **無料枠**：`#daegisaidrafts` 集約 → Slack AI 一次要約 → NotebookLM 整合。  
- **有料化後**：Zapier/Make で「集約→一次要約→整合→戻し」を自動化。  
- **Webhook**：用途で分離（Alerts＝`#daegisalerts`、Digest/共有＝`#daegisroundtable`）。

---

## 10) Terminal Hygiene（恒久）
- **ブロック必須**：多段クォート/長置換/ヒアドキュメント/複合パイプ/リモート実行。  
- **行ごとOK**：`systemctl status`, `journalctl ... | tail`, `export`, `chmod`, `bash n`。  
- **JSON渡し**：外側 `"..."`、内側 `\"`、または `printf | jq -n`。  
- **切り分け順**：Sentry → Relay tail → Scribe → Ledger → Slack permalink。

---

## 更新メモ
- **v3.7（2025-10-04）**：  
  - **最小成功＋観測キー契約**を恒久化。  
  - **Boundary/Responsibilities/RACI** を Map に固定。  
  - Slack集約の**用途別チャンネル**を常設化。  
  - v3.6 の「円卓原則」を Map へ要約統合、詳細テンプレは **Guidelines v0.4** 側に移管。
- **v3.6（2025-10-02）**：円卓原則の正式化、役割再定義（Grok斥候＋鍛冶補助／ChatGPT実装専任）。

---

### 追記提案（対象：**Daegis Guidelines v0.4**）
- 「Daily Digest 文言」「Perplexity Trigger allow/deny JSON」「p95計算ロジック」「Webhook運用（alerts/roundtable）」は**Guidelines**に集約。Mapは境界・責務・RACIのみ維持。


4) Map（恒久ルールの更新）
    •    原則：Adaptive Hybrid Pool を中核に据える（基本ローカル、難問のみ外部“先生”を限定投入、最終は Oracle verdict で締める）。
    •    恒久役割：
    •    Halu＝初期方針3行（RAGで根拠注入）
    •    Oracle＝評価ゲート（✅/⚠️/❌）＋合意形成
    •    Slash/FastAPI＝運用入口の既定面
    •    統一フォーマット：
    •    生成出力：{policy, risks, next, sources[], confidence}
    •    評価保存：{id, agent, label(✅/🛠/❌), reason, ts, user}
    •    verdict：{id, agent:"oracle", mode:"eval", verdict(✅/⚠️/❌), reasons[], ts}
