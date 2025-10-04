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

