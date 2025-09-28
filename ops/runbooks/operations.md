
---

# Alertmanager→Slack（確実版）
- Slack Webhook は `/etc/alertmanager/slack_webhook.url` に保存し、Alertmanager では `api_url_file` で参照する（YAML直書き禁止）。
- Prometheus→Alertmanager 配線:
  ```yaml
  alerting:
    alertmanagers:
      - static_configs:
          - targets: ['localhost:9093']

---

# Alertmanager→Slack（確実版）
- Slack Webhook は /etc/alertmanager/slack_webhook.url に保存し、Alertmanager では api_url_file で参照する（YAML直書き禁止）。
- Prometheus→Alertmanager 配線:
  alerting:
    alertmanagers:
      - static_configs:
          - targets: ['localhost:9093']
- Smoke テスト（即時発火/即収束）:
  1) global.evaluation_interval: 15s（テスト中のみ）
  2) /etc/prometheus/rules/always.yml（expr: vector(1), for: 0s）
  3) systemctl restart prometheus → Slack で firing を確認
  4) always.yml を削除 → resolved を確認
- 権限: /etc/prometheus/rules/*.yml は prometheus:prometheus（0644）

# Prometheus 設定事故からの復旧
- 症状: journalctl に "field evaluation_interval already set" などの YAML 二重定義。
- 手順:
  1) /etc/prometheus/prometheus.yml.bak.* から直近を復元、起動確認。
  2) 復元不可なら最小良形（alertmanagers / rule_files / scrape_configs を含む）へ置換。
  3) API チェック: /-/ready → /api/v1/rules → /api/v1/alerts。
- 既定権限: ルールは prometheus:prometheus で 0644。

# OS 別サービス管理
- Pi（Debian/Ubuntu）: systemd（systemctl）
- macOS: launchd（brew services / launchctl）
- 原則: 本番運用は Pi 上の systemd。Mac で systemctl は使わない。

# Sentry（観測ハーネス）メモ
- 使い方: sentry "<短い状況メモ>" で観測ログを残す（最小実装）。将来は Relay/MQTT 送信に置換。
- テンプレ: sentry "Alertmanager→Slack: smoke ok; switching to up==0 proactive"
- セキュリティ: Webhook を公開チャンネルや履歴で露出したら即ローテーションし、/etc/alertmanager/slack_webhook.url を置換後に `systemctl reload prometheus-alertmanager`。
- セキュリティ: Webhook を公開チャンネルや履歴で露出したら即ローテーションし、/etc/alertmanager/slack_webhook.url を置換後に systemctl reload prometheus-alertmanager。
