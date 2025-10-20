#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
LEGACY_TGZ=$(ls -1t "$ROOT"/archives/*halu-legacy.tgz | head -n1)
[ -n "${LEGACY_TGZ:-}" ] || { echo "[ERR] legacy tgz not found"; exit 2; }

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# 展開せずにパスを特定 → 必要最小だけ取り出す
LEG_AGENT=$(tar -tzf "$LEGACY_TGZ" | grep -E '/agent\.md$' | head -n1 || true)
[ -n "$LEG_AGENT" ] || { echo "[ERR] agent.md not found in tgz"; exit 3; }

tar -xzf "$LEGACY_TGZ" -C "$TMPDIR" "$LEG_AGENT"
NOTE=$(head -n20 "$TMPDIR/$LEG_AGENT" | grep -v '^#' | tr '\n' ' ' | sed 's/"/\\"/g')

UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"t\":\"${UTC}\",\"act\":\"legacy-reflect\",\"note\":\"${NOTE}\"}" >> "$ROOT/logs/halu/reflection.jsonl"
echo "[OK] reflection appended from legacy agent.md"
