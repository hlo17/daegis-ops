#!/usr/bin/env bash
set -euo pipefail

SESSION="layout"
PROJECT="$HOME/daegis"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  # 左ペイン: uvicorn（プロジェクト直下で起動）
  tmux new-session -d -s "$SESSION" -n work -c "$PROJECT" \
    'python3 -m uvicorn router.app:app --host 127.0.0.1 --port 8081 | tee /tmp/router_debug.log'

  # 右上: smoke
  tmux split-window -h  -t "$SESSION":0 -c "$PROJECT"
  tmux send-keys   -t "$SESSION":0.1 'PORT=8081 bash ./scripts/dev/smoke_chat.sh' C-m

  # 右下: log tail
  tmux split-window -v  -t "$SESSION":0.1 -c "$PROJECT"
  tmux send-keys   -t "$SESSION":0.2 'tail -f /tmp/router_debug.log || true' C-m
fi

exec tmux attach -t "$SESSION"
