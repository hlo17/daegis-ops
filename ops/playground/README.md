# Playground (DRY-only)
- 目的: 壊してOKな実験場。**実行はDRYのみ** / 本線への昇格は別PR。
- ルール:
  - autonomy_level は **L0/L1** のみ
  - intent は **play.*** のみ
  - 成果は WORM( logs/worm/journal.jsonl ) と Prom に記録
- 実行: scripts/playground/run.sh --dry ops/playground/experiments/foo.yml
