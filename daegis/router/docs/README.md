# Daegis Router
- /metrics (Prometheus text format)
- /chat (ping)
Metrics: requests/latency/tokens/cost/cache/daycap

## Run
docker compose -f daegis/router/compose.yaml up -d --build

## Check
curl -fsS http://localhost:8080/metrics | head
