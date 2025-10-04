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
