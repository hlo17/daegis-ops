#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"; cd "$ROOT"
TODAY=$(date -u +%Y%m%d); ARCHDIR="archives/${TODAY}"
OUT="${ARCHDIR}/halu_snapshot.tar.gz"
mkdir -p "${ARCHDIR}" docs/ledger logs/worm
tar -czf "${OUT}" docs/agents/halu/agent.md logs/halu logs/worm 2>/dev/null || true
SHA=$(sha256sum "${OUT}" | awk '{print $1}')
UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"t\":\"${UTC}\",\"act\":\"snapshot\",\"path\":\"${OUT}\",\"sha\":\"${SHA}\",\"affect\":\"SILENCE\",\"stage\":\"L1\"}" >> docs/ledger/halu.jsonl
echo "{\"t\":\"${UTC}\",\"source\":\"halu_snapshot\",\"path\":\"${OUT}\",\"sha\":\"${SHA}\"}" >> logs/worm/journal.jsonl
echo "[OK] snapshot -> ${OUT}"
