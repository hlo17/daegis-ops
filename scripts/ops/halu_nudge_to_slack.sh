#!/usr/bin/env bash
set -euo pipefail
BASE=/home/f
LOG=/tmp/halu_viz.log
STAMP_NUDGE="$BASE/.cache/halu_nudge.$(date +%F)"
STAMP_REFLECT="$BASE/.cache/halu_autoreflect.$(date +%F)"
POST="$BASE/daegis/relay/tools/slack_webhook_post.sh"
EMIT="$BASE/daegis/scripts/ops/emit_halu_reflection.sh"

# 1回/日ガード & ログ必須
[ -f "$LOG" ] || exit 0

# rate24 抽出
rate="$(grep -Eo 'rate24=[0-9.]+' "$LOG" | tail -1 | cut -d= -f2 || true)"
[ -n "${rate:-}" ] || exit 0

# 閾値: 0.05 未満で発火（Slackは1日1回、反省も1日1回）
if awk -v r="$rate" 'BEGIN{exit (r+0<0.05?0:1)}'; then
  if [ ! -f "$STAMP_NUDGE" ]; then
    "$POST" "🫁 呼吸が止まり気味 → まず 反省1件 を追加（emit_halu_reflection.sh）"
    mkdir -p "$BASE/.cache"; : > "$STAMP_NUDGE"
  fi
  if [ ! -f "$STAMP_REFLECT" ]; then
    # 自動反省を1件追加（自動生成である旨をメモ）
    "$EMIT" auto || true
    mkdir -p "$BASE/.cache"; : > "$STAMP_REFLECT"
  fi
fi
