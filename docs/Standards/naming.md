# Naming Standard (Daegis)
- ルート: ~/daegis/{ops,docs,ark,projects,tools,poc,venv}
- サービス名: {領域}-{機能} 例) monitoring-prom, monitoring-grafana
- ホスト別設定: ops/hosts/<Hostname>/
- バックアップ: ark/backups/<topic>.<YYYYMMDD-HHMMSS>.tgz
- スナップ: snapshots/ か ark/logbook/ を利用
- 環境変数: ~/.config/daegis/.env.local（docker は ops/docker/.env → symlink）
