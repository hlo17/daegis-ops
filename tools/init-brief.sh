#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TZ=Asia/Tokyo UPDATED="$(date +%Y-%m-%dT%H:%M%Z)"
cat > brief.md <<'MD'
# Daegis Brief — Handoff (Rolling)
updated: __UPDATED__
owner: f (@round-table)

## 1) 現在の状況
-

## 2) 次にやること (優先順)
1.

## 3) 注意点・リスク
-

## 4) 引き継ぎキーワード
- files: brief.md, docs/Daegis Chronicle.md, ops/runbooks/AI-Handoff.md
- cmds:
  -
- urls:
---
📎 固定リンク（参照用）
- Map → docs/Daegis Map.md
- Guidelines → docs/Daegis Guidelines.md
MD
python3 - "$UPDATED" <<'PY'
import sys, pathlib
p=pathlib.Path('brief.md')
p.write_text(p.read_text().replace('__UPDATED__', sys.argv[1]), encoding='utf-8')
PY
echo "✅ brief.md initialized."
