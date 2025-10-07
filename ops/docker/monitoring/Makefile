SHELL := /bin/bash
.RECIPEPREFIX := >
.PHONY: up down ps logs reload am-test

up:
> docker compose up -d
down:
> docker compose down
ps:
> docker compose ps
logs:
> docker compose logs -f --tail=200
reload:
> curl -s -X POST http://localhost:9090/-/reload || true
am-test:
> curl -s -X POST -H 'Content-Type: application/json' \
>  http://localhost:9093/api/v2/alerts -d "[{\"labels\":{\"alertname\":\"DaegisTestAlert\",\"severity\":\"info\"},\"annotations\":{\"summary\":\"Daegis monitoring stack test alert (via AM)\"},\"startsAt\":\"$$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}]" && echo

am-status:
> curl -s http://localhost:9093/api/v2/status | jq '.versionInfo.version, .config.original!=null, .config.original.route.receiver'

am-alerts:
> curl -s http://localhost:9093/api/v2/alerts | jq '.[].labels.alertname, .[].receivers'

am-silences:
> curl -s http://localhost:9093/api/v2/silences | jq '.[].status.state' | sort | uniq -c

prom-status:
> curl -s http://localhost:9090/-/ready && echo
> curl -s 'http://localhost:9090/api/v1/alerts' | jq '.data[].labels.alertname' || true
> curl -s 'http://localhost:9090/api/v1/rules'  | jq '.data.groups[].name'     || true
