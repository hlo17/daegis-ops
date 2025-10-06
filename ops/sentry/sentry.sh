#!/usr/bin/env bash
set -euo pipefail

case "${1:-check}" in
  check)
    ROOT="$HOME/daegis"
    cd "$ROOT"

    # 1) Git 未コミット/未ステージの検出
    if ! git -C "$ROOT" diff --quiet || ! git -C "$ROOT" diff --cached --quiet; then
      echo "[sentry] git: uncommitted changes"
      git -C "$ROOT" status --short || true
      exit 10
    fi

    # 2) 巨大ログ検出（100MB超）
    big=$(find "$ROOT/ark/logbook" -type f -size +100M -print 2>/dev/null | head -1 || true)
    if [ -n "${big:-}" ]; then
      echo "[sentry] big log: $big"
      exit 11
    fi

    echo "[sentry] ok"
    ;;
  *)
    echo "usage: sentry.sh [check]"
    exit 2
    ;;
esac
