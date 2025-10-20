#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/daegis/logs/prom/halu.prom"
TMP="$(mktemp)"

# 9090 から拾えれば拾う。無ければ0でDRY点灯
pass="$(curl -fsS localhost:9090/metrics 2>/dev/null | awk -F' ' '/^halu_eval_pass_ratio[ \t]/{print $2; exit}' || echo 0)"
case_pass_1h="$(curl -fsS 'http://localhost:9090/api/v1/query?query=increase(halu_eval_cases_total%5B1h%5D)' 2>/dev/null \
  | jq -r '.data.result[]?.value[1]' 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo 0)"
case_pass_24h="$(curl -fsS 'http://localhost:9090/api/v1/query?query=increase(halu_eval_cases_total%5B24h%5D)' 2>/dev/null \
  | jq -r '.data.result[]?.value[1]' 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo 0)"

{
  echo '# HELP daegis_halu_eval_pass_ratio_1h Halu pass ratio (1h avg)'
  echo '# TYPE daegis_halu_eval_pass_ratio_1h gauge'
  printf 'daegis_halu_eval_pass_ratio_1h %s\n' "${pass}"

  echo '# HELP daegis_halu_eval_cases_1h Cases in 1h by status (approx, DRY)'
  echo '# TYPE daegis_halu_eval_cases_1h gauge'
  printf 'daegis_halu_eval_cases_1h{status="total"} %s\n' "${case_pass_1h}"

  echo '# HELP daegis_halu_eval_cases_24h Cases in 24h by status (approx, DRY)'
  echo '# TYPE daegis_halu_eval_cases_24h gauge'
  printf 'daegis_halu_eval_cases_24h{status="total"} %s\n' "${case_pass_24h}"

  echo '# HELP daegis_halu_info meta'
  echo '# TYPE daegis_halu_info gauge'
  printf 'daegis_halu_info{source="mirror_9090",mode="DRY"} 1\n'
} > "$TMP"

mv "$TMP" "$OUT"
