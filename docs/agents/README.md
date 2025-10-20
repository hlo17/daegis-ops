# agents.md — Daegis での使い方（最短版）

## Mission
各エージェントの設計・計画・検証を単一点に集中し、AIが自走できる足場を提供する。

## Exec Plan
- まず docs/chronicle/plans.md を更新
- docs/agents/*.md を先に直し、実装は後
- /review と Garden Gate でレビュー→反映

## Tests
- scripts/ops/agents_check.sh
- guardian beacon + WORM
- PromQL で daegis_solaris_* が取れる
