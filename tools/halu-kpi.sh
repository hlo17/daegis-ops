#!/usr/bin/env bash
set -euo pipefail
AB_JSON="/srv/round-table/ab-result.json"
PPL_JSON="$HOME/daegis/tools/halu_5min_model/metrics.json"
OUT="$HOME/daegis/records"; mkdir -p "$OUT"
TS="$(date '+%F %T')"; DAY="$(date '+%Y%m%d')"

decision=$(jq -r '.decision // empty' "$AB_JSON" 2>/dev/null || echo "")
p_value=$(jq -r '(.reason.p_value // .kpi.p_value) // empty' "$AB_JSON" 2>/dev/null || echo "")
improvement=$(jq -r '(.kpi.improvement // .reason.improvement) // empty' "$AB_JSON" 2>/dev/null || echo "")
samples=$(jq -r '.kpi.samples // empty' "$AB_JSON" 2>/dev/null || echo "")
override=$(jq -r '.kpi.override_rate // empty' "$AB_JSON" 2>/dev/null || echo "")
ppl=$(jq -r '.ppl // empty' "$PPL_JSON" 2>/dev/null || echo "")

slot_src="$HOME/daegis/records/hand-off.md"; slot_fill=""
if [ -f "$slot_src" ]; then
  total=$(grep -n '.' "$slot_src" | tail -n 400 | wc -l || echo 0)
  filled=$(grep -n '状況:.*方針:.*次:' "$slot_src" | tail -n 400 | wc -l || echo 0)
  [ "${total:-0}" -gt 0 ] && slot_fill=$(awk -v f="$filled" -v t="$total" 'BEGIN{printf "%.2f", t?f/t:0}')
fi

echo "{\"ts\":\"$TS\",\"decision\":\"$decision\",\"p_value\":${p_value:-null},\"improvement\":${improvement:-null},\"samples\":${samples:-null},\"override_rate\":${override:-null},\"ppl\":${ppl:-null},\"slot_fill\":${slot_fill:-null}}" \
>> "$OUT/kpi-$DAY.jsonl"

all=$(mktemp); cat "$OUT"/kpi-*.jsonl 2>/dev/null > "$all" || true
last2=$(tail -n 2 "$all" 2>/dev/null | jq -s 'if length==2 then
{d_imp:(.[1].improvement-.[0].improvement),
 d_p:(.[1].p_value-.[0].p_value),
 d_or:(.[1].override_rate-.[0].override_rate),
 d_ppl:(.[1].ppl-.[0].ppl)} else {} end' 2>/dev/null || echo '{}')
D_IMP=$(echo "$last2" | jq -r '.d_imp // "NA"'); D_P=$(echo "$last2" | jq -r '.d_p // "NA"')
D_OR=$(echo "$last2" | jq -r '.d_or // "NA"');   D_PPL=$(echo "$last2" | jq -r '.d_ppl // "NA"')

{
echo "# HALU ダッシュボード（$TS）"
echo "- 学習PPL: **${ppl:-NA}**（直前比 ${D_PPL}）"
echo "- A/B: **Δ=${improvement:-NA}**, **p=${p_value:-NA}**, n=${samples:-NA}, override=${override:-NA}（直前比 Δ:${D_IMP} / p:${D_P} / ov:${D_OR}）"
echo
echo "## 直近7件"
printf "| 時刻 | Δ | p | n | override | ppl | slot_fill |\n|---|---:|---:|---:|---:|---:|---:|\n"
tail -n 7 "$all" 2>/dev/null | jq -r '[.ts, .improvement, .p_value, .samples, .override_rate, .ppl, .slot_fill] | @tsv' 2>/dev/null | \
awk -F'\t' '{printf("| %s | %s | %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5,$6,$7)}' || echo "| - | - | - | - | - | - | - |"
} > "$OUT/dashboard.md"

echo "[ok] updated: $OUT/dashboard.md"
