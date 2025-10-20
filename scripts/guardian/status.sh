#!/usr/bin/env bash
set -euo pipefail
root="${1:-$PWD}"

echo "=== Guardian Status ==="

# ---- Phase（JSONLの最終行）----
if [ -f "$root/docs/chronicle/phase_ledger.jsonl" ]; then
  PHASE=$(tail -1 "$root/docs/chronicle/phase_ledger.jsonl" \
          | jq -r '.phase // "unknown"' 2>/dev/null || echo "unknown")
else
  PHASE="unknown"
fi
echo "Phase: ${PHASE}"

echo
echo "--- KPI (rollup/current.json) ---"
if [ -f "$root/docs/rollup/current.json" ]; then
  jq '.kpi' "$root/docs/rollup/current.json"
else
  echo "(missing)"
fi

echo
echo "--- System Map (nodes / edges) ---"
if [ -f "$root/docs/chronicle/system_map.json" ]; then
  jq -r '["nodes="+(((.nodes//[])|length)|tostring),
          "edges="+(((.edges//[])|length)|tostring)] | join(" ")' \
     "$root/docs/chronicle/system_map.json"
  echo "nodes:"
  jq -r '(.nodes//[])[]? | (.id // .component_id // "unknown")' \
     "$root/docs/chronicle/system_map.json" | sed 's/^/  - /'
else
  echo "(missing)"
fi

echo
echo "--- Last 10 Ledger Entries ---"
if [ -f "$root/docs/chronicle/phase_ledger.jsonl" ]; then
  tail -10 "$root/docs/chronicle/phase_ledger.jsonl" \
  | jq -Rr '
      if test("^\\s*\\{") then
        (fromjson? // empty) as $o
        | if $o == {} then empty else
            "\(($o.timestamp_utc // $o.decision_time // $o.ts // "-"))\t\(($o.phase // "unknown"))\t\(($o.component_id // $o.id // "unknown"))\t\(($o.topic // $o.event // "(no-topic)"))"
          end
      else empty end
    '
else
  echo "(missing)"
fi

echo
echo "--- Flags ---"
for f in L5_VETO L105_COOLDOWN_UNTIL; do
  if [ -e "$root/flags/$f" ]; then
    echo "  $f: present"
  else
    echo "  $f: (absent)"
  fi
done

echo
echo "--- WORM evidence ---"
test -s "$root/docs/chronicle/cron_snapshot.txt" && echo "  cron_snapshot: OK" || echo "  cron_snapshot: (missing)"
test -s "$root/docs/runbook/dashboard_lite.md" && echo "  dashboard_lite: OK" || echo "  dashboard_lite: (missing)"
d="archives/$(date +%F)/dashboard_lite.md"; [ -f "$root/$d" ] && echo "  dash_snapshot_today: OK" || echo "  dash_snapshot_today: (missing)"

echo
echo "--- Next Actions (from summary.md) ---"
if [ -f "$root/docs/chronicle/summary.md" ]; then
  sed -n '/^## Next Actions/,$p' "$root/docs/chronicle/summary.md" | sed -n '1,80p'
else
  echo "(missing)"
fi
