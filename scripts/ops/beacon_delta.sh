#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
bj="docs/chronicle/beacon.json"
md="docs/chronicle/beacon.md"
hist="logs/beacon_history.jsonl"
[ -f "$bj" ] || exit 0
ts=$(jq -r '.ts // now|todate' "$bj" 2>/dev/null || date -u +%FT%TZ)
jq -c '{ts,hold_rate:.KPI.hold_rate,p95_ms:.KPI.p95_ms,e5xx:.KPI.e5xx}' "$bj" >> "$hist"
prev=$(tail -2 "$hist" | head -1)
curr=$(tail -1 "$hist")
ph=$(echo "$prev" | jq -r '.hold_rate // empty'); ch=$(echo "$curr" | jq -r '.hold_rate // empty')
pp=$(echo "$prev" | jq -r '.p95_ms // empty');  cp=$(echo "$curr" | jq -r '.p95_ms // empty')
pe=$(echo "$prev" | jq -r '.e5xx // empty');    ce=$(echo "$curr" | jq -r '.e5xx // empty')

dh="n/a"; dp="n/a"; de="n/a"
[ -n "${ph:-}" ] && [ -n "${ch:-}" ] && dh=$(python3 - <<PY
ph=$ph; ch=$ch
print(f"{ch-ph:+.4f}")
PY
)
[ -n "${pp:-}" ] && [ -n "${cp:-}" ] && dp=$(python3 - <<PY
pp=$pp; cp=$cp
print(f"{cp-pp:+.2f} ms")
PY
)
[ -n "${pe:-}" ] && [ -n "${ce:-}" ] && de=$(python3 - <<PY
pe=$pe; ce=$ce
print(f"{ce-pe:+d}")
PY
)
printf "\n- **Δ (vs prev)**: hold_rate %s / p95 %s / e5xx %s\n" "$dh" "$dp" "$de" >> "$md" || true
