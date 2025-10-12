# Solaris (Idle Harvest) — AGENT SPEC
## Mission
低負荷時に安全な“静的学習素材”を収穫（行数/ハッシュ等の軽量特徴）。
## Interfaces
- input: archives/<date>/beacon.md, dashboard_lite.md
- output: logs/worm/journal.jsonl (event=solar_harvest)
- metrics: logs/prom/daegis_solaris.prom
## Tests
- run: `bash scripts/ops/idle_harvest.sh`
- expect: WORM に `solar_harvest` イベント、Prom に 4指標が載る
