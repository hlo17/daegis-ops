#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
now="$(date -u +%FT%TZ)"

echo "[regen] rebuilding docs bundles…"

mkdir -p "$ROOT/docs/chronicle" "$ROOT/docs/rollup"

# 0) バリデーション（壊れてても落とさない）
jq . "$ROOT/docs/chronicle/system_map.json" >/dev/null 2>&1 || echo "[warn] system_map.json missing/invalid"
jq . "$ROOT/docs/rollup/current.json"      >/dev/null 2>&1 || echo "[warn] rollup/current.json missing/invalid"

# 1) Chronicle Summary（Next Actions が無ければ作成）
summary="$ROOT/docs/chronicle/summary.md"
touch "$summary"
if ! grep -q "^## Next Actions" "$summary"; then
  {
    echo "## Next Actions (auto seeded at $now)"
    echo
    echo "1) Dashboard KPI 証跡の固定化 …"
    echo "2) Cron 実在証跡の保存 …"
    echo "3) trace_id 採番ルールの固定 …"
    echo
  } >> "$summary"
fi

# 2) Brief（なければ作成、あれば追記）
brief="$ROOT/docs/chronicle/brief.md"
touch "$brief"
{
  echo
  echo "### Snapshot @ $now"
  if [ -f "$ROOT/docs/rollup/current.json" ]; then
    jq -r '"- KPI: canary=\(.kpi.canary_verdict//"unknown"), hold=\(.kpi.hold_rate//"unknown"), e5xx=\(.kpi.e5xx//"unknown"), p95=\(.kpi.p95_ms//"unknown"), adopt_last200=\(.kpi.adopt_block_last200//"unknown")"' \
      "$ROOT/docs/rollup/current.json" 2>/dev/null || true
  fi
} >> "$brief"

# 3) Charter（存在しなければ雛形だけ）
charter="$ROOT/docs/chronicle/charter.md"
if [ ! -s "$charter" ]; then
  cat > "$charter" <<EOF
# Daegis Charter (seed)
- Governance: Append-only, Tasks-only, No new ports/deps
- Evidence: WORM snapshots (cron, dashboard), API-one proof
- Phase: (auto) $(tail -1 "$ROOT/docs/chronicle/phase_ledger.jsonl" 2>/dev/null | jq -r '.phase // "unknown"')
EOF
fi

# 4) Instructions（copilot README 同期は外部スクリプトに委譲）
# ここは Phase VI で本実装へ差し替え
[ -x "$ROOT/scripts/dev/sync_copilot_readme.sh" ] && bash "$ROOT/scripts/dev/sync_copilot_readme.sh" || true

echo "[done] (Phase VIで本実装へ差し替え)"
