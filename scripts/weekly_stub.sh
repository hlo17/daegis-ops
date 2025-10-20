#!/usr/bin/env bash
set -euo pipefail
W="$HOME/daegis/reports/weekly_review_$(date -u +%G-W%V).md"
test -s "$W" || cat >"$W" <<'MD'
# Weekly Review (YYYY-Www)
- 心拍健全性（avg age / alerts）:
- 反射の量（1h 窓の最大/平均）:
- 今週の改善（<=3）:
- 来週の 1 改善（=1）:
MD
echo "created $W"
