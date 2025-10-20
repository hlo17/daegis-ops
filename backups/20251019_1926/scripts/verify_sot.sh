#!/usr/bin/env bash
set -euo pipefail
root="$HOME/daegis"
phase_tag="$(cat "$root/phase_tag.txt" 2>/dev/null || cat "$root/docs/chronicle/phase_tag.txt" 2>/dev/null || echo missing)"
rollup_phase="$(jq -r '.phase // empty' "$root/rollup/current.json" 2>/dev/null || jq -r '.phase // empty' "$root/docs/rollup/current.json" 2>/dev/null || echo missing)"
halu_state="$(cat "$root/flags/L7_HALU_STATE" 2>/dev/null || echo missing)"

echo "phase_tag.txt:   $phase_tag"
echo "rollup.current:  $rollup_phase"
echo "L7_HALU_STATE:   $halu_state"

consistent=1
[[ "$phase_tag" = "$rollup_phase" && "$phase_tag" != "missing" ]] || consistent=0
echo "daegis_sot_consistent $consistent" > /tmp/daegis_sot.prom

# node_exporter textfile_collector へ反映（あるなら）
if [ -d /var/lib/node_exporter/textfile_collector ]; then
  sudo mv /tmp/daegis_sot.prom /var/lib/node_exporter/textfile_collector/daegis_sot.prom
fi

# 運用上の注意喚起（ログ終了コードは成功のままにする）
if [ $consistent -eq 0 ]; then
  echo "WARNING: SOT mismatch"
fi

