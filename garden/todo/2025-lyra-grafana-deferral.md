# Lyra / Grafana 可視化は安定化後に一括構築する（Deferral）
status:: open
tags:: daegis, lyra, grafana, ops, decision
created:: {{date}}

## 背景
- Exporter → Prometheus の配管は完了
- `lyra_mode_last`, `lyra_mode_is_active` などの系列は取得済み
- ダッシュボード調整に時間をかけず、**観測層の信頼性**を先に固める

## やること（チェックリスト）
- [ ] `lyra_mode.prom` の更新間隔の監視（node_exporter textfile 経由）
- [ ] `LyraNoSamples` アラートの発火テスト（意図的に停止→検知）
- [ ] Rule group `lyra`, `lyra_more`, `lyra_alerts` の健全性チェック
- [ ] Grafana 一括投入スクリプト（curl /api/dashboards/db）雛形をGit化
- [ ] 安定化後、Factory テンプレ（Jinja2 等）で Lyra ダッシュボードを自動生成

## メモ
- 現状パネル "Current Mode" は `topk(1, lyra_mode_last == 1)`（instant）
- Prometheus DS は 9090 を参照
