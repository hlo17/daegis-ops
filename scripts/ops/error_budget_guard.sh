#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"

BJSON="docs/chronicle/beacon.json"
EB="ops/policy/error_budget.json"
[ -f "$BJSON" ] || exit 0
[ -f "$EB" ]    || exit 0

e5xx=$(jq -r '.KPI.e5xx // 0' "$BJSON")
hold=$(jq -r '.KPI.hold_rate // 0' "$BJSON")
p95=$(jq -r '.KPI.p95_ms // 0' "$BJSON")
max_e5=$(jq -r '.budget.e5xx.max' "$EB")
max_hr=$(jq -r '.budget.hold_rate.max' "$EB")
max_p95=$(jq -r '.budget.p95_ms.max' "$EB")
days_ok=$(jq -r '.suggest_restore_after_days' "$EB")

# 履歴
mkdir -p logs
echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"e5xx\":$e5xx,\"hold\":$hold,\"p95\":$p95}" >> logs/error_budget.history.jsonl

# 直近N日の合格判定（緩め・簡易）
ok_days=$(tail -n $((days_ok*24)) logs/error_budget.history.jsonl 2>/dev/null \
  | awk -v me="$max_e5" -v mh="$max_hr" -v mp="$max_p95" '
    {e5=$0; gsub(/.*"e5xx":/,"",e5); gsub(/,.*$/,"",e5);
     hr=$0; gsub(/.*"hold":/,"",hr); gsub(/,.*$/,"",hr);
     p9=$0; gsub(/.*"p95":/,"",p9); gsub(/}.*$/,"",p9);
     if (e5+0<=me && hr+0<=mh && p9+0<=mp) ok++}
    END{print ok+0}
  ')

suggest_down="false"
suggest_restore="false"
reason_down=()

# ダウン提案（今時点の逸脱）
[ "$e5xx" -gt "$max_e5" ] && { suggest_down="true"; reason_down+=("e5xx>$max_e5"); }
awk "BEGIN{exit !($hold > $max_hr)}" || { suggest_down="true"; reason_down+=("hold>$max_hr"); }
awk "BEGIN{exit !($p95 > $max_p95)}" || { suggest_down="true"; reason_down+=("p95>$max_p95"); }

# 復帰提案（連続OK）
if [ "$ok_days" -ge "$((days_ok*24-1))" ]; then
  suggest_restore="true"
fi

# 出力（非破壊：提案ファイルと旗だけ）
mkdir -p logs/flags
rm -f logs/flags/GATE_SUGGEST_* 2>/dev/null || true
if [ "$suggest_down" = "true" ]; then
  touch logs/flags/GATE_SUGGEST_DOWN
fi
if [ "$suggest_restore" = "true" ]; then
  touch logs/flags/GATE_SUGGEST_RESTORE
fi

# Beaconに提案を1行追記（存在すれば）
if [ -f docs/chronicle/beacon.md ]; then
  [ "$suggest_down" = "true" ] && echo "- **suggest_gate**: DOWN (${reason_down[*]})" >> docs/chronicle/beacon.md
  [ "$suggest_restore" = "true" ] && echo "- **suggest_gate**: RESTORE (past ${days_ok}h clean)" >> docs/chronicle/beacon.md
fi
