#!/usr/bin/env sh
# L6: Autonomous Audit & Gate Revoke (standalone; append-only; stdlib tools)
set -eu
SRC="logs/decision.jsonl"
OUT="logs/policy_apply_revoke.jsonl"
ENVF="${L6_ENV_FILE:-scripts/dev/env_local.sh}"
H="${L6_REVOKE_HOLD_STREAK:-5}"
E="${L6_REVOKE_5XX_STREAK:-2}"
BASE="${L6_BASELINE_SLA_MS:-3000}"
TS="$(date -u +%FT%TZ)"
[ -f "$SRC" ] || { echo "[L6] missing $SRC"; exit 0; }
tail -200 "$SRC" > /tmp/dec.tail.$$ || true
hold=0 err=0
if command -v jq >/dev/null 2>&1; then
  tac /tmp/dec.tail.$$ | jq -cr '{e:(.ethics.verdict//""),s:(.status//200)}|"\(.e)|\(.s)"' \
  | while IFS='|' read -r e s; do
      [ "${e:-}" = "HOLD" ] && hold=$((hold+1)) || hold=0
      [ "${s:-200}" -ge 500 ] && err=$((err+1)) || err=0
      printf "%s %s\n" "$hold" "$err"
    done | tail -1 > /tmp/streak.$$
else
  tac /tmp/dec.tail.$$ | awk -F'"' '
    /"ethics":/ {e=$0~/"HOLD"/?"HOLD":"X"}
    /"status":/ {match($0,/"status": *([0-9]+)/,m); s=m[1]+0; print e "|" s}
  ' | awk -F'|' '{if($1=="HOLD") h++; else h=0; if($2>=500) e++; else e=0; print h, e}' | tail -1 > /tmp/streak.$$
fi
read HST EST </tmp/streak.$$ || { HST=0; EST=0; }
rm -f /tmp/dec.tail.$$ /tmp/streak.$$
if [ "${HST:-0}" -ge "$H" ] || [ "${EST:-0}" -ge "$E" ]; then
  mkdir -p logs "$(dirname "$ENVF")"
  printf '{"event":"policy_revoke","ts":"%s","hold_streak":%s,"e5xx_streak":%s,"baseline_sla_ms":%s}\n' "$TS" "${HST:-0}" "${EST:-0}" "${BASE}" >> "$OUT"
  {
    echo "# [L6 revoke] $TS HOLD=$HST 5xx=$EST"
    echo "export DAEGIS_SLA_DEFAULT_MS=${BASE}"
  } >> "$ENVF"
  bash scripts/guard/alert_hook.sh "L6 REVOKE: HOLD=$HST 5xx=$EST -> SLA=${BASE}" 2>/dev/null || true
  echo "[L6] revoke appended: SLA=${BASE}"
else
  echo "[L6] OK: hold=$HST err=$EST (H>=$H, 5xx>=$E)"
fi
exit 0