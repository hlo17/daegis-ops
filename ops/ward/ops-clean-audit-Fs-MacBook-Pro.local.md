# Ops Clean Audit (Fs-MacBook-Pro.local)
- when: 
- root: /Users/f/daegis

---

## A) ops/docker
### files
- docker-compose.override.yml
- docker-compose.yml

### grep(.env/secret) ※残っていたら要手動確認

---

## B) ops/monitoring
### alertmanager/
- ./alertmanager.yml.bak.1758702183
- ./secret/slack_webhook_url
- ./alertmanager.yml
- ./alertmanager.yml.tmpl

### prometheus/
- ./alerts_latency.yml
- ./rules/daegis-alerts.yml
- ./prometheus.yml

### grafana/
- ./dashboards/daegis.json
- ./dashboards/dashboards.yml
- ./grafana_data.tgz


---

## C) logs (top size)
     72K	.

- halu.log present

## D) junk candidates
_none_

## E) stale refs (halu-dev)
    /Users/f/daegis/docs/Restart/README.md:3:[![Smoke & Gate](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml/badge.svg)](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml)
    /Users/f/daegis/docs/Restart/README.from-halu-dev.md:3:[![Smoke & Gate](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml/badge.svg)](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml)
    /Users/f/daegis/logs/halu.log:3:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   About an hour ago   Up 11 minutes                0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:4:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        About an hour ago   Up 32 minutes                0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:5:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           About an hour ago   Up About an hour             
    /Users/f/daegis/logs/halu.log:6:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        About an hour ago   Up About an hour             
    /Users/f/daegis/logs/halu.log:7:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      About an hour ago   Up About an hour (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:8:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     About an hour ago   Up 11 minutes                0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:12:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up 2 minutes           0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:13:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up About an hour       0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:14:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:15:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:16:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:17:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up 59 minutes          0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:21:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up About a minute      0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:22:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up About an hour       0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:23:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:24:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:25:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:26:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up About an hour       0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:30:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up 8 minutes           0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:31:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up 2 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:32:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:33:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:34:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:35:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up About an hour       0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:39:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up 8 minutes           0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:40:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up 2 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:41:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:42:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:43:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:44:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up About an hour       0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:48:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up 13 minutes          0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:49:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up 2 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:50:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:51:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:52:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:53:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up About an hour       0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:57:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   2 hours ago   Up 14 minutes          0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:58:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        2 hours ago   Up 2 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:59:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:60:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        2 hours ago   Up 2 hours             
    /Users/f/daegis/logs/halu.log:61:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      2 hours ago   Up 2 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:62:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     2 hours ago   Up About an hour       0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:554:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   3 hours ago   Up About an hour       0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:555:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        3 hours ago   Up 3 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:556:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           3 hours ago   Up 3 hours             
    /Users/f/daegis/logs/halu.log:557:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        3 hours ago   Up 3 hours             
    /Users/f/daegis/logs/halu.log:558:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      3 hours ago   Up 3 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:559:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     3 hours ago   Up 2 hours             0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:560:name: halu-dev
    /Users/f/daegis/logs/halu.log:579:        source: /Users/f/halu-dev/alertmanager
    /Users/f/daegis/logs/halu.log:605:        source: /Users/f/halu-dev/grafana/provisioning
    /Users/f/daegis/logs/halu.log:610:        source: /Users/f/halu-dev/grafana/dashboards
    /Users/f/daegis/logs/halu.log:616:      context: /Users/f/halu-dev
    /Users/f/daegis/logs/halu.log:624:      COMPOSE_PROJECT_NAME: halu-dev
    /Users/f/daegis/logs/halu.log:876:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   3 hours ago   Up About an hour       0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:877:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        3 hours ago   Up 3 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:878:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           3 hours ago   Up 3 hours             
    /Users/f/daegis/logs/halu.log:879:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        3 hours ago   Up 3 hours             
    /Users/f/daegis/logs/halu.log:880:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      3 hours ago   Up 3 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:881:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     3 hours ago   Up 2 hours             0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:977:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   4 hours ago   Up 2 hours             0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:978:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        4 hours ago   Up 3 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:979:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           4 hours ago   Up 4 hours             
    /Users/f/daegis/logs/halu.log:980:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        4 hours ago   Up 4 hours             
    /Users/f/daegis/logs/halu.log:981:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      4 hours ago   Up 4 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:982:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     4 hours ago   Up 3 hours             0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/logs/halu.log:1030:halu-dev-alertmanager-1   prom/alertmanager:latest   "/bin/alertmanager -…"   alertmanager   4 hours ago   Up 2 hours             0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp
    /Users/f/daegis/logs/halu.log:1031:halu-dev-grafana-1        grafana/grafana:latest     "/run.sh"                grafana        4 hours ago   Up 3 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
    /Users/f/daegis/logs/halu.log:1032:halu-dev-halu-1           halu-dev-halu              "python -m app.main"     halu           4 hours ago   Up 4 hours             
    /Users/f/daegis/logs/halu.log:1033:halu-dev-metrics-1        python:3.11-slim           "sh -lc 'pip install…"   metrics        4 hours ago   Up 4 hours             
    /Users/f/daegis/logs/halu.log:1034:halu-dev-mosquitto-1      eclipse-mosquitto:2        "/docker-entrypoint.…"   mosquitto      4 hours ago   Up 4 hours (healthy)   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp
    /Users/f/daegis/logs/halu.log:1035:halu-dev-prometheus-1     prom/prometheus:latest     "/bin/prometheus --c…"   prometheus     4 hours ago   Up 3 hours             0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp
    /Users/f/daegis/ops/runbooks/README.md:3:[![Smoke & Gate](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml/badge.svg)](https://github.com/hlo17/halu-dev/actions/workflows/ci.yml)
    /Users/f/daegis/ops/ward/Daegis-Ward.md.20251006-153344.bak:176:- 正式ルート: ~/daegis （~/halu-dev は互換 symlink）
    /Users/f/daegis/ops/ward/Daegis-Ward.md:176:- 正式ルート: ~/daegis （~/halu-dev は互換 symlink）
    /Users/f/daegis/ops/ward/halu-dev-audit.md:1:# halu-dev backup audit (Mon Oct  6 15:38:39 JST 2025)
    /Users/f/daegis/ops/ward/halu-dev-audit.md:2:- Source: /Users/f/halu-dev.migrated.20251006-151256
    /Users/f/daegis/ops/ward/halu-dev-leftovers.md:1:# halu-dev leftovers (not auto-imported)
    /Users/f/daegis/ops/ward/halu-dev-leftovers.md:2:- source: /Users/f/halu-dev.migrated.20251006-151256
    /Users/f/daegis/ops/ward/ops-clean-audit-Fs-MacBook-Pro.local.md:44:## E) stale refs (halu-dev)
    /Users/f/daegis/venv/pyvenv.cfg:5:command = /Users/f/halu-dev/venv/bin/python3 -m venv /Users/f/daegis/venv

## F) duplicate filenames (coarse)
_skip_

## G) proposed actions (dry-run)
```bash
# 1) ゴミ系の削除（安全：拡張子系のみ）
find "/Users/f/daegis" -type f -regextype posix-extended -regex ".*(^|/)(\.DS_Store|.*\.bak(\.|$)|.*~$|.*\.old$|.*\.tmp$)" -print

# 2) 実行する場合（本番）
APPLY=1 find "/Users/f/daegis" -type f -regextype posix-extended -regex ".*(^|/)(\.DS_Store|.*\.bak(\.|$)|.*~$|.*\.old$|.*\.tmp$)" -print -delete

# 3) halu-dev の文言置換例（レビュー必須）
grep -RIl "\\bhalu-dev\\b" "/Users/f/daegis" | xargs -I{} sed -i.bak "s/halu-dev/daegis/g" {}
```

---

## Obsidian（Vault を ~/daegis に）
1. Obsidian → Open folder as vault → **/Users/f/daegis** を選択
2. （任意）Vault 名を "Daegis" に
3. 既存 Vault が他パスなら Close してから上記で再オープン

---

