# Daegis Monitoring — Runbook (SSoT)

> 本書は 2025-10-07/08 の初回オペノートを統合し、最新の構成・運用手順をまとめた正本です。
> 元資料: “Monitoring — 初回オペノート（2025-10-07）”, “Monitoring — 初回オペノート v1.1（2025-10-08）”.

## ステータス凡例 / 変更点（要約）
- Confirmed / Needs-Verify / Planned の粒度で整理（詳細は各章）。
- Router /metrics はプレーンテキスト返却で統一。router_up 追加、cost/tokens/cache 指標あり。
- Prometheus: router:8080 を scrape、Alertmanager(9094) 連携、Rules 読み込み。
- Alertmanager→Slack: `api_url_file` 方式で疎通確認済（テンプレ修正後に安定）。

## ふだんの確認コマンド
(…ここに “確認コマンド／壊れたら” を統合抜粋…)

## よくある落とし穴
(…host.docker.internal, ポート競合, Grafana パーミッションなど…)

## 次の一手・ペンディング
(…P95/5xx ルール、コストキャップ強制、Secrets化、MQTTハードニング等…)
