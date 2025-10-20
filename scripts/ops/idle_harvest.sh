#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"

# ---- 安全条件: 負荷とGateを確認（観測専用なのでGate=D前提でOK）----
load1=$(awk '{print $1}' /proc/loadavg)
# RPi/小型機でも大抵OKな閾値（0.70未満）
awk "BEGIN{exit !($load1 < 0.70)}" || exit 0

# 1) 軽作業: 当日アーカイブのハッシュ索引（将来の“自己修復/再利用”の種）
d="$(date +%F)"
mkdir -p "archives/$d" logs/worm logs/solar
if [ -f "archives/$d/beacon.md" ]; then
  sha_beacon=$(sha256sum "archives/$d/beacon.md" | awk '{print $1}')
else
  sha_beacon=""
fi
if [ -f "archives/$d/dashboard_lite.md" ]; then
  sha_dash=$(sha256sum "archives/$d/dashboard_lite.md" | awk '{print $1}')
else
  sha_dash=""
fi

# 2) “静的学習素材”づくり：薄い要約 or 行数/語数だけ（重いNLPはやらない）
lines_beacon=$(wc -l < "archives/$d/beacon.md" 2>/dev/null || echo 0)
lines_dash=$(wc -l < "archives/$d/dashboard_lite.md" 2>/dev/null || echo 0)

# 3) WORMに「harvestイベント」を記録
ts=$(date -u +%FT%TZ)
printf '{"ts":"%s","event":"solar_harvest","load1":%.2f,"beacon_lines":%d,"dash_lines":%d,"beacon_sha":"%s","dash_sha":"%s"}\n' \
  "$ts" "$load1" "$lines_beacon" "$lines_dash" "$sha_beacon" "$sha_dash" >> logs/worm/journal.jsonl

# 4) Prometheus テキストファイルエクスポート（pull型; ルールは既存に追記済み想定）
mkdir -p logs/prom
prom=logs/prom/daegis_solaris.prom
cat > "$prom" <<PROM
daegis_solaris_last_run_timestamp_seconds $(date +%s)
daegis_solaris_last_load1 $load1
daegis_solaris_beacon_lines $lines_beacon
daegis_solaris_dashboard_lines $lines_dash
PROM

# 5) ローカルログ
echo "[$ts] harvest ok (load1=$load1, beacon=$lines_beacon, dash=$lines_dash)" >> logs/solar/idle_harvest.log
