#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
component="${1:?component}"
reason="${2:-""}"
ts=$(date -u +%FT%TZ)
echo "{\"ts\":\"$ts\",\"effects_chain\":[{\"triggered_component\":\"$component\",\"reason\":\"$reason\"}]}" >> docs/chronicle/effects_chain.jsonl
echo "effect added: $component ($reason)"
