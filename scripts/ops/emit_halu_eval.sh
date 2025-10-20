#!/usr/bin/env bash
set -euo pipefail
# 使い方:
#   emit               # 現在の累積で .prom を再出力
#   pass <reason>      # 例: pass grammar
#   fail <reason>      # 例: fail hallucination

STATE_DIR="$HOME/daegis/state"
STATE_MAIN="$STATE_DIR/halu_eval_total.tsv"
STATE_REASON="$STATE_DIR/halu_eval_reason_total.tsv"
OUT="$HOME/daegis/logs/prom/halu_eval.prom"

mkdir -p "$STATE_DIR" "$(dirname "$OUT")"
[[ -s "$STATE_MAIN"  ]] || printf "pass\t0\nfail\t0\n" > "$STATE_MAIN"
[[ -s "$STATE_REASON" ]] || : > "$STATE_REASON"

cmd="${1:-emit}"
arg="${2:-unknown}"
inc_main() {
  local res="$1"
  awk -v k="$res" 'BEGIN{OFS="\t"} {c[$1]=$2} END{
    c[k]=c[k]+0+1;
    print "pass", (c["pass"]+0);
    print "fail", (c["fail"]+0)
  }' "$STATE_MAIN" > "$STATE_MAIN.tmp"
  mv "$STATE_MAIN.tmp" "$STATE_MAIN"
}

inc_reason() {
  local res="$1" reason="$2"
  if [[ -s "$STATE_REASON" ]]; then
    awk -v r="$res" -v z="$reason" 'BEGIN{OFS="\t"} {k=$1"\t"$2; c[k]=$3}
      END{
        c[r"\t"z]=c[r"\t"z]+0+1;
        for (k in c){split(k,a,"\t"); print a[1],a[2],c[k]}
      }' "$STATE_REASON" > "$STATE_REASON.tmp"
  else
    printf "%s\t%s\t1\n" "$res" "$reason" > "$STATE_REASON.tmp"
  fi
  mv "$STATE_REASON.tmp" "$STATE_REASON"
}
case "$cmd" in
  pass|fail)
    inc_main "$cmd"
    inc_reason "$cmd" "$arg"
    ;;
  emit) : ;;
  *) echo "usage: $0 [pass <reason>|fail <reason>|emit]" >&2; exit 1 ;;
esac

P=$(awk '$1=="pass"{print $2}' "$STATE_MAIN")
F=$(awk '$1=="fail"{print $2}' "$STATE_MAIN")
TS=$(date +%s)

{
  echo '# TYPE daegis_halu_eval_cases_total counter'
  echo "daegis_halu_eval_cases_total{result=\"pass\"} $P"
  echo "daegis_halu_eval_cases_total{result=\"fail\"} $F"

  echo '# TYPE daegis_halu_eval_cases_reason_total counter'
  awk 'BEGIN{OFS=""} {printf "daegis_halu_eval_cases_reason_total{result=\"%s\",reason=\"%s\"} %d\n",$1,$2,$3}' "$STATE_REASON" 2>/dev/null || true

  echo '# TYPE daegis_halu_textfile_timestamp_seconds gauge'
  echo "daegis_halu_textfile_timestamp_seconds $TS"
} > "$OUT"
