#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
# 5MB超えたら古い行を削る（ざっくり10000行だけ残す）
for f in logs/beacon_daily.log logs/worm/journal.jsonl; do
  [ -f "$f" ] || continue
  if [ $(stat -c%s "$f") -gt $((5*1024*1024)) ]; then
    tail -10000 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done
