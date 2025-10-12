# Daegis AGENTS index (v0)
このフォルダは、各エージェントが「どう動き、どう検証されるか」をAIが読める形で明記します。
- 役割と境界（Mission / Interfaces）
- 実行計画（Exec Plan）
- テストとレビュー（Tests / Review）
- 最小のプレイブック（Playbooks）

## Catalog
- [Oracle L13](./oracle.md)
- [Luna (Autopilot)](./luna.md)
- [Scribe / Dashboard](./scribe.md)
- [Solaris (Idle Harvest)](./solaris.md)

## Global Conventions
- **Test gate (beacon)**: hold_rate<=0.10 && e5xx==0 && p95_ms<=2500
- **/review**: 実装→レビュー→再実装を機械で往復。CLI: `tools/ai_review.sh`
- **Exec Plan (plans.md)**: 進行台本。AIは最初にここを読むこと。
