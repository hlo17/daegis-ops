#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
prom="logs/prom/daegis_emotion.prom"
# 直近のmood_tag行を拾う
line=$(tac logs/worm/journal.jsonl 2>/dev/null | grep -m1 '"event":"mood_tag"')
mood=$(printf "%s" "$line" | sed -n 's/.*"mood":"\([^"]*\)".*/\1/p')
note=$(printf "%s" "$line" | sed -n 's/.*"note":"\([^"]*\)".*/\1/p')
: "${mood:=SILENCE}"
# one-hotで吐く
{
  echo "daegis_mood_current 1"
  for m in JOY FLOW FEAR AWE ANGER GRIEF LOVE SILENCE TRANSCEND; do
    v=$([ "$mood" = "$m" ] && echo 1 || echo 0)
    echo "daegis_mood_flag{mood=\"$m\"} $v"
  done
} > "$prom"
