# Daegis — Copilot Ops Cheatsheet

## Status (Guardian)

./scripts/guardian/status.sh

## Safe Park（終業）

./scripts/guardian/closeout.sh

## Regenerate 6 Docs（Map / Ledger / Chronicle / Brief / Runbook / Charter）

bash scripts/dev/regenerate_docs_full.sh
git add docs/chronicle/*.md docs/runbook/dashboard_lite.md || true
PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m "docs: regenerate 6-pack" || true
git push || true

## References
- Phase Lexicon: ops/policy/phase_lexicon.json
- Six Docs Roots:
  - Map: docs/chronicle/system_map.json
  - Ledger: docs/chronicle/phase_ledger.jsonl (+ docs/chronicle/ledger.md)
  - Chronicle: docs/chronicle/chronicle.md
  - Brief: docs/chronicle/brief.md
  - Runbook: docs/runbook/dashboard_lite.md
  - Charter: docs/chronicle/charter.md

## Guardian Cheats
- 現状サマリ: `guardian`
- 終業スナップショット: `guardian park`  （※デフォルトは非ブロック。ブロック時: `BLOCK=1 COOLDOWN_MIN=45 guardian park`）
- 6-docs 再生成: `guardian docs`
- 変化差分: `guardian diff`
- コンパクト出力: `guardian beacon`

## Factory (Runbook quick)
1) キューへ JSON を置く: `ops/factory/queue/job_xxx.json`
2) 署名検証 & RBAC & Allowlist 通過で実行（APPROVEDのみ実行、それ以外は DRY）
3) 監査: `logs/factory_jobs.jsonl` を参照（WORM）
