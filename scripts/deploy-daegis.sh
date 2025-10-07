#!/bin/bash
set -Eeuo pipefail

# --- オプション: --stay で終了時に待つ（GUI起動対策）
STAY=0
if [[ "${1:-}" == "--stay" ]]; then STAY=1; shift || true; fi
if [[ ! -t 0 && ! -t 1 ]]; then STAY=1; fi
trap 'rc=$?; if (( STAY )); then echo; read -rp "Done (exit $rc). Press Enter to close..."; fi; exit $rc' EXIT

# ---- 設定
DAEGIS_DIR="${DAEGIS_DIR:-$HOME/daegis/pilot/router}"
COMPOSE="docker compose ${COMPOSE_PROJECT_NAME:+-p $COMPOSE_PROJECT_NAME}"

usage(){ echo "Usage: $0 [--stay] {up|down|logs|health}"; exit 0; }
[[ $# -ge 1 ]] || usage
CMD="$1"; shift || true
cd "$DAEGIS_DIR"

case "$CMD" in
  up)
    $COMPOSE up -d --build
    sleep 3
    docker logs router-router-1 --tail=20 || true
    ;;
  down)
    $COMPOSE down -v
    ;;
  logs)
    $COMPOSE logs -f --no-log-prefix router | stdbuf -oL sed -u 's/^/[router] /'
    ;;
  health)
    if curl -fsS http://localhost:8080/metrics | grep -q "router_up 1"; then
      echo "Health: OK (router_up=1)"
    else
      echo "Health: FAILED"; exit 1
    fi
    ;;
  *) usage ;;
esac
