#!/usr/bin/env bash
# usage: deliver-b64 <src> <user@host> <remote-path> [--chmod=0755] [--owner=user] [--group=group] [--sudo]
set -euo pipefail
src="${1:?src}"; host="${2:?user@host}"; rpath="${3:?remote path}"; shift 3 || true
mode=""; owner=""; group=""; use_sudo="no"
for a in "$@"; do
  case "$a" in
    --chmod=*) mode="${a#--chmod=}" ;;
    --owner=*) owner="${a#--owner=}" ;;
    --group=*) group="${a#--group=}" ;;
    --sudo)    use_sudo="yes" ;;
  esac
done

chown_arg=""
[ -n "$owner" ] && chown_arg="$owner"
[ -n "$group" ] && chown_arg="${chown_arg}:$group"

dir="$(dirname "$rpath")"
tmp="${rpath}.tmp.$(date +%s).$$"

# まず中身を作る
base64 "$src" | ssh -o IdentitiesOnly=yes "$host" "set -e; umask 022; mkdir -p '$dir'; base64 -d > '$tmp'"

SUDO=""
[ "$use_sudo" = "yes" ] && SUDO="sudo"

# パーミッション調整と原子置換
ssh -o IdentitiesOnly=yes "$host" "set -e;
  tmp='$tmp'; mode='$mode'; chown_arg='$chown_arg'; SUDO='$SUDO';
  if [ -n \"\$mode\" ]; then \$SUDO chmod \"\$mode\" \"\$tmp\"; fi
  if [ -n \"\$chown_arg\" ]; then \$SUDO chown \"\$chown_arg\" \"\$tmp\"; fi
  \$SUDO mv -f \"\$tmp\" '$rpath'
"
echo "[deliver-b64] done -> $host:$rpath"
