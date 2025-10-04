#!/usr/bin/env bash
set -Eeuo pipefail
name="${1:-run}"; shift || true
[ "${1:-}" = "--" ] && shift
ts="$(date -u +%Y%m%dT%H%M%SZ)"
log="$HOME/daegis/logs/${name}_${ts}.log"

echo "[$(date -u +%FT%TZ)] logrun start: $name" | tee "$log"

rc=0
if [ $# -gt 0 ]; then
  # 引数を安全に1文字列へ（bash -lcに渡す）
  cmd="$*"
  bash -lc "$cmd" |& tee -a "$log"; rc=${PIPESTATUS[0]}
else
  # 標準入力をそのまま実行（ヒアドキュメント等の想定）
  cmd="$(cat)"
  bash -lc "$cmd" |& tee -a "$log"; rc=${PIPESTATUS[0]}
fi

echo "[$(date -u +%FT%TZ)] logrun end: rc=$rc" | tee -a "$log"
exit $rc
