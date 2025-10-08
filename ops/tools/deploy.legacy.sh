#!/usr/bin/env bash
# shellcheck disable=SC2221,SC2222  # caseパターンの意図的な順序
#!/usr/bin/env bash
# === Daegis Deploy Helper v3 (sudo/remote-safe + extra hooks) ===
set -euo pipefail
TARGET="${SAVE_TO:?SAVE_TO を指定してください}"
: "${RUN:=0}"; : "${ARGS:=}"; : "${BACKUP:=1}"; : "${HOOKS:=0}"; : "${QUIET:=0}"

log(){ [ "$QUIET" = "1" ] || echo -e "$@"; }
need_sudo(){ [ -w "$(dirname "$1")" ] && { [ ! -e "$1" ] || [ -w "$1" ]; } || [ "$(id -u)" = "0" ] || return 0; return 1; }

# --- ensure dir ---
DIR=$(dirname -- "$TARGET")
if [ ! -d "$DIR" ]; then
  if need_sudo "$DIR"; then sudo mkdir -p -- "$DIR"; else mkdir -p -- "$DIR"; fi
fi

# --- backup ---
if [ -f "$TARGET" ] && [ "$BACKUP" = "1" ]; then
  ts=$(date +"%Y%m%d-%H%M%S")
  if need_sudo "$TARGET"; then sudo cp -a -- "$TARGET" "${TARGET}.bak-${ts}"; else cp -a -- "$TARGET" "${TARGET}.bak-${ts}"; fi
  log "🧷 Backup  : ${TARGET}.bak-${ts}"
fi

# --- write atomically ---
tmp=$(mktemp)
cat > "$tmp"; printf '' >> "$tmp"

if need_sudo "$TARGET"; then
  # keep executable bit
  sudo install -m 0755 "$tmp" "$TARGET"
else
  mv -- "$tmp" "$TARGET"
  chmod +x "$TARGET"
fi

log "✅ Saved   : $TARGET"
log "🔐 Mode    : +x"

# --- hooks ---
if [ "$HOOKS" = "1" ]; then
  case "$TARGET" in
    /etc/systemd/system/*.service)
      svc="$(basename "$TARGET" .service)"
      if command -v systemctl >/dev/null 2>&1; then
        log "🛠  systemd: daemon-reload & enable --now ${svc}"
        sudo systemctl daemon-reload
        sudo systemctl enable --now "$svc"
        sudo systemctl status "$svc" --no-pager -l || true
      fi
      ;;
    /etc/mosquitto/*.conf|/etc/mosquitto/conf.d/*.conf)
      if command -v systemctl >/dev/null 2>&1; then
        log "🛠  mosquitto: restart"
        sudo systemctl restart mosquitto
        sudo systemctl status mosquitto --no-pager -l | sed -n '1,25p' || true
      fi
      ;;
    /etc/cloudflared/*|/etc/cloudflared/*.yml|/etc/cloudflared/*.yaml)
      if command -v systemctl >/dev/null 2>&1; then
        log "🛠  cloudflared: restart"
        sudo systemctl restart cloudflared
        sudo systemctl status cloudflared --no-pager -l | sed -n '1,25p' || true
      fi
      ;;
  esac
fi

# --- run ---
if [ "$RUN" = "1" ]; then
  log "🏃 Run     : $TARGET ${ARGS}"
  set +e
  if [ -x "$TARGET" ]; then "$TARGET" "${ARGS:-}"; rc=$?; else bash "$TARGET" "${ARGS:-}"; rc=$?; fi
  set -e
if [ "$rc" -eq 0 ]; then log "✅ 実行完了"; else log "❌ 実行エラー: $rc"; exit "$rc"; fi
else
  log "👉 実行    : $TARGET ${ARGS}"
fi
