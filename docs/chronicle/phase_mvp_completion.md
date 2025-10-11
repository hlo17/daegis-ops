# Daegis OS – Phase I (MVP) Completion Chronicle

- **Tag**: {{AUTO_FILL_TAG_OR_NOTE}}  
- **Branch**: {{AUTO_FILL_BRANCH}}  
- **Commit**: {{AUTO_FILL_COMMIT_ONELINE}}

## What Shipped (MVP)
- Orchestration: /chat MISS→HIT cache + 3s timeout(504)
- Safety: `scripts/guard/safe_fallback.sh`（手動トグル）＋ X-Mode header
- Ontology: `ops/policy/compass.json`, `intents.yml`, charter
- Observability: Episode-ID, Decision log (toggle), Decision ledger (JSONL)
- Monitoring: Prometheus(:9091) alerts + hint annotations
- Release/Recovery: tag, rollback script, runbooks

## Evidence (see `docs/runbook/mvp_evidence.md`)
- Headers（x-cache / x-corr-id / x-episode-id）
- SAFE 往復（x-mode: SAFE）
- Decision Log toggle（LOG_DECISION=0）
- Decision Ledger 末尾1行
- Alert hints via :9091 API

## Release & Rollback

### Create Release Tag
```bash
# Auto-generated timestamp tag
scripts/release/cut.sh

# Custom version tag
scripts/release/cut.sh v1.2.3
```

### Safe Rollback
```bash
# Guided rollback to specific tag (revert-based, no hard reset)
scripts/release/rollback.sh v1.2.2

# Follow prompts: inspect diff → create revert → review → commit & push
```

**Principle**: Always use tag-based rollback with `git revert` for safety.

## Phase II Launch — Autonomous Safeguards & Traceability (2025-10-09)

- MVP 完了 (vMVP-20251009-1926) を確認。  
- ChatGPT 13 議席を正式に追加。  
- 運用方針：API-one proof / Tasks-only / 二者承認を確定。  
- Prometheus(:9091 Docker) を Single Source of Truth と定義。  
- 開始タスク：Alert→SAFE 準自動化、Ledger Rotation、Grafana Trace Panel、Compass 署名化。

## Risks & Mitigations (current)
- /metrics 500 in dev → doc化済み（dev-only、必要なら `requirements-dev.txt`）
- Human-in-the-loop SAFE → 次フェーズで準自動化

## Phase II (Next)
1. Alert → SAFE 準自動（人間承認ワンキー実行）
2. Decision ledger ローテーション（10MB×3）
3. Episode trace パネル（Grafana）
4. Compass 変更の署名＋Ledger記録
<!-- Generated on 2025-10-11T07:21:05Z -->
# Chronicle (MVP→Phase II/V/VI)
参照: docs/chronicle/2025-10-11/, phase_ledger.jsonl
