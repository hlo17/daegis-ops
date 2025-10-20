#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
LED="$ROOT/docs/ledger/halu.jsonl"
BUS="$ROOT/logs/halu/bus.jsonl"
TPL="$ROOT/ops/intent/templates/reflect_digest.json"
ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
read -r SUMMARY < <(jq -r .summary "$TPL")
echo "{\"t\":\"$ISO\",\"act\":\"intent.propose\",\"id\":\"reflect_digest_hourly\",\"summary\":\"$SUMMARY\",\"stage\":\"L3\"}" >> "$LED"
echo "{\"ts\":$(date +%s),\"agent\":\"halu\",\"event\":\"intent.propose\",\"id\":\"reflect_digest_hourly\"}" >> "$BUS"
echo "[OK] proposed: reflect_digest_hourly"
