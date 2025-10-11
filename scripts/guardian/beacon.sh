#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${ROOT:-$(cd "$SELF_DIR/../.." && pwd)}"
OUT_DIR="$ROOT/docs/chronicle"
NOW="$(date -u +%FT%TZ)"

kv(){ printf '%s: %s\n' "$1" "${2:-unknown}"; }
exists(){ [ -f "$1" ] && [ -s "$1" ]; }

# Phase
PHASE="unknown"
if exists "$OUT_DIR/phase_ledger.jsonl"; then
  PHASE=$(tail -1 "$OUT_DIR/phase_ledger.jsonl" | jq -r '.phase // "unknown"' 2>/dev/null || echo unknown)
fi

# KPI
kpi_json="$ROOT/docs/rollup/current.json"
read -r CANARY HOLD E5XX P95 ADOPT <<EOF
$(jq -r '[.kpi.canary_verdict,.kpi.hold_rate,.kpi.e5xx,.kpi.p95_ms,.kpi.adopt_block_last200] | @tsv' "$kpi_json" 2>/dev/null || echo -e "unknown\tunknown\tunknown\tunknown\tunknown")
EOF

# Flags
VETO=$([ -s "$ROOT/flags/L5_VETO" ] && echo present || echo absent)
COOL=$([ -s "$ROOT/flags/L105_COOLDOWN_UNTIL" ] && echo present || echo absent)

# Ledger tail（寛容）
LEDGER_TAIL="$(
  if exists "$OUT_DIR/phase_ledger.jsonl"; then
    tail -6 "$OUT_DIR/phase_ledger.jsonl" | jq -Rr '
      if test("^\\s*\\{") then
        (fromjson? // empty) as $o
        | select($o != null)
        | "- " + ($o.phase//"unknown") + " · " + ($o.component_id//$o.id//"(unknown)")
        + " · " + ($o.topic//$o.event//"(no-topic)")
      else empty end
    ' 2>/dev/null || true
  fi
)"

# Next Actions（任意）
NEXT_ACT="$(sed -n '/^## Next Actions/,$p' "$OUT_DIR/summary.md" 2>/dev/null | head -20 || true)"

# 画面出力
echo "=== Beacon @ $NOW ==="
kv "phase" "$PHASE"
echo "--- KPI ---"; kv "canary" "$CANARY"; kv "hold_rate" "$HOLD"; kv "e5xx" "$E5XX"; kv "p95_ms" "$P95"; kv "adopt_block_last200" "$ADOPT"
echo "--- flags ---"; kv "L5_VETO" "$VETO"; kv "L105_COOLDOWN_UNTIL" "$COOL"
echo "--- last events ---"; [ -n "$LEDGER_TAIL" ] && echo "$LEDGER_TAIL" || echo "(no ledger)"
echo "--- next actions ---"; [ -n "$NEXT_ACT" ] && echo "$NEXT_ACT" | sed 's/^/  /' || echo "(none)"

# 保存（md/json）
mkdir -p "$OUT_DIR"
BEACON_MD="$OUT_DIR/beacon.md"
BEACON_JSON="$OUT_DIR/beacon.json"

{
  echo "# Beacon"; echo "$NOW"; echo
  echo "- phase: $PHASE"
  echo "- KPI:";  echo "  - canary: $CANARY"; echo "  - hold_rate: $HOLD"; echo "  - e5xx: $E5XX"; echo "  - p95_ms: $P95"; echo "  - adopt_block_last200: $ADOPT"
  echo "- flags:"; echo "  - L5_VETO: $VETO"; echo "  - L105_COOLDOWN_UNTIL: $COOL"
  echo "- last events:"; [ -n "$LEDGER_TAIL" ] && echo "$LEDGER_TAIL" | sed 's/^/  /' || echo "  (none)"
} > "$BEACON_MD"

jq -n \
  --arg now "$NOW" \
  --arg phase "$PHASE" \
  --arg canary "$CANARY" \
  --arg hold "$HOLD" \
  --arg e5xx "$E5XX" \
  --arg p95 "$P95" \
  --arg adopt "$ADOPT" \
  --arg veto "$VETO" \
  --arg cool "$COOL" \
  --arg tail "${LEDGER_TAIL:-}" \
  '{timestamp:$now, phase:$phase,
    kpi:{canary:$canary, hold_rate:$hold, e5xx:$e5xx, p95_ms:$p95, adopt_block_last200:$adopt},
    flags:{L5_VETO:$veto, L105_COOLDOWN_UNTIL:$cool},
    last_events: ($tail|split("\n")|map(select(length>0)))}' \
  > "$BEACON_JSON"

echo "[beacon] wrote:"
echo "  - $BEACON_MD"
echo "  - $BEACON_JSON"
