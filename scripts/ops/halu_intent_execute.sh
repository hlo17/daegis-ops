#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
LED="$ROOT/docs/ledger/halu.jsonl"
BUS="$ROOT/logs/halu/bus.jsonl"
PROM="$ROOT/logs/prom/halu_intent.prom"
SUMPROM="$ROOT/logs/prom/halu_reflection_summary.prom"
ID="${1:-reflect_digest_hourly}"

# quorum
"$ROOT/scripts/ops/halu_quorum_gate.sh" >/dev/null

# proposal (<=20m)
test -s "$LED" || { echo "[HOLD] no ledger"; exit 3; }
if command -v tac >/dev/null 2>&1; then REV="tac"; else REV="tail -r"; fi
RECENT="$($REV "$LED" | jq -r --arg ID "$ID" 'select(.act=="intent.propose" and .id==$ID) | .t // empty' | head -n1 || true)"
[ -n "$RECENT" ] || { echo "[HOLD] no recent propose for $ID"; exit 3; }
if ! RECENT_TS=$(date -ud "$RECENT" +%s 2>/dev/null); then echo "[HOLD] invalid proposal timestamp: $RECENT"; exit 3; fi
NOW=$(date +%s); if [ $((NOW-RECENT_TS)) -gt 1200 ]; then echo "[HOLD] proposal too old (>20m)"; exit 3; fi

# inputs (dry)
TOTAL=$(awk '/^daegis_halu_reflection_summary_total_1h/{print $2+0}' "$SUMPROM" 2>/dev/null || echo 0)
TOP="$($REV "$LED" | jq -rc 'select(.act=="reflect.summarize")|.top_intents|join("/")' | head -n1 2>/dev/null || echo "")"
ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOTE="digest(1h): total=${TOTAL}; top=${TOP:-n/a}"

# evidence
mkdir -p "$(dirname "$LED")" "$(dirname "$BUS")" "$(dirname "$PROM")"
echo "{\"t\":\"$ISO\",\"act\":\"intent.execute.dry\",\"id\":\"$ID\",\"note\":\"$NOTE\",\"stage\":\"L3\"}" >> "$LED"
echo "{\"ts\":$(date +%s),\"agent\":\"halu\",\"event\":\"intent.execute.dry\",\"id\":\"$ID\",\"total\":$TOTAL}" >> "$BUS"

# prom counter (外部小スクリプトで原子的に更新)
"$ROOT/scripts/ops/prom_bump_counter.sh" "daegis_halu_intent_exec_total" "$PROM" >/dev/null

echo "[OK] DRY executed: $ID :: $NOTE"
