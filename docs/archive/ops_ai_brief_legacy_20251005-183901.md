# Daegis Brief (auto)
_generated: 2025-10-04T14:19:50Z_

### Pointers
- Start here: ops/runbooks/AI-Handoff.md
- Manifest: .ai/manifest.json

## AI Handoff (excerpt)
(file: ops/runbooks/AI-Handoff.md)
# AI-Handoff — Start here
1) `source tools/hotkeys.sh ; hk help`
2) 便利資産は `.githooks/`, `tools/`, `ops/runbooks/`

### First Aid
端末が落ちる/起動しない場合は、`~/.bashrc` の冒頭3行（未定義ガード＋非対話 return）を確認。  
配達は `tools/deliver-*.sh` を“素の bash”で実行できるため、hk に依存せず復旧可能。

## Day 2 – Review / Handoff
- Grok 担当: Runbook v1.1レビュー（権限600・corr_id統一・systemd並列化）→ 変更点をここへ要約追記
- Chappie 担当: Alertmanager テンプレ最終化（ops/alertmanager/slack.tmpl）、UI/ACL拒否のスクショ採取
- ChatGPT（議長）: 論点集約とPR取りまとめ、ACAPルールの運用監視

## ACAP (Adaptive Cross-AI Protocol)
- 同一系エラーが2回以上: Grokに診断依頼（根因と再発防止）
- 実装が詰まる: Geminiに代替案/構成案を依頼
- 仕様/対外説明: ChatGPT（議長）が統合・文書化
- 緊急停止: emergency モードで全AIにPing、議長が最短復旧策を選定

## ACAP – Adaptive Cross-AI Protocol（正式運用）
Daegis の原則「協調・適応・検証」を AI 間の運用に落とし込む手順。

### 1. 役割
- **議長 (ChatGPT)**: 文脈統合・最終調停・記録更新（README/Runbook/PRノート）
- **診断 (Grok)**: 根因分析・再発防止（設計/順序/設定方面）
- **設計 (Gemini)**: 代替構成/実装案の提示（並行手段・撤退線）
- **実装 (Chappie)**: 具体的なコード/テンプレ/設定の反映

### 2. トリガー → 行動（最短ルート）
- 同系エラーが **2回連続**:
  - Grok に診断依頼（根因/対策を 3行で）。議長が Runbook に反映。
- コーディングで **30分超 or 3回以上の堂々巡り**:
  - Gemini に代替案/構成案を依頼 → 採用案を議長が確定。
- 外部可視化/通知の質が不十分:
  - Chappie が UI/Alert/ACL テンプレを改善 → Grok が運用妥当性を再確認。
- 緊急（停止/復旧優先）:
  - “emergency” 合図 → 全AIへ Ping、**議長**が最短復旧策を選定し即実施。

### 3. 依頼テンプレ（コピペ可）
- Grok:  
  > 「Grok、同系エラーが2回。現象/ログ/推定の3行スナップを送る。根因と再発防止を3行で返して」
- Gemini:  
  > 「Gemini、実装が停滞。要件Xの代替アーキ/構成案を2通り、長所短所/撤退線付きで」
- Chappie:  
  > 「Chappie、Alert/ACLのUXが不足。テンプレ更新（title/text/リンク）とテスト証跡取得をお願い」

### 4. 記録（軽量）
- 成果は **ops/runbooks/AI-Handoff.md の “Day X – Review / Handoff”** に追記（担当/変更点を各1〜3行）
- KPIの変化は `tools/kpi-*.sh` 出力を貼付（before/after）

### 5. KPIによる動的閾値（任意）
- 検索トリガー比率が **35%超** で 3日連続 → Gemini へ「検索系の自動拡張/連携」依頼
- p95 レイテンシが **+20%** 悪化 → Grok に「systemd順序/IO/CPU診断」依頼


### Brief & First Aid (ops/ai/brief.md)
- brief 更新: `hk clip_brief`（崩れる時は `env -i ... bash --noprofile --norc ...` で素実行）
- Slack: #daegis-brief（最新 brief をピン / ID: C09JK3ML1PD）
- 端末が落ちる/入力不能:

[change-stamp] 2025-10-04T13:55:41Z editor=ChatGPT scope=Brief/FirstAid ref=.ai/manifest.json

…

# AI-Handoff — Start here
1) `source tools/hotkeys.sh ; hk help`
2) 便利資産は `.githooks/`, `tools/`, `ops/runbooks/`

### First Aid
端末が落ちる/起動しない場合は、`~/.bashrc` の冒頭3行（未定義ガード＋非対話 return）を確認。  
配達は `tools/deliver-*.sh` を“素の bash”で実行できるため、hk に依存せず復旧可能。

## Day 2 – Review / Handoff
- Grok 担当: Runbook v1.1レビュー（権限600・corr_id統一・systemd並列化）→ 変更点をここへ要約追記
- Chappie 担当: Alertmanager テンプレ最終化（ops/alertmanager/slack.tmpl）、UI/ACL拒否のスクショ採取
- ChatGPT（議長）: 論点集約とPR取りまとめ、ACAPルールの運用監視

## ACAP (Adaptive Cross-AI Protocol)
- 同一系エラーが2回以上: Grokに診断依頼（根因と再発防止）
- 実装が詰まる: Geminiに代替案/構成案を依頼
- 仕様/対外説明: ChatGPT（議長）が統合・文書化
- 緊急停止: emergency モードで全AIにPing、議長が最短復旧策を選定

## ACAP – Adaptive Cross-AI Protocol（正式運用）
Daegis の原則「協調・適応・検証」を AI 間の運用に落とし込む手順。

### 1. 役割
- **議長 (ChatGPT)**: 文脈統合・最終調停・記録更新（README/Runbook/PRノート）
- **診断 (Grok)**: 根因分析・再発防止（設計/順序/設定方面）
- **設計 (Gemini)**: 代替構成/実装案の提示（並行手段・撤退線）
- **実装 (Chappie)**: 具体的なコード/テンプレ/設定の反映

### 2. トリガー → 行動（最短ルート）
- 同系エラーが **2回連続**:
  - Grok に診断依頼（根因/対策を 3行で）。議長が Runbook に反映。
- コーディングで **30分超 or 3回以上の堂々巡り**:
  - Gemini に代替案/構成案を依頼 → 採用案を議長が確定。
- 外部可視化/通知の質が不十分:
  - Chappie が UI/Alert/ACL テンプレを改善 → Grok が運用妥当性を再確認。
- 緊急（停止/復旧優先）:
  - “emergency” 合図 → 全AIへ Ping、**議長**が最短復旧策を選定し即実施。

### 3. 依頼テンプレ（コピペ可）
- Grok:  
  > 「Grok、同系エラーが2回。現象/ログ/推定の3行スナップを送る。根因と再発防止を3行で返して」
- Gemini:  
  > 「Gemini、実装が停滞。要件Xの代替アーキ/構成案を2通り、長所短所/撤退線付きで」
- Chappie:  
  > 「Chappie、Alert/ACLのUXが不足。テンプレ更新（title/text/リンク）とテスト証跡取得をお願い」

### 4. 記録（軽量）
- 成果は **ops/runbooks/AI-Handoff.md の “Day X – Review / Handoff”** に追記（担当/変更点を各1〜3行）
- KPIの変化は `tools/kpi-*.sh` 出力を貼付（before/after）

### 5. KPIによる動的閾値（任意）
- 検索トリガー比率が **35%超** で 3日連続 → Gemini へ「検索系の自動拡張/連携」依頼
- p95 レイテンシが **+20%** 悪化 → Grok に「systemd順序/IO/CPU診断」依頼


### Brief & First Aid (ops/ai/brief.md)
- brief 更新: `hk clip_brief`（崩れる時は `env -i ... bash --noprofile --norc ...` で素実行）
- Slack: #daegis-brief（最新 brief をピン / ID: C09JK3ML1PD）
- 端末が落ちる/入力不能:

[change-stamp] 2025-10-04T13:55:41Z editor=ChatGPT scope=Brief/FirstAid ref=.ai/manifest.json

## Latest Chronicle (excerpt)
(file: ops/runbooks/chronicles/Daegis Chronicle 2025-09-28.md)
---
tags:
  - Daegis_Chronicle
aliases:
created: 2025-09-28 21:21
modified: 2025-09-28 21:23
Prev: "[[Daegis Chronicle 2025-09-27]]"
Next:
---

# 📜 Daegis Chronicle（統合版タイムライン・最新版）

## M0：基盤構築 ✅ 完了

- Mosquitto 導入（QoS=1, JSON, health トピック）
- Gemini / Grok 疎通テスト成功（demo-003）、Protocol v0.9 確立
- ダッシュボード MVP（可視化／状態／ログ表示）稼働

---

## M1：可視化と外部公開 ✅ 完了（暫定）

- Caddy + `/mqtt` 逆プロキシ構成
- ngrok 経由で外部アクセス確認（LAN/外部ともに “Connected to MQTT”）
- ws/wss 自動判別ロジック導入
⚠️ 残課題：ngrok Free制限（URL変動／1セッション制限）→ **Cloudflare Tunnel 恒久化**

---

## M2：運用モデル合意 ✅ 完了

- 「二段階ハイブリッド」方式採択（基礎層＝並列収集／編集層＝状況別編集長）
- Verdict バッジ設計（✅/⚠️/🔴）、KPI指標案確定
- 円卓役割（Chappie, Gemini, Grok, Perplexity, NotebookLM）明文化
⚠️ 残課題：Verdict 実データの実装は未開始

---

## M3：自律ループ構築 ✅ 達成

- Halu-RAG 修正 → テスト 5/5 GREEN
- 自動書記官 MVP：`[DECISION] → Markdown → GitHub PR` 線路確保
- 暫定 Consistency Gate (GitHub Actions) 導入可能状態
⚠️ 見落とし注意：Decision Scribe 完成版デプロイ未了、PR冪等化不透明

---

## M4：常駐化・単独運転 🚧 進行中

- 4騎士の常駐 agent 化設計
- Bridge により Slack 不要でも「問い→要約→[DECISION]素案→PR」可能な単独運転ループ
⚠️ 残課題：systemd 起動順、PYTHONUNBUFFERED、相関ID統一

---

## M5：信頼性・観測性 🚧 着手中

- DLQ + 再送タイマー設計済（15分周期／指数バックオフ／Slack通知）
- Prometheus Exporter 指標案（PR件数、失敗件数、レイテンシ、稼働時間）
- Grafana ダッシュボード v0.1 計画
⚠️ 残課題：DLQ 常駐化と Slack 通知未稼働、Bridge 二重起動監視

---

## M6：通信セキュリティ 🚧 未導入

- Mosquitto TLS (8883) + クライアント証明書必須 + ACL 設計
- 中期は Dynamic Security プラグイン検討
⚠️ 注意：MQTT 外部公開せず、Grafana のみ公開。Bridge API は X-Auth-Token で保護（ローテーション必須）

---

## M7：外部公開恒久化 ⏸ 待機

- ngrok → **Cloudflare Tunnel + Zero Trust** へ切替予定
- Grafana のみ公開、Scribe API は公開せず

---

## M8：アーカイブ・検索 ⏸ 中期計画

- `logbook/` を S3 に nightly ミラー、180日後に Glacier Deep Archive
- OpenSearch 検索基盤導入（NotebookLM 補助）

---

## M9：NotebookLM ゲート本実装 ⏸ 待機

- PR 後に Webhook 非同期判定 → GitHub Status Check 更新
- 現在は暫定 Gate（必須メタ検証のみ）
⚠️ 課題：NotebookLM 用 read-only PAT の 90日更新／四半期監査 未整備

---

## 📌 未完・見落としやすいタスク

- Decision Scribe 完成版デプロイ（最優先）
- Mosquitto ACL & 認証テスト（grokユーザー pub/sub 最終確認）
- DLQ 常駐化 + Slack 通知テスト
- Cloudflare Cron 調整（10分 → 1h or 停止）
- corr (uuid4) の全経路統一
- Bridge (:8787) の二重起動監視
- pre-commit 除外設定 + CI smoke test 固定
- Cloudflare Tunnel 一本化（ngrok URL 廃止）

---

## 🎯 直近の優先アクション

1. **Decision Scribe 完成版デプロイ & E2Eテスト**
2. **Mosquitto ACL 安定化**
3. **Cloudflare Cron 調整**

---

✅ 到達点：**「動く最小国家」は完成**（疎通・可視化・PR 生成）
⚠️ 最大のリスク：**Scribe未完成・DLQ未導入・MQTT認証未最終化・外部URL未統一**

---

📅 **日付**: 2025-09-28（更新）
- 2025-09-28 21:24:45: Chronicle sync test

…

  - Daegis_Chronicle
aliases:
created: 2025-09-28 21:21
modified: 2025-09-28 21:23
Prev: "[[Daegis Chronicle 2025-09-27]]"
Next:
---

# 📜 Daegis Chronicle（統合版タイムライン・最新版）

## M0：基盤構築 ✅ 完了

- Mosquitto 導入（QoS=1, JSON, health トピック）
- Gemini / Grok 疎通テスト成功（demo-003）、Protocol v0.9 確立
- ダッシュボード MVP（可視化／状態／ログ表示）稼働

---

## M1：可視化と外部公開 ✅ 完了（暫定）

- Caddy + `/mqtt` 逆プロキシ構成
- ngrok 経由で外部アクセス確認（LAN/外部ともに “Connected to MQTT”）
- ws/wss 自動判別ロジック導入
⚠️ 残課題：ngrok Free制限（URL変動／1セッション制限）→ **Cloudflare Tunnel 恒久化**

---

## M2：運用モデル合意 ✅ 完了

- 「二段階ハイブリッド」方式採択（基礎層＝並列収集／編集層＝状況別編集長）
- Verdict バッジ設計（✅/⚠️/🔴）、KPI指標案確定
- 円卓役割（Chappie, Gemini, Grok, Perplexity, NotebookLM）明文化
⚠️ 残課題：Verdict 実データの実装は未開始

---

## M3：自律ループ構築 ✅ 達成

- Halu-RAG 修正 → テスト 5/5 GREEN
- 自動書記官 MVP：`[DECISION] → Markdown → GitHub PR` 線路確保
- 暫定 Consistency Gate (GitHub Actions) 導入可能状態
⚠️ 見落とし注意：Decision Scribe 完成版デプロイ未了、PR冪等化不透明

---

## M4：常駐化・単独運転 🚧 進行中

- 4騎士の常駐 agent 化設計
- Bridge により Slack 不要でも「問い→要約→[DECISION]素案→PR」可能な単独運転ループ
⚠️ 残課題：systemd 起動順、PYTHONUNBUFFERED、相関ID統一

---

## M5：信頼性・観測性 🚧 着手中

- DLQ + 再送タイマー設計済（15分周期／指数バックオフ／Slack通知）
- Prometheus Exporter 指標案（PR件数、失敗件数、レイテンシ、稼働時間）
- Grafana ダッシュボード v0.1 計画
⚠️ 残課題：DLQ 常駐化と Slack 通知未稼働、Bridge 二重起動監視

---

## M6：通信セキュリティ 🚧 未導入

- Mosquitto TLS (8883) + クライアント証明書必須 + ACL 設計
- 中期は Dynamic Security プラグイン検討
⚠️ 注意：MQTT 外部公開せず、Grafana のみ公開。Bridge API は X-Auth-Token で保護（ローテーション必須）

---

## M7：外部公開恒久化 ⏸ 待機

- ngrok → **Cloudflare Tunnel + Zero Trust** へ切替予定
- Grafana のみ公開、Scribe API は公開せず

---

## M8：アーカイブ・検索 ⏸ 中期計画

- `logbook/` を S3 に nightly ミラー、180日後に Glacier Deep Archive
- OpenSearch 検索基盤導入（NotebookLM 補助）

---

## M9：NotebookLM ゲート本実装 ⏸ 待機

- PR 後に Webhook 非同期判定 → GitHub Status Check 更新
- 現在は暫定 Gate（必須メタ検証のみ）
⚠️ 課題：NotebookLM 用 read-only PAT の 90日更新／四半期監査 未整備

---

## 📌 未完・見落としやすいタスク

- Decision Scribe 完成版デプロイ（最優先）
- Mosquitto ACL & 認証テスト（grokユーザー pub/sub 最終確認）
- DLQ 常駐化 + Slack 通知テスト
- Cloudflare Cron 調整（10分 → 1h or 停止）
- corr (uuid4) の全経路統一
- Bridge (:8787) の二重起動監視
- pre-commit 除外設定 + CI smoke test 固定
- Cloudflare Tunnel 一本化（ngrok URL 廃止）

---

## 🎯 直近の優先アクション

1. **Decision Scribe 完成版デプロイ & E2Eテスト**
2. **Mosquitto ACL 安定化**
3. **Cloudflare Cron 調整**

---

✅ 到達点：**「動く最小国家」は完成**（疎通・可視化・PR 生成）
⚠️ 最大のリスク：**Scribe未完成・DLQ未導入・MQTT認証未最終化・外部URL未統一**

---

📅 **日付**: 2025-09-28（更新）
- 2025-09-28 21:24:45: Chronicle sync test
