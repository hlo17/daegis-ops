#!/usr/bin/env bash
set -euo pipefail
cd /home/f/daegis

# ✅ 既存briefを保持（雛形上書きしない）
if [ ! -f brief.md ]; then
  ./tools/init-brief.sh
fi

# 1. クロニクルのみ更新
./tools/init-chronicle.sh

# 2. Git反映（コミット失敗時も続行）
git add -A
git commit -m "handoff: daily auto-update $(date +%F)" || true
git push

# 3. Slack投稿
./tools/rt-digest.sh
