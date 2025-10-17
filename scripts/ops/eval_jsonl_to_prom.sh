#!/usr/bin/env bash
set -euo pipefail
SRC="logs/halu/eval_events.jsonl"
OUT="logs/prom/halu_eval.prom"
mkdir -p "$(dirname "$OUT")"

# 直近5分だけを集計
since=$(date -u -d '-5 min' +%s)

# PASS/FAIL 件数（5分窓）
pass=$(awk -v s="$since" '
  BEGIN{c=0}
  { if ($0!~/^\s*$/){
      if (match($0, /"t":"([^"]+)"/, tm)){
        t=tm[1]; gsub("Z","",t); gsub("T"," ",t);
        ts=strftime("%s", t " UTC");
        if (ts>=s && $0 ~ /"outcome":"PASS"/) c++
      }
    }
  }
  END{print c}' "$SRC" 2>/dev/null || echo 0)

fail=$(awk -v s="$since" '
  BEGIN{c=0}
  { if ($0!~/^\s*$/){
      if (match($0, /"t":"([^"]+)"/, tm)){
        t=tm[1]; gsub("Z","",t); gsub("T"," ",t);
        ts=strftime("%s", t " UTC");
        if (ts>=s && $0 ~ /"outcome":"FAIL"/) c++
      }
    }
  }
  END{print c}' "$SRC" 2>/dev/null || echo 0)

# 理由別 FAIL 集計（5分窓）
tmp=$(mktemp)
awk -v s="$since" '
  { if ($0!~/^\s*$/){
      if (match($0, /"t":"([^"]+)"/, tm)){
        t=tm[1]; gsub("Z","",t); gsub("T"," ",t);
        ts=strftime("%s", t " UTC");
        if (ts>=s && $0 ~ /"outcome":"FAIL"/){
          if (match($0, /"reason":"([^"]+)"/, m)){ cnt[m[1]]++ }
        }
      }
    }
  }
  END{ for (r in cnt) printf "%s\t%d\n", r, cnt[r] }' "$SRC" > "$tmp" 2>/dev/null || true

ts=$(date +%s)
{
  echo '# TYPE daegis_halu_eval_cases_window_total counter'
  echo "daegis_halu_eval_cases_window_total{result=\"pass\",window=\"5m\"} $pass"
  echo "daegis_halu_eval_cases_window_total{result=\"fail\",window=\"5m\"} $fail"

  echo '# TYPE daegis_halu_eval_cases_reason_window_total counter'
  if [ -s "$tmp" ]; then
    while IFS=$'\t' read -r reason n; do
      printf 'daegis_halu_eval_cases_reason_window_total{result="fail",reason="%s",window="5m"} %d\n' "$reason" "$n"
    done < "$tmp"
  fi

  echo '# TYPE daegis_halu_textfile_timestamp_seconds gauge'
  echo "daegis_halu_textfile_timestamp_seconds $ts"
} > "$OUT"
rm -f "$tmp"
