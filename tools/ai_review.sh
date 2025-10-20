#!/usr/bin/env bash
echo "== mini_brief =="; sed -n "1,20p" docs/chronicle/brief.md 2>/dev/null || true
if [ -f docs/agents/AEGIS.parlance.md ]; then echo "== aegis_parlance =="; sed -n "1,120p" docs/agents/AEGIS.parlance.md; fi
if [ -f docs/agents/assistant_profile.md ]; then
  echo "== assistant_profile =="
  sed -n "1,160p" docs/agents/assistant_profile.md
fi
set -euo pipefail
cd "$HOME/daegis"
topic="${1:-general}"
echo "[review] topic=$topic"
# レビュー対象の要約（軽量）：beacon最新・差分ファイルリスト
echo "== beacon (rollup) =="; sed -n '1,80p' docs/chronicle/beacon.md 2>/dev/null || true
echo "== git diff --name-status (last commit) =="; git diff --name-status HEAD~1..HEAD || true
# Introspect に「/review 起票済み」を残す（AIが拾う）
mkdir -p inbox/ai_to_human
ts=$(date -u +%FT%TZ)
printf '{"ts":"%s","event":"review_request","topic":"%s"}\n' "$ts" "$topic" >> logs/worm/journal.jsonl
