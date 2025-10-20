# Garden Gate — Handoff Map (v0)

## What matters (今フェーズの要点)
- **運用モード**: Phase VII / Gate=半開（D→L1を往復）
- **文化の芯**: Emotion Codex / Narrative Trigger / Ferment / Hash-Rely / Parlance
- **窓口**: Garden Gate（`inbox/window/*.md` + `tools/window_open.sh`）

## Where things live（格納場所）
- エージェント仕様: `docs/agents/*.md`（AGENTS.md＝見取り図）
- 計画書: `docs/chronicle/plans.md`（“まずここを更新”）
- 証跡/WORM: `logs/worm/journal.jsonl`（Prom→`logs/prom/*.prom`）
- 感情語彙/タグ: `ops/policy/emotion_codex.yml` / `scripts/scribe/mood_tag.sh`
- 詩的トリガ: `ops/factory/policies.d/narrative_triggers.json`
- 発酵（Cooldown出力）: `scripts/guardian/cooldown_ferment.sh`
- DNA（後述統合）: `ops/ledger/agent_dna.jsonl`
- Parlance: `docs/agents/AEGIS.parlance.md`
- Spirit（場の意識・メタ）: `docs/chronicle/spirit.yml`

## Daily loops（毎日/毎時ループ）
- **毎20分**: Narrative Trigger → 必要なら Window カード起票
- **毎時17分**: Ferment（Cooldown時の要約＆意思決定ツリー）
- **毎時07分**: Garden Badge（ダッシュの“色”タグ）
- **随時**: `scripts/scribe/mood_tag.sh <MOOD> <tone> "<note>"`

## Guardrails（常に守る）
- **PlaygroundはDRY限定**（L0/L1 & `intent=play.*`）
- **Intent Lexicon から外れない**（`ops/policy/intent_lexicon.json`）
- **Test gate**: `hold_rate<=0.10 && e5xx==0 && p95<=2500`
- **Decisionは記録から**：/review → WORM → Beacon

## Interfaces（外部/他AI）
- **Garden Gateカード**: `docs/window/CARD_TEMPLATE.md` に従い作成
- **/review**: `tools/ai_review.sh <topic>`（assistant_profile/parlanceを自動同梱）
- **名前マップ**: `profiles/participants.yml`（後述）

## In case of fire（緊急時）
- Gateを閉じる: `scripts/guardian/panic.sh`（※既存）
- 失敗予算超え: `ops/policy/error_budget.json` を参照、冷却→Ferment発火
- 復帰ワンライナー: `tools/come_back.sh` または `scripts/ops/resume_L1_dry.sh`