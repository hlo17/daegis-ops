#!/usr/bin/env bash
# layout_3pane.sh
session="layout"

tmux has-session -t $session 2>/dev/null && tmux attach -t $session && exit 0
tmux new-session -d -s $session -n work

# 上下分割
tmux split-window -v -t $session
# 上ペインを左右分割
tmux select-pane -t $session:0.0
tmux split-window -h -t $session

# 上の左ペインで smoke_chat.sh
tmux send-keys -t $session:0.0 'cd ~/daegis-ops && bash scripts/dev/smoke_chat.sh' C-m
# 上の右ペインで tail -f log
tmux send-keys -t $session:0.1 'tail -f /tmp/router_debug.log' C-m
# 下ペインは対話操作用
tmux send-keys -t $session:0.2 'cd ~/daegis' C-m

tmux attach -t $session
