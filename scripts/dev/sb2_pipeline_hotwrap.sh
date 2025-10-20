#!/usr/bin/env bash
set -euo pipefail
bash scripts/dev/sb2_pipeline.sh >/dev/null 2>&1 || true
python3 scripts/learn/sb2_tag_inject_v2.py >/dev/null 2>&1 || true
HAS_CAND=$(tail -200 logs/policy_auto_tune.jsonl 2>/dev/null | grep -c '"event":"auto_tune_candidate"') || HAS_CAND=0
[ "${HAS_CAND:-0}" -eq 0 ] && python3 scripts/learn/sb2_tag_inject_v2_hotfix.py >/dev/null 2>&1 || true
bash scripts/learn/auto_adopt_gate_guard.sh >/dev/null 2>&1 || true
# --- [append-only] decision enrich & 5xx top routes (v2025-10-10) ---
python3 scripts/learn/decision_enrich.py >/dev/null 2>&1 || true
jq -r 'select(.status>=500) | .route // .path // "unknown"' logs/decision_enriched.jsonl 2>/dev/null \
 | awk '{c[$0]++} END{for(k in c) printf "%5d %s\n", c[k], k}' \
 | sort -nr > logs/top_5xx_routes.txt 2>/dev/null || true
# --- [append-only] sb2 candidate counters ---
jq -r 'select(.event=="auto_tune_candidate") | .confidence_tag' logs/policy_auto_tune.jsonl 2>/dev/null \
 | awk 'BEGIN{m=0;h=0}{if($1=="mid")m++; if($1=="high")h++} END{printf("[sb2] auto_tune_candidate_count mid=%d high=%d\n", m, h)}' \
 | tee -a logs/policy_auto_tune_counters.log >/dev/null 2>&1 || true
# --- [append-only] chat warmup (best-effort) ---
python3 - <<'PY' >/dev/null 2>&1 || true
import time, json, sys
# ここに将来の軽量エンドポイントがあれば差し替え。今はダミーで即終了。
time.sleep(0.05)
PY
