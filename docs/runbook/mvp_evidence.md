# Daegis OS MVP Evidence (YYYY-MM-DD)
- Smoke: MISS/HIT/504 ヘッダ抜粋（x-cache / x-corr-id / x-episode-id）
- SAFE: enable/disable ヘッダ差分（x-mode: SAFE）
- Decision Log: LOG_DECISION=0 タスクで無出力を確認
- Decision Ledger: 最新1行（episode_id, corr_id, decision_time, compass_version, event_time, observed_time, intent_hint）
- Alert Hints: :9091/api/v1/rules の hint 出力2本
