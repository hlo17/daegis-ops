: ${RPROMPT:=}
: ${PROMPT:=%n@%m:%~ %# }
: ${RPROMPT:=}
: ${PROMPT:=%n@%m:%~ %# }
setopt interactivecomments
# starship があれば有効化
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Created by `pipx` on 2025-09-24 03:34:04
export PATH="$PATH:/Users/f/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
capture(){
  local T=$(date +%s)
  echo "### START $T :: $*" | tee -a halu.log
  eval "$@" 2>&1 | tee -a halu.log
  echo "### END $T" | tee -a halu.log
  echo "token:$T"
}
share(){
  local T; T=$(grep -o '### START [0-9]\+' halu.log | tail -1 | awk '{print $3}')
  sed -n "/### START ${T} /,/### END ${T}/p" halu.log
}
# Daegis Sentry shortcut
sentry() { PROMPT="${*:-受信テスト}" "$HOME/daegis/ops/sentry/sentry.sh"; }
append_md(){ bash ~/daegis/ops/tools/append_md.sh "$@"; }
append_chronicle(){ bash ~/daegis/ops/tools/append_chronicle.sh "$@"; }
sentryc(){ bash ~/daegis/ops/tools/sentry_chronicle.sh "$@"; }
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
loadsecrets(){ 
  export OPENAI_API_KEY="$(security find-generic-password -a "$USER" -s OPENAI_API_KEY -w 2>/dev/null)"
  export GEMINI_API_KEY="$(security find-generic-password -a "$USER" -s GEMINI_API_KEY  -w 2>/dev/null)"
}
export PATH="$HOME/daegis/ops/bin:$PATH"
# --- Daegis remote deploy helper ---
rdeploy() {
  local save="$1"; shift
  ssh round-table "SAVE_TO=$save $* bash ~/ops/tools/deploy.sh"
}
# --- end ---

# 既存: 本文をここから受け取って Pi に保存
rdeploy() {
  local target="$1"; shift
  local opts="$1";   shift
  cat | ssh round-table "SAVE_TO='$target' ${opts} bash ~/ops/tools/deploy.sh"
}

# 新規: 既存のローカルファイルを Pi に送る（本文コピペ不要）
rdeploy_file() {
  local local_path="$1"
  local remote_path="${2:-"~/${1##*/}"}"
  local opts="${3:-}"
  if [[ ! -f "$local_path" ]]; then
    echo "no such file: $local_path" >&2; return 1
  fi
  cat "$local_path" | ssh round-table "SAVE_TO='$remote_path' ${opts} bash ~/ops/tools/deploy.sh"
  echo "📤 pushed $local_path -> $remote_path"
}

# --- send existing local file to Pi safely ---
rdeploy_file() {
  local local_path="$1"
  local remote_path="$2"
  local opts="${3:-}"

  if [[ -z "$local_path" || ! -f "$local_path" ]]; then
    echo "no such file: $local_path" >&2; return 1
  fi

  # 既定の送信先は Pi の \$HOME 直下（\$ をエスケープして「リモートで」展開）
  if [[ -z "$remote_path" ]]; then
    remote_path="\$HOME/${local_path##*/}"
  else
    # 先頭が ~ ならローカルで展開せずに \$HOME に置換して渡す
    if [[ "$remote_path" == ~/* ]]; then
      remote_path="\$HOME/${remote_path#~/}"
    fi
  fi

  # リモートで deploy.sh を実行（SAVE_TO はクォートしない：\$HOME を展開させる）
  cat "$local_path" | ssh round-table "SAVE_TO=$remote_path $opts bash ~/ops/tools/deploy.sh"
  echo "📤 pushed $local_path -> $remote_path"
}


# ---- push local doc -> Pi: ~/daegis/docs/<name> ----
# 使い方:
#   rpushdoc <local_path>            # 同名で ~/daegis/docs/ に配置
#   rpushdoc <local_path> <name>     # リモート名を指定して配置
#   rpushdoc <local_path> <name> "HOOKS=1 SUDO=1"   # 追加オプション（任意）
#
# 例:
#   rpushdoc ~/daegis/docs/Daegis-2030-Plan.md
#   rpushdoc ./notes.md Research-Notes.md
rpushdoc() {
  local local_path="$1"
  local name="${2:-"${1##*/}"}"
  local extra_opts="${3:-}"

  if [[ -z "$local_path" ]]; then
    echo "usage: rpushdoc <local_path> [remote_name] [\"HOOKS=1 SUDO=1 ...\"]" >&2
    return 2
  fi
  if [[ ! -f "$local_path" ]]; then
    echo "no such file: $local_path" >&2
    return 1
  fi

  # 事前に docs ディレクトリを作成（なければ）
  ssh round-table 'mkdir -p ~/daegis/docs' || return $?

  # deploy.sh に流し込んで保存
  cat "$local_path" | ssh round-table \
    "SAVE_TO='\$HOME/daegis/docs/$name' $extra_opts bash ~/ops/tools/deploy.sh" || return $?

  echo "�� pushed $local_path -> ~/daegis/docs/$name"
  # 軽く確認
  ssh round-table "ls -lh ~/daegis/docs/$name"
}
# ---- list remote docs on Pi ----
rlsdocs() {
  ssh round-table 'ls -lh ~/daegis/docs || echo "(no ~/daegis/docs)"'
}

# ---- pull remote doc -> Mac ----
# 使い方:
#   rpulldoc <remote_name>                 # ~/daegis/docs/<remote_name> をローカルに保存
#   rpulldoc <remote_path>                 # 例: rpulldoc '~/daegis/docs/X.md'
#   rpulldoc <remote> <local_path>         # 保存先を明示
rpulldoc() {
  local remote="$1"
  local local_path="$2"

  if [[ -z "$remote" ]]; then
    echo "usage: rpulldoc <remote_name|remote_path> [local_path]" >&2
    return 2
  fi

  # remote がスラッシュを含まなければ ~/daegis/docs/<name> とみなす
  if [[ "$remote" != */* ]]; then
    remote="\$HOME/daegis/docs/$remote"
  fi

  # デフォルトのローカル保存先
  if [[ -z "$local_path" ]]; then
    mkdir -p "$HOME/daegis/docs"
    local fname="$(basename "$remote")"
    local_path="$HOME/daegis/docs/$fname"
  else
    # ディレクトリ指定だったらファイル名を補う
    if [[ -d "$local_path" ]]; then
      local fname="$(basename "$remote")"
      local_path="${local_path%/}/$fname"
    else
      mkdir -p "$(dirname "$local_path")"
    fi
  fi

  # 取得（タイムスタンプ保持 -p）
  scp -p round-table:"$remote" "$local_path"
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    echo "📥 pulled round-table:$remote -> $local_path"
    ls -lh "$local_path"
  else
    echo "pull failed (rc=$rc). remote exists? → ssh round-table 'ls -l $remote'" >&2
  fi
  return $rc
}

# ---- show diff between local & remote ----
# 使い方: rdiffdoc <remote_name|remote_path> [local_path]
rdiffdoc() {
  local remote="$1"
  local local_path="$2"
  if [[ -z "$remote" ]]; then
    echo "usage: rdiffdoc <remote_name|remote_path> [local_path]" >&2
    return 2
  fi
  if [[ "$remote" != */* ]]; then
    remote="\$HOME/daegis/docs/$remote"
  fi
  if [[ -z "$local_path" ]]; then
    local_path="$HOME/daegis/docs/$(basename "$remote")"
  fi
  if [[ ! -f "$local_path" ]]; then
    echo "local not found: $local_path （先に rpulldoc してください）" >&2
    return 1
  fi
  ssh round-table "cat $remote" | diff -u --label "remote:$remote" --label "local:$local_path" - "$local_path"
}
# ============================================
# Pi (round-table) と docs フォルダを rsync 同期
# デフォルト: ~/daegis/docs  <->  ~/daegis/docs
# オプションで --dry-run を渡すと試走
# ============================================

# 共通 rsync オプション（見やすい進捗・差分のみ・パーミッション/時刻保持）
__DAEGIS_RSYNC_OPTS="-avh --delete --partial --progress --times --omit-dir-times --human-readable"

# 除外したいファイル/フォルダがあればここに追加（例は macOS の小物を除外）
__DAEGIS_EXCLUDES=(
  "--exclude=.DS_Store"
  "--exclude=.Trash"
  "--exclude=.Spotlight-V100"
  "--exclude=.TemporaryItems"
)

# Mac → Pi：ローカルの docs を Pi に反映
rpushdocs() {
  local local_dir="${1:-$HOME/daegis/docs/}"
  local remote_dir="${2:-~/daegis/docs/}"
  local extra_opts="$3"   # 例: "--dry-run"
  rsync $__DAEGIS_RSYNC_OPTS "${__DAEGIS_EXCLUDES[@]}" $extra_opts \
    "$local_dir" "round-table:$remote_dir"
}

# Pi → Mac：Pi の docs をローカルに反映
rpulldocs() {
  local remote_dir="${1:-~/daegis/docs/}"
  local local_dir="${2:-$HOME/daegis/docs/}"
  local extra_opts="$3"   # 例: "--dry-run"
  rsync $__DAEGIS_RSYNC_OPTS "${__DAEGIS_EXCLUDES[@]}" $extra_opts \
    "round-table:$remote_dir" "$local_dir"
}

# 片方向“保護”モード（削除しない）
rpushdocs_safe() {
  local local_dir="${1:-$HOME/daegis/docs/}"
  local remote_dir="${2:-~/daegis/docs/}"
  local extra_opts="$3"
  rsync -avh --partial --progress --times --omit-dir-times --human-readable \
    "${__DAEGIS_EXCLUDES[@]}" $extra_opts \
    "$local_dir" "round-table:$remote_dir"
}
rpulldocs_safe() {
  local remote_dir="${1:-~/daegis/docs/}"
  local local_dir="${2:-$HOME/daegis/docs/}"
  local extra_opts="$3"
  rsync -avh --partial --progress --times --omit-dir-times --human-readable \
    "${__DAEGIS_EXCLUDES[@]}" $extra_opts \
    "round-table:$remote_dir" "$local_dir"
}

# おまけ：同期前に差分プレビュー（削除も表示）
rdiffdocs() {
  local dir_local="${1:-$HOME/daegis/docs/}"
  local dir_remote="${2:-~/daegis/docs/}"
  # rsync の --itemize-changes で差分一覧
  rsync -avhn --delete --itemize-changes "${__DAEGIS_EXCLUDES[@]}" \
    "$dir_local" "round-table:$dir_remote" \
  | sed -n '1!p'   # 先頭の送信元/宛先行を省く
}
# 保存検知でローカル→Pi自動同期
rwatchdocs() {
  local local_dir="${1:-$HOME/daegis/docs}"
  local remote_dir="${2:-~/daegis/docs/}"
  if ! command -v fswatch >/dev/null 2>&1; then
    echo "fswatch がありません。brew install fswatch を実行してください。" >&2
    return 1
  fi
  echo "👀 watching $local_dir → $remote_dir (Ctrl+Cで終了)"
  fswatch -o "$local_dir" | while read _; do
    rpushdocs "$local_dir/" "$remote_dir"   # 前に渡した rsync 関数を利用
    date "+[synced at %H:%M:%S]"
  done
}

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/daegis/ops:$PATH"
export PATH="$HOME/daegis/ops:$PATH"
alias dfpub="dfctl.py publish-test && dfctl.py result-wait"

# --- Daegis dfctl shortcuts ---
alias dfpub="dfctl.py publish-test && dfctl.py result-wait"
alias dfstat="dfctl.py status"
alias dfres="dfctl.py restart"
alias dfsnap="dfctl.py snapshot"
alias dflog="dfctl.py logs"
alias dfpub="dfctl.py retain-clear && dfctl.py publish-test && dfctl.py result-wait"
alias dfpub="ssh round-table 'dfctl.py retain-clear && dfctl.py publish-test && (dfctl.py result-wait --wait 6 || dfctl.py result-wait --wait 6 || dfctl.py result-wait --wait 6)'"
# Daegis: 新チャット冒頭サマリー
newchat(){ ~/daegis/ops/bin/new_chat_summary.py "${1:-handoff}"; }
alias d="cd ~/daegis && pwd"
export PATH="$HOME/daegis/tools:$HOME/daegis/ops/bin:$HOME/daegis/ops:$PATH"
