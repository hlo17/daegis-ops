#!/usr/bin/env bash
set -Eeuo pipefail
d=$(date +%F); dir="archives/$d"; mkdir -p "$dir" logs/worm
for f in docs/runbook/dashboard_lite.md logs/factory_jobs.jsonl ops/factory/genome_index.jsonl; do
[[ -f "$f" ]] || continue
cp "$f" "$dir/" 2>/dev/null || true
sha=$(sha256sum "$dir/$(basename "$f")" 2>/dev/null | awk '{print $1}')
printf '{"ts":%s,"event":"worm_snapshot","path":"%s","sha256":"%s"}\n' "$(date +%s)" "$dir/$(basename "$f")" "${sha:-NA}" >> logs/worm/journal.jsonl
done
echo "[worm] snap -> $dir"
