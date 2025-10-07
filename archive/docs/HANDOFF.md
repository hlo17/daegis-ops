### 2025-10-07
- Pi: mosquitto 正常化（単一 listener, ACL/password 適用）
- Pi: `halu-runner.service` 稼働。inbox→outbox エコー、UTC ISO8601。
- Pi: `backup-halulog.timer` 03:15Z-9 実行、成果物は `snapshots/archive/halu-logs-*.tar.gz`。
- Mac: compose 側 AM=blackhole、Prometheus/Grafana 再接続は次タスク。
- Pi: `backup-halulog.timer` 有効、成果物は `snapshots/archive/halu-logs-*.tar.gz`
- Pi: `REGISTRY.yml` 登録（mqtt/halu_runner/backup）
