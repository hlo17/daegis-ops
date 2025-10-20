#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
OUT="$ROOT/docs/agents/halu/LEVEL_PROBE_$(date -u +%Y%m%dT%H%M%SZ).md"
{
  echo "# Halu Level Probe — evidence-first"
  echo "## A) Archives hits"
  ls -1 "$ROOT"/archives/*/*halu* 2>/dev/null | sed 's/^/ - /' || echo " - (none)"
  echo
  echo "## B) Chronicle mentions (L1–L4)"
  rg -n 'Halu.*L[1-4]|L[1-4].*Halu' "$ROOT/docs/chronicle" 2>/dev/null | sed 's/^/   > /' || echo "   > (none)"
  echo
  echo "## C) Config/Runner presence"
  test -f "$ROOT/ops/remote/relay/halu_relay.py" && echo " - relay: present" || echo " - relay: (stub/absent)"
  test -f "$ROOT/config/halu_modes.yaml" && echo " - config: present" || echo " - config: (stub/absent)"
  echo
  echo "## D) Current :9091 halu*"
  (curl -fsS localhost:9091/metrics 2>/dev/null | grep '^daegis_halu_' || echo "(none)") | sed 's/^/    /'
  echo
  echo "## Inference (rule-of-thumb)"
  if grep -q '^daegis_halu_eval_cases_24h' "$ROOT/logs/prom/halu.prom" 2>/dev/null; then
    echo "- hint: >=L1（観測はある）。busや自動jobが活発ならL2+の可能性。"
  else
    echo "- hint: L0～L1（観測弱）。relay/configの実稼働復元が先。"
  fi
} > "$OUT"
echo "$OUT"
