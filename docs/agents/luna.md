# Luna — AGENT SPEC
## Mission
潮汐/位相で「探索↔整頓」を切替える司令塔（Autopilot）。
## Payload
`daegis/luna/state`: {phase, tide, ts, weight, mode}
## Exec Plan
- tide: high=探索 / low=整頓
- beat: 5m, phase weight: waxing(+1) full(+2) waning(-1) new(-2)
## Tests
- run: `bash scripts/ops/idle_harvest.sh` → prom `daegis_solaris_*` が更新
## Review
- `/review luna` で weight/mode の妥当性点検（過負荷/低収穫を避ける）
## Playbooks
- pb-1: high の時は `introspect` 未回答消化優先
