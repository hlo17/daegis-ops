#!/usr/bin/env bash
set -euo pipefail
AB=/srv/round-table/ab-result.json
p=$(jq -r '.reason.p_value // .kpi.p_value // empty' "$AB" 2>/dev/null || true)
d=$(jq -r '.kpi.improvement // .reason.improvement // empty' "$AB" 2>/dev/null || true)
[ -z "${SLACK_WEBHOOK_URL:-}" ] && exit 0
awk 'BEGIN{p='"${p:-999}"';d='"${d:-0}"';
 if (p<0.05 && d>=0.10) print 1; else print 0}' | grep -q 1 || exit 0
# 条件を満たしたら学習もキック
systemctl --user start halu-train.service || true

# ついでに「開始」を通知
[ -n "${SLACK_WEBHOOK_URL:-}" ] && jq -n --arg p "$p" --arg d "$d" \
  '{text:("[HALU][KPI] 🚀 retrain triggered (Δ="+$d+", p="+$p+")")}' \
 | curl -fsS -X POST -H 'Content-type: application/json' --data @- "$SLACK_WEBHOOK_URL" >/dev/null || true
