#!/usr/bin/env bash
set -euo pipefail
src="$HOME/daegis/logs/factory_jobs.jsonl"
. "$HOME/daegis/scripts/lib/prom_emit.sh"

# ない場合はゼロ埋め
if [ ! -f "$src" ]; then
  OK=0; FAIL=0; DRY=0; DENY=0
else
  # ok/fail: event=="job_end" を対象に rc と dry_run を見る
  # dry: job_start/job_end に dry_run true が関与したジョブをカウント（エンド優先）
  # deny: event=="deny"
  OK=$(jq -r 'select(.event=="job_end" and (.dry_run|not) and ((.rc=="0") or (.rc|tostring=="0"))) | 1' "$src" 2>/dev/null | wc -l | awk '{print $1}')
  FAIL=$(jq -r 'select(.event=="job_end" and (.dry_run|not) and ((.rc!="0") and (.rc|tostring!="0"))) | 1' "$src" 2>/dev/null | wc -l | awk '{print $1}')
  DRY=$(jq -r 'select((.event=="job_end" or .event=="job_start") and (.dry_run==true)) | 1' "$src" 2>/dev/null | wc -l | awk '{print $1}')
  DENY=$(jq -r 'select(.event=="deny") | 1' "$src" 2>/dev/null | wc -l | awk '{print $1}')
fi

emit_gauge 'daegis_factory_jobs_total{result="ok"}'   "$OK"   "daegis_factory"
emit_gauge 'daegis_factory_jobs_total{result="fail"}' "$FAIL" "daegis_factory"
emit_gauge 'daegis_factory_jobs_total{result="deny"}' "$DENY" "daegis_factory"
emit_gauge 'daegis_factory_jobs_total{result="dry"}'  "$DRY"  "daegis_factory"

# 付随INFO（1行だけ／属性はラベルへ）
ts=$(date -u +%FT%TZ)
emit_gauge "daegis_factory_info{source=\"ledger\",updated=\"$ts\"}" 1 "daegis_factory"
echo "[emit_factory_prom] ok=$OK fail=$FAIL deny=$DENY dry=$DRY ts=$ts"
