hk_open_handbook(){ ${PAGER:-less} ops/runbooks/AI-Handoff.md; }
hk_rt_daily(){
  curl -fsS -X POST "${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}" \
    -H "content-type: application/json" -d '{"task":"daily test"}' | jq . || echo "[orchestrate] NG"
}
hk_kpi_avg(){ tools/kpi-avg.sh "$@"; }
