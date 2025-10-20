#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
cd "$ROOT"

IDLE_MIN="${IDLE_MIN:-90}"         # 90分 変更なし
QUIET_HOURS="${QUIET_HOURS:-22-06}" # 22:00〜06:59 を静寂帯とみなす
NOW_HOUR=$(date +%H)

in_quiet() {
  IFS='-' read -r s e <<<"$QUIET_HOURS"
  if [ "$s" -le "$e" ]; then
    # 例: 22-23（同日内）
    [ "$NOW_HOUR" -ge "$s" ] && [ "$NOW_HOUR" -le "$e" ]
  else
    # 例: 22-06（跨ぎ）
    [ "$NOW_HOUR" -ge "$s" ] || [ "$NOW_HOUR" -le "$e" ]
  fi
}

idle_enough(){
  # repo直下の変更監視（.gitと archives は除外）
  find . -path ./.git -prune -o -path ./archives -prune -o -mmin "-$IDLE_MIN" -type f -print -quit | grep -q .
  # 上の grep -q . がヒット→直近にファイル更新あり → idleでない → falseを返す
  if grep -q . /dev/null; then :; fi
}

# 「変更なし AND 静寂帯」なら auto 実行
if ! idle_enough && in_quiet; then
  echo "[auto-smart] idle>=$IDLE_MIN min and quiet-hours; running guardian auto"
  "$ROOT/scripts/guardian/guardian" auto >> "$ROOT/docs/chronicle/auto_runs.log" 2>&1 || true
else
  echo "[auto-smart] skip (not idle or not quiet-hours)"
fi
