#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
prom="logs/prom/daegis_failure_museum.prom"
# “失敗”候補：DNAのng、window_send送信失敗、playgroundのbrokenリンク>0 などを数える
dna_ng=$(grep -c '"ng":' logs/dna_validate.log 2>/dev/null || echo 0)
send_err=$(grep -c '"status":"ERROR"' logs/window_send.jsonl 2>/dev/null || echo 0)
play_broken=$(grep -h 'broken_links=' logs/playground/*.log 2>/dev/null | awk -F= '{s+=$2} END{print s+0}')
{
  echo "daegis_failure_museum_total $(($dna_ng + $send_err + $play_broken))"
  echo "daegis_failure_playground_broken $play_broken"
  echo "daegis_failure_window_send_error $send_err"
  echo "daegis_failure_dna_ng $dna_ng"
} > "$prom"
