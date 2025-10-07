#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
install -d docs
TOD="$(TZ=Asia/Tokyo date +%Y-%m-%d)"
if ! grep -q "^## ${TOD}\b" "docs/Daegis Chronicle.md" 2>/dev/null; then
  cat >> "docs/Daegis Chronicle.md" <<EOF

## ${TOD}
-

### Decisions
- ${TOD}:  —
EOF
  echo "✅ Chronicle appended for ${TOD}"
else
  echo "ℹ️ docs/Daegis Chronicle.md already has ${TOD} block. No changes."
fi
