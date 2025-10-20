#!/usr/bin/env bash
set -Eeuo pipefail
cmd="${1:-status}"

case "$cmd" in
  queue)
    ls -1 ops/factory/queue/*.json 2>/dev/null || echo "(empty)"
    ;;
  run)
    f="${2:-}"; [[ -z "$f" ]] && { echo "usage: guardian factory run ops/factory/queue/<job>.json"; exit 2; }
    ops/factory/run_job.sh "$f"
    ;;
  status)
    jf="logs/factory_jobs.jsonl"
    [[ -s "$jf" ]] || { echo "jobs_ok: 0"; echo "jobs_fail: 0"; echo "jobs_deny: 0"; echo "jobs_dry: 0"; exit 0; }
    ok=$(jq -s '[.[]|select(.event=="job_end")|select((.rc//1)==0)]|length' "$jf")
    fail=$(jq -s '[.[]|select(.event=="job_end")|select((.rc//0)!=0)]|length' "$jf")
    deny=$(jq -s '[.[]|select(.event=="deny")]|length' "$jf")
    dry=$(jq -s '[.[]|select(.event=="dry_ok")]|length' "$jf")
    echo "jobs_ok:    $ok"
    echo "jobs_fail:  $fail"
    echo "jobs_deny:  $deny"
    echo "jobs_dry:   $dry"
    ;;
  *)
    echo "guardian factory {queue|run <file>|status}"
    ;;
esac
