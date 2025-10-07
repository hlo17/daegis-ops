
# workflow trigger test
## Lessons learned — HALU 5min loop (2025-10-06)
- スクリプト破損・短文コーパス・CPU停止で不安定化。Slack未配線の404はノイズ。
- 直し：短文耐性＆CPU制御の学習、KPI安全集計、systemd外の手動一周で健全性確認。
- 再現/確認（Quick verify）:
  ~/daegis/tools/rt-digest-exec.sh && \
  jq . ~/daegis/tools/halu_5min_model/metrics.json && \
  tail -n 20 ~/daegis/records/dashboard.md && \
  ls -lh ~/daegis/records/kpi.png
