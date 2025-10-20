#!/usr/bin/env bash
set -euo pipefail
ROOT="${HOME}/daegis"
PROM="${ROOT}/logs/prom/halu.prom"
TMP="$(mktemp)"
now="$(date -u +%s)"
ok=1

musts=("docs/agents/halu/agent.md" "logs/prom/halu.prom" "config/halu_modes.yaml" "ops/remote/relay/halu_relay.py")
missing=0
for p in "${musts[@]}"; do
  [[ -e "${ROOT}/${p}" ]] || { echo "MISS:${p}" >&2; missing=1; ok=0; }
done

age_prom=0
[[ -f "$PROM" ]] && age_prom=$(( now - $(date -r "$PROM" +%s 2>/dev/null || echo $now) ))

# halu.prom を更新（値はDRYでも0/1で点灯）
{
  echo '# HELP daegis_halu_sentry_ok 1=healthy 0=problem'
  echo '# TYPE daegis_halu_sentry_ok gauge'
  echo "daegis_halu_sentry_ok ${ok}"
  echo '# HELP daegis_halu_textfile_age_seconds seconds since halu.prom last write'
  echo '# TYPE daegis_halu_textfile_age_seconds gauge'
  echo "daegis_halu_textfile_age_seconds ${age_prom}"

  # 既存の daegis_halu_* を保ちつつ、空なら 0 を入れる
  pass="$(awk '/^daegis_halu_eval_pass_ratio_1h/{print $2}' "$PROM" 2>/dev/null || true)"
  echo '# HELP daegis_halu_eval_pass_ratio_1h Halu pass ratio (1h avg; DRY default 0)'
  echo '# TYPE daegis_halu_eval_pass_ratio_1h gauge'
  echo "daegis_halu_eval_pass_ratio_1h ${pass:-0}"

  oneh="$(awk -F'[ {}]+' '/^daegis_halu_eval_cases_1h/{print $NF}' "$PROM" 2>/dev/null || true)"
  echo '# HELP daegis_halu_eval_cases_1h Cases (1h total; DRY default 0)'
  echo '# TYPE daegis_halu_eval_cases_1h gauge'
  echo "daegis_halu_eval_cases_1h{status=\"total\"} ${oneh:-0}"

  day="$(awk -F'[ {}]+' '/^daegis_halu_eval_cases_24h/{print $NF}' "$PROM" 2>/dev/null || true)"
  echo '# HELP daegis_halu_eval_cases_24h Cases (24h total; DRY default 0)'
  echo '# TYPE daegis_halu_eval_cases_24h gauge'
  echo "daegis_halu_eval_cases_24h{status=\"total\"} ${day:-0}"

  echo '# HELP daegis_halu_info meta'
  echo '# TYPE daegis_halu_info gauge'
  echo 'daegis_halu_info{source="sentry",mode="DRY"} 1'
} > "$TMP"
mv "$TMP" "$PROM"

# WORMに一行証跡
mkdir -p "${ROOT}/logs/worm"
jq -n --arg ts "$(date -u +%FT%TZ)" --arg event "halu_sentry" \
      --arg ok "$ok" --argjson miss "$missing" \
      '{ts:$ts,event:$event,ok:($ok|tonumber),missing:$miss}' >> "${ROOT}/logs/worm/journal.jsonl"

# 0=OK, 1=missingあり
exit $((missing))
