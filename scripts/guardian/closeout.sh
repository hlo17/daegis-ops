#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"

DO_BLOCK="${BLOCK:-0}"     # 0: ブロックしない, 1: ブロックする（明示時のみ）
COOLDOWN_MIN="${COOLDOWN_MIN:-30}"

# [1] adopt ブロック（明示指定のときだけ）
if [ "$DO_BLOCK" = "1" ] || [ "${1:-}" = "block" ]; then
  mkdir -p "$ROOT/flags"
  date -d "+${COOLDOWN_MIN} min" +%s > "$ROOT/flags/L105_COOLDOWN_UNTIL"
  : > "$ROOT/flags/L5_VETO"
  echo "[park] adopt BLOCKED (VETO + ${COOLDOWN_MIN}m cooldown)"
else
  echo "[park] adopt NOT blocked (explicit only)"
fi

# [2] ダッシュ・スナップショット（WORM）
bash "$ROOT/scripts/dev/dashboard_lite.sh" || true
mkdir -p "$ROOT/archives/$(date +%F)"
cp "$ROOT/docs/runbook/dashboard_lite.md" "$ROOT/archives/$(date +%F)/" 2>/dev/null || true

# [3] adopt_block_last200 → rollup 反映
if [ -f "$ROOT/logs/policy_apply_controlled.jsonl" ]; then
  CNT=$(tac "$ROOT/logs/policy_apply_controlled.jsonl" | head -200 | jq -r 'select(.event=="adopt_block")|1' | wc -l)
  tmp=$(mktemp)
  jq --argjson n "$CNT" '.kpi.adopt_block_last200=$n' "$ROOT/docs/rollup/current.json" > "$tmp" && mv "$tmp" "$ROOT/docs/rollup/current.json"
  echo "[park] adopt_block_last200=$CNT"
else
  echo "[park] (no policy_apply_controlled.jsonl)"
fi

# [4] cron 証跡（WORM）
mkdir -p "$ROOT/docs/chronicle"
if command -v crontab >/dev/null 2>&1 && crontab -l >/dev/null 2>&1; then
  "$ROOT/ops/capsules/scribe/cron_snapshot.sh" || true
else
  echo "(no crontab)" > "$ROOT/docs/chronicle/cron_snapshot.txt"
fi

# [5] guardian status をファイル化（任意の監査物）
{ echo "=== Guardian Status Snapshot ==="; "$ROOT/scripts/guardian/status.sh"; } > "$ROOT/docs/chronicle/guardian_status.txt" 2>&1 || true

# [6] Git コミット
git -C "$ROOT" add flags/* docs/rollup/current.json docs/chronicle/cron_snapshot.txt docs/chronicle/guardian_status.txt archives/$(date +%F)/dashboard_lite.md 2>/dev/null || true
PRE_COMMIT_ALLOW_NO_CONFIG=1 git -C "$ROOT" commit -m "park: snapshot (dash/cron/status; block=${DO_BLOCK})" || true
git -C "$ROOT" push || true
echo "[DONE] park sequence completed."
