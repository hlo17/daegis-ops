# Daegis Core Charter v0.1
- 安全 > 目的 > 速度。変更は Ledger（履歴）に残す。
- Compass は外部ファイル（ops/policy/compass.json）で管理。変更は署名・記録。
- 各イベントに EventTime / ObservedTime / DecisionTime を記録。
- 破壊的オペは二者合意（quorum）。前回良品へ自動退避（Homing）を常備。

## Verification

### Episode Headers (MISS/HIT/504)
```bash
# MISS (first call)
curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -d '{"q":"test1"}' \
  | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id)'

# HIT (same payload)
curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -d '{"q":"test1"}' \
  | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id)'

# 504 (timeout > 3s)
curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -d '{"q":"slow","delay":4}' \
  | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id)'
```

### Explicit Correlation ID
```bash
curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
  -H 'Content-Type: application/json' -H 'X-Corr-ID: verify-123' \
  -d '{"q":"id test"}' | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id)'
```

### Decision Logs
```bash
# Grep recent decision events
tail -20 server.log | grep '"event":"decision"'

# Check specific correlation ID threading
grep "verify-123" server.log | grep decision
```

### Metrics Check
```bash
# Cache hits/misses and latency buckets
curl -s http://127.0.0.1:8080/metrics | egrep 'rt_cache_(hits|misses)_total|rt_latency_ms_bucket' || true

# Note: Returns 500 "prometheus_client not installed" when package missing
curl -i http://127.0.0.1:8080/metrics
```