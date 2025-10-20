#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
cd "$ROOT"

have_prev(){
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  git cat-file -e HEAD~1:docs/rollup/current.json >/dev/null 2>&1 || return 1
}

arrow(){ # old new
  awk -v o="$1" -v n="$2" 'BEGIN{
    if(o==""||o=="unknown"||n==""||n=="unknown"){print "~"; exit}
    if(o==n){print "="} else if (n>o){print "↑"} else {print "↓"}
  }'
}

echo "=== Guardian Diff (vs previous commit) ==="
if ! have_prev; then
  echo "(no previous snapshot found; make at least one commit)"; exit 0
fi

# --- KPI diff ---
echo
echo "--- KPI ---"
cur_canary=$(jq -r '.kpi.canary_verdict//"unknown"' docs/rollup/current.json 2>/dev/null || echo unknown)
cur_hold=$(jq -r '.kpi.hold_rate//"unknown"' docs/rollup/current.json 2>/dev/null || echo unknown)
cur_e5xx=$(jq -r '.kpi.e5xx//"unknown"' docs/rollup/current.json 2>/dev/null || echo unknown)
cur_p95=$(jq -r '.kpi.p95_ms//"unknown"' docs/rollup/current.json 2>/dev/null || echo unknown)
cur_adopt=$(jq -r '.kpi.adopt_block_last200//"unknown"' docs/rollup/current.json 2>/dev/null || echo unknown)

prev_json=$(mktemp)
git show HEAD~1:docs/rollup/current.json > "$prev_json" 2>/dev/null || true
prev_canary=$(jq -r '.kpi.canary_verdict//"unknown"' "$prev_json" 2>/dev/null || echo unknown)
prev_hold=$(jq -r '.kpi.hold_rate//"unknown"' "$prev_json" 2>/dev/null || echo unknown)
prev_e5xx=$(jq -r '.kpi.e5xx//"unknown"' "$prev_json" 2>/dev/null || echo unknown)
prev_p95=$(jq -r '.kpi.p95_ms//"unknown"' "$prev_json" 2>/dev/null || echo unknown)
prev_adopt=$(jq -r '.kpi.adopt_block_last200//"unknown"' "$prev_json" 2>/dev/null || echo unknown)

printf "canary_verdict: %s → %s\n" "$prev_canary" "$cur_canary"
printf "hold_rate:      %s → %s  %s\n" "$prev_hold" "$cur_hold" "$(arrow "$prev_hold" "$cur_hold")"
printf "e5xx:           %s → %s  %s\n" "$prev_e5xx" "$cur_e5xx" "$(arrow "$prev_e5xx" "$cur_e5xx")"
printf "p95_ms:         %s → %s  %s\n" "$prev_p95" "$cur_p95" "$(arrow "$prev_p95" "$cur_p95")"
printf "adopt_last200:  %s → %s  %s\n" "$prev_adopt" "$cur_adopt" "$(arrow "$prev_adopt" "$cur_adopt")"

# --- Flags diff ---
echo
echo "--- Flags ---"
for f in L5_VETO L105_COOLDOWN_UNTIL; do
  cur="absent"; [ -s "flags/$f" ] && cur="present"
  prev="absent"
  if git cat-file -e "HEAD~1:flags/$f" >/dev/null 2>&1; then prev="present"; fi
  printf "%-20s %s → %s\n" "$f:" "$prev" "$cur"
done

# --- Ledger tail diff ---
echo
echo "--- Ledger tail (last 5 lines) ---"
echo "[current]"
tail -5 docs/chronicle/phase_ledger.jsonl 2>/dev/null | jq -Rr 'if test("^\\s*\\{") then (fromjson? // empty) as $o | "- " + ($o.phase//"unknown") + " " + ($o.component_id//$o.id//"(unknown)") + " " + ($o.topic//$o.event//"(no-topic)") else empty end' || true
echo "[previous]"
git show HEAD~1:docs/chronicle/phase_ledger.jsonl 2>/dev/null | tail -5 | jq -Rr 'if test("^\\s*\\{") then (fromjson? // empty) as $o | "- " + ($o.phase//"unknown") + " " + ($o.component_id//$o.id//"(unknown)") + " " + ($o.topic//$o.event//"(no-topic)") else empty end' || true
