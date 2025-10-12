#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"

# cronでも見つかるようにPATHを補強（予防線）
export PATH="$HOME/bin:$HOME/daegis/scripts/guardian:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# 1) Beacon（絶対パスで実行）
if command -v guardian >/dev/null 2>&1; then
  guardian beacon >> logs/beacon_daily.log 2>&1 || true
else
  "$HOME/daegis/scripts/guardian/guardian" beacon >> logs/beacon_daily.log 2>&1 || true
fi

# 2) WORMアーカイブ
d="$(date +%F)"
mkdir -p "archives/$d"
cp -f docs/chronicle/beacon.md "archives/$d/beacon.md" 2>/dev/null || true

# （任意・推奨）ダッシュ証跡も添えておくと「dash_snapshot_today」が欠落しません
if [ -f docs/runbook/dashboard_lite.md ]; then
  cp -f docs/runbook/dashboard_lite.md "archives/$d/dashboard_lite.md" 2>/dev/null || true
fi

# 3) WORMジャーナル
mkdir -p logs/worm
sha=$(sha256sum "archives/$d/beacon.md" 2>/dev/null | awk '{print $1}')
ts=$(date -u +%FT%TZ)
printf '{"ts":"%s","event":"worm_beacon","sha":"%s","path":"archives/%s/beacon.md"}\n' "$ts" "$sha" "$d" >> logs/worm/journal.jsonl

# （ダッシュ証跡も記録）
if [ -f "archives/$d/dashboard_lite.md" ]; then
  sha_dash=$(sha256sum "archives/$d/dashboard_lite.md" | awk '{print $1}')
  printf '{"ts":"%s","event":"worm_snapshot","path":"archives/%s/dashboard_lite.md","sha256":"%s"}\n' "$ts" "$d" "$sha_dash" >> logs/worm/journal.jsonl
fi

# 4) 軽いローテ（WORM=保存→期限後整理という運用）
find archives -type f -mtime +21 -delete >/dev/null 2>&1 || true
bash "$HOME/daegis/scripts/ops/beacon_delta.sh" >> logs/beacon_daily.log 2>&1 || true
