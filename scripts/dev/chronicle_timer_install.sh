#!/usr/bin/env sh
# Install weekly Chronicle job: systemd timer if available, else user crontab.
set -eu
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
W="${ROOT}"
run_line="bash -lc 'cd \"$W\" && bash scripts/dev/chronicle_weekly.sh && bash scripts/dev/chronicle_weekly_notify.sh || true'"
if command -v systemctl >/dev/null 2>&1 && [ -d /etc/systemd/system ]; then
  UNIT_DIR="/etc/systemd/system"
  sudo tee "$UNIT_DIR/daegis-chronicle.service" >/dev/null <<UNIT
[Unit]
Description=Daegis Chronicle Weekly Snapshot
[Service]
Type=oneshot
ExecStart=/usr/bin/env $run_line
UNIT
  sudo tee "$UNIT_DIR/daegis-chronicle.timer" >/dev/null <<'TIMER'
[Unit]
Description=Run Daegis Chronicle weekly
[Timer]
OnCalendar=Sun *-*-* 00:10:00 UTC
Persistent=true
[Install]
WantedBy=timers.target
TIMER
  sudo systemctl daemon-reload
  sudo systemctl enable --now daegis-chronicle.timer
  systemctl list-timers --all | grep -E 'daegis-chronicle\.timer' || true
  echo "[chronicle] systemd timer installed"
else
  echo "[chronicle] systemd not present → install user crontab entry"
  (crontab -l 2>/dev/null | grep -v 'daegis-chronicle' ; echo '10 0 * * 0 cd '"$W"' && '"$run_line"' # daegis-chronicle') | crontab -
  crontab -l | tail -1
  echo "[chronicle] crontab installed"
fi
exit 0