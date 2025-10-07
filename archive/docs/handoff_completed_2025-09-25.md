# 引き継ぎメモ v2.0

## 1. 概要
Raspberry Pi中心の多層構成。Mosquitto (MQTT), Caddy (Edge), Grafana/Prometheus (可視化/監視), Slack (通知), GitHub Actions (CI)。層は L1〜L6。

## 2. 監視/可視化
Daegis Health ダッシュボード常時稼働。Prometheus からメトリクス収集。ダッシュボードは永続化済み、Nightly Smoke & Gate を main 監視に導入予定。

## 3. 知識・同期
Obsidian Vault と GitHub を連携。日次 md を logbook 配下に保存し、CIでLint/メタチェック。必要に応じて Slack へ [DECISION] を連携。

## 4. 決定事項
- [DECISION] ここに箇条書き

## 5. メタデータ
- generated_by: system
- consistency_check: pending
- category: handoff
