#!/usr/bin/env sh
set -eu
# Reflex v2: robust streak detector (no tac dependency; jq optional)
SRC="${SRC:-logs/decision.jsonl}"
HOLD_N="${HOLD_N:-3}"
E5XX_N="${E5XX_N:-2}"
[ -f "$SRC" ] || { echo "[reflex] missing $SRC"; exit 0; }
tail -200 "$SRC" > /tmp/dec.tail.$$ || true
has_jq=0; command -v jq >/dev/null 2>&1 && has_jq=1
# reverse lines portable
awk '1{buf[NR]=$0} END{for(i=NR;i>=1;i--) print buf[i]}' /tmp/dec.tail.$$ > /tmp/dec.rev.$$
hold=0; err=0
if [ $has_jq -eq 1 ]; then
  jq -cr '. as $l | {e:(.ethics.verdict//""),s:(.status//200)} | "\(.e)|\(.s)"' /tmp/dec.rev.$$ \
  | while IFS='|' read -r e s; do
      [ "$e" = "HOLD" ] && hold=$((hold+1)) || hold=0
      [ "${s:-200}" -ge 500 ] && err=$((err+1)) || err=0
      echo "$hold $err"
    done | tail -1 > /tmp/streak.$$
else
  awk -F'"' '
    /"ethics":/ {e=$0~/"HOLD"/?"HOLD":"X"}
    /"status":/ {match($0,/"status": *([0-9]+)/,m); s=m[1]+0; print e "|" s}
  ' /tmp/dec.rev.$$ \
  | awk -F'|' '{if($1=="HOLD") h++; else h=0; if($2>=500) e++; else e=0; print h, e}' \
  | tail -1 > /tmp/streak.$$
fi
read H E </tmp/streak.$$ || { H=0; E=0; }
rm -f /tmp/dec.tail.$$ /tmp/dec.rev.$$ /tmp/streak.$$
[ "${H:-0}" -ge "$HOLD_N" ] && bash scripts/guard/alert_hook.sh "HOLD x$H (>=${HOLD_N})" || true
[ "${E:-0}" -ge "$E5XX_N" ] && bash scripts/guard/alert_hook.sh "HTTP_5XX x$E (>=${E5XX_N})" || true
exit 0