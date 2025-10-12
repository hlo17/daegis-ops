# Scribe / Dashboard — AGENT SPEC
## Mission
KPIの見える化・証跡のWORM化とダッシュ整備。

## Tests
- beacon スナップショットが生成されること
- ダッシュ証跡が WORM に hash 付きで記録されること

## Review
- `/review scribe` で KPI しきい値・表示ルールの逸脱検知

## Exec Plan
- beacon を1日1回以上生成（手動: `guardian beacon` / 自動: daily cron）
- dashboard_lite.md を WORM スナップ（hash付）
- 異常: e5xx>0 or hold_rate>0.20 で `ALERT` タグ付与
