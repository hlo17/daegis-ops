# Daegis Brief (auto)
_generated: MANUAL_COPY_

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
- Grok: Runbook v1.1レビュー（権限600・corr_id統一・systemd並列化）→ 変更点を要約追記
- Chappie: Alertmanager テンプレ最終化（ops/alertmanager/slack.tmpl）、UI/ACL拒否のスクショ採取
- ChatGPT（議長）: 論点集約とPR取りまとめ、ACAPルールの運用監視

## ACAP – Adaptive Cross-AI Protocol（正式運用）
Daegis の原則「協調・適応・検証」を AI 間の運用に落とし込む手順。

### 1. 役割
- **議長 (ChatGPT)**: 文脈統合・最終調停・記録更新（README/Runbook/PRノート）
- **診断 (Grok)**: 根因分析・再発防止（設計/順序/設定）
- **設計 (Gemini)**: 代替構成/実装案（並行手段・撤退線）
- **実装 (Chappie)**: 具体的なコード/テンプレ/設定反映

### 2. トリガー → 行動
- 同系エラー **2連続** → Grokに3行診断 → 議長がRunbook反映  
- 実装が **30分超/3回** 詰まり → Geminiへ代替案依頼 → 議長が採用確定  
- 可視化/通知の質不足 → ChappieがUI/Alert改善 → Grokが運用妥当性再確認  
- 緊急停止 → “emergency” → 全AIにPing、議長が最短復旧策を即決

### 3. 依頼テンプレ（コピペ可）
- Grok: 「同系エラーが2回。現象/ログ/推定の3行。根因と再発防止を3行で。」
- Gemini: 「実装停滞。要件Xの代替アーキ/構成案を2通り、長所短所/撤退線付きで。」
- Chappie: 「Alert/ACLのUX不足。title/text/リンクのテンプレ更新とテスト証跡取得を。」

### 4. 記録（軽量）
- **ops/runbooks/AI-Handoff.md** の “Day X – Review / Handoff” に担当/変更点（各1〜3行）  
- KPI変化は `tools/kpi-*.sh` の出力を貼付（before/after）

### 5. KPIの動的閾値（任意）
- 検索トリガー比率 **>35% ×3日** → Gemini に検索系拡張依頼  
- p95 レイテンシ **+20%** → Grok に systemd順序/IO/CPU診断依頼
