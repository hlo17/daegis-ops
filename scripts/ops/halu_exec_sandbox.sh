#!/usr/bin/env bash
set -euo pipefail
ID="${1:?usage: halu_exec_sandbox <job-id>}"
JSON="$HOME/daegis/queue/approved/$ID.json"
[ -f "$JSON" ] || { echo "no such job"; exit 2; }

jq -e . "$JSON" >/dev/null
TASK=$(jq -r '.task' "$JSON")
mapfile -t ARGS < <(jq -r '.args[]?' "$JSON")

AL="$HOME/daegis/state/tools.allow"
DONE="$HOME/daegis/queue/done"
FAIL="$HOME/daegis/queue/failed"
LOG="$HOME/daegis/logs/queue.log"
mkdir -p "$DONE" "$FAIL" "$(dirname "$LOG")"

case "$TASK" in
  reflection)
    TARGET="$HOME/daegis/scripts/ops/emit_halu_reflection.sh"
    grep -qxF "$TARGET" "$AL" || { echo "not allowed"; exit 4; }
    CMD=( "$TARGET" "${ARGS[@]}" )
    ;;
  viz)
    TARGET="$HOME/daegis/www/halu_state_viz.py"
    grep -qxF "$TARGET" "$AL" || { echo "not allowed"; exit 4; }
    CMD=( /usr/bin/env python3 "$TARGET" "${ARGS[@]}" )
    ;;
  bandit)
    TARGET="$HOME/daegis/scripts/ops/bandit_update_safe.sh"
    grep -qxF "$TARGET" "$AL" || { echo "not allowed"; exit 4; }
    CMD=( /usr/bin/env bash "$TARGET" "${ARGS[@]}" )
    ;;
  *)
    CMD=( /usr/bin/env bash -lc "echo 'unknown task: ${TASK:-}' >&2; exit 3" )
    ;;
esac

OUT="$DONE/$ID.out"
ERR="$FAIL/$ID.err"

set +e
"${CMD[@]}" >"$OUT" 2>&1
RC=$?
set -e

TS=$(date -u +%FT%TZ)
if [ $RC -eq 0 ]; then
  printf '{"ts":"%s","event":"done","id":"%s","task":"%s"}\n' "$TS" "$ID" "$TASK" \
    | flock -x "$LOG.lock" tee -a "$LOG" >/dev/null
  "$HOME/daegis/relay/tools/slack_webhook_post.sh" "🟢 Done: $ID ($TASK)"
  rm -f "$JSON"
else
  mv -f "$OUT" "$ERR" 2>/dev/null || true
  printf '{"ts":"%s","event":"failed","id":"%s","task":"%s","rc":%d}\n' "$TS" "$ID" "$TASK" "$RC" \
    | flock -x "$LOG.lock" tee -a "$LOG" >/dev/null
  FIRST=$(head -n 1 "$ERR" 2>/dev/null | tr -d '\r' | cut -c1-160)
  [ -z "$FIRST" ] && FIRST="(no stderr)"
  "$HOME/daegis/relay/tools/slack_webhook_post.sh" "🔴 Failed: $ID ($TASK rc=$RC) — $FIRST"
  mv -f "$JSON" "$FAIL/$ID.json" 2>/dev/null || true
  exit $RC
fi
