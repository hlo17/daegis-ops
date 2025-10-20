#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
echo "== Guardian =="
guardian status || true
echo; echo "== Introspect (latest) =="
jq -r '.[]|[.id,.status,.to,.topic]|@tsv' docs/chronicle/introspect.latest.jsonl 2>/dev/null || true
echo; echo "== Beacon tail =="
tail -20 logs/beacon_daily.log 2>/dev/null || true
echo; echo "== WORM tail =="
tail -10 logs/worm/journal.jsonl 2>/dev/null || true

echo; echo "== Today WORM presence =="
d="$(date +%F)"; grep -q "archives/$d/" logs/worm/journal.jsonl && echo "OK: entries found for $d" || echo "WARN: no entries for $d"
