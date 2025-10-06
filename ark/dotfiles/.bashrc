# ===== DAEGIS BASH PROFILE =====
# 環境変数とプロンプトの設定

# 色付きプロンプト
if [ -n "$PS1" ]; then
  HOSTNAME_SHORT=$(hostname -s)
  BLUE="\[\033[0;34m\]"
  GREEN="\[\033[0;32m\]"
  YELLOW="\[\033[0;33m\]"
  RESET="\[\033[0m\]"
  PS1="${GREEN}\u${RESET} in @${YELLOW}${HOSTNAME_SHORT}${RESET} in :\W # "
fi

# エイリアスなど
alias d='cd ~/daegis && pwd'
alias ll='ls -alF'
alias gs='git status'

# VS Code shell integration（存在すれば）
[ -f "$HOME/.vscode/bin"/*/shellIntegration-bash.sh ] && source "$HOME/.vscode/bin"/*/shellIntegration-bash.sh 2>/dev/null || true

# ===== END =====
export PATH="$HOME/daegis/tools:$PATH"
export PATH="$HOME/daegis/tools:$HOME/daegis/ops/bin:$HOME/daegis/ops:$PATH"
