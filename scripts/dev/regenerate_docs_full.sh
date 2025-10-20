#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
NOW="$(date -u +%FT%TZ)"
out_chron="$ROOT/docs/chronicle"
out_run="$ROOT/docs/runbook"
out_roll="$ROOT/docs/rollup"
mkdir -p "$out_chron" "$out_run" "$out_roll"

# KPI（無ければ unknown）
kpi_canary=$(jq -r '.kpi.canary_verdict//"unknown"' "$out_roll/current.json" 2>/dev/null || echo unknown)
kpi_hold=$(jq -r '.kpi.hold_rate//"unknown"' "$out_roll/current.json" 2>/dev/null || echo unknown)
kpi_e5xx=$(jq -r '.kpi.e5xx//"unknown"' "$out_roll/current.json" 2>/dev/null || echo unknown)
kpi_p95=$(jq -r '.kpi.p95_ms//"unknown"' "$out_roll/current.json" 2>/dev/null || echo unknown)
kpi_adopt=$(jq -r '.kpi.adopt_block_last200//"unknown"' "$out_roll/current.json" 2>/dev/null || echo unknown)

# 1) Chronicle（台帳→時系列）
{
  echo "# Chronicle"
  echo
  echo "_Generated at ${NOW}_"
  echo
  if [ -f "$out_chron/phase_ledger.jsonl" ]; then
    echo "## Timeline (tail 100)"
    tail -100 "$out_chron/phase_ledger.jsonl" \
      | jq -Rr '
          if test("^\\s*\\{") then
            (fromjson? // empty) as $o
            | "- \(($o.timestamp_utc // $o.decision_time // $o.ts // "-"))"
            + " — [" + ($o.phase // "unknown") + "] "
            + ($o.component_id // $o.id // "(unknown)") + ": "
            + ($o.topic // $o.event // "(no-topic)") 
          else empty end
        '
  else
    echo "(no ledger)"
  fi
} > "$out_chron/chronicle.md"

# 2) Brief（KPI＋Map抜粋）
{
  echo "# Brief"
  echo
  echo "_Snapshot @ ${NOW}_"
  echo
  echo "- KPI: canary=$kpi_canary, hold=$kpi_hold, e5xx=$kpi_e5xx, p95=$kpi_p95, adopt_last200=$kpi_adopt"
  echo "- Nodes/Edges:"
  if [ -f "$out_chron/system_map.json" ]; then
    jq -r '"  - nodes=\((.nodes//[])|length), edges=\((.edges//[])|length)"' "$out_chron/system_map.json"
    echo "  - node ids:"
    jq -r '(.nodes//[])[]? | "    - " + (.id // .component_id // "unknown")' "$out_chron/system_map.json"
  else
    echo "  (missing system_map.json)"
  fi
} > "$out_chron/brief.md"

# 3) Charter（目的・ガードレール）
{
  echo "# Charter"
  echo
  echo "## Purpose"
  echo "- 円卓型AI協働システム（Daegis OS）は、複数のAIエージェントと人間（議長）が「意思決定 → 検証 → 証跡 → 学習」を **1本のAPIで監査可能** にする実験型OS。"
  echo "- 中心に6文書体制（Map / Ledger / Chronicle / Brief / Runbook / Charter）を置き、全変更は **Append-only ＋ API-one proof** 原則で管理。"
  echo
  echo "## Guardrails"
  echo "- Auto-Adopt は L5_VETO / L105_COOLDOWN_UNTIL で即時停止。"
  echo "- Canary は **エラー削減で PASS** を目指す（しきい値緩和は最後の手段）。"
  echo
  echo "## Current KPIs"
  echo "- canary=$kpi_canary, hold=$kpi_hold, e5xx=$kpi_e5xx, p95=$kpi_p95, adopt_last200=$kpi_adopt"
} > "$out_chron/charter.md"

# 4) Ledger（集計ビュー：原本JSONLはそのまま）
{
  echo "# Ledger (Aggregates)"
  echo
  if compgen -G "$ROOT/logs/decision*.jsonl" >/dev/null; then
    TOTAL=$(grep -ch '^{' "$ROOT"/logs/decision*.jsonl 2>/dev/null | awk '{s+=$1} END{print s+0}')
  else
    TOTAL=0
  fi
  if [ -f "$ROOT/logs/decision_enriched.jsonl" ]; then
    HOLDS=$(jq -r 'select(.ethics?.verdict=="HOLD") | 1' "$ROOT/logs/decision_enriched.jsonl" 2>/dev/null | wc -l | tr -d ' ')
  else
    HOLDS=0
  fi
  echo "- decisions_total: ${TOTAL}"
  echo "- holds_total: ${HOLDS}"
  echo
  echo "## Recent (tail 20)"
  if [ -f "$out_chron/phase_ledger.jsonl" ]; then
    tail -20 "$out_chron/phase_ledger.jsonl" \
    | jq -Rr '
        if test("^\\s*\\{") then
          (fromjson? // empty) as $o
          | "- " + ($o.component_id // $o.id // "unknown")
          + ": " + ($o.evaluation?.verdict // "unknown")
        else empty end'
  fi
} > "$out_chron/ledger.md"

echo "[done] regenerated 6 docs at ${NOW}"
