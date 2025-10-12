# Daegis AGENTS index (v0)
このフォルダは、各エージェントが「どう動き、どう検証されるか」をAIが読める形で明記します。

## Mission
円卓エージェント群（Oracle/Luna/Scribe/Solaris…）の仕様と運用約束を単一の参照点に集約する。

## Exec Plan
1) まず `docs/chronicle/plans.md` を更新（生きた計画書）  
2) 変更は必ず各 `docs/agents/*.md` を先に直す（設計→実装の順）  
3) 実装後 `make ci` 相当の軽検証 → `/review <agent>` を回す → merge

## Tests
- `scripts/ops/agents_check.sh` が **OK** を返すこと  
- `guardian beacon` が成功し、WORM（archives/当日）が生成されること  
- PromQL `daegis_solaris_*` にサンプルが載ること

## Catalog
- [Oracle L13](./oracle.md)
- [Luna (Autopilot)](./luna.md)
- [Scribe / Dashboard](./scribe.md)
- [Solaris (Idle Harvest)](./solaris.md)

## Global Conventions
- Test gate: `hold_rate<=0.10 && e5xx==0 && p95_ms<=2500`
- `/review`: 実装前に設計を、実装後に差分を、機械で往復
- Exec Plan: まず `plans.md` を更新してから手を動かす
