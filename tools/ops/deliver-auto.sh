#!/usr/bin/env bash
# usage: deliver-auto <src> <user@host> <remote-path> [--no-validate] [--chmod=0755] [--owner=u] [--group=g] [--sudo]
set -euo pipefail
src="${1:?src}"; host="${2:?user@host}"; rpath="${3:?remote path}"; shift 3 || true
noval="no"; rest=()
for a in "$@"; do [ "$a" = "--no-validate" ] && noval="yes" || rest+=("$a"); done
if [ "$noval" != "yes" ] && [ -x tools/validate.sh ]; then tools/validate.sh "$src" || exit 1; fi
sz=$(wc -c <"$src")
if [ "$sz" -le $((96*1024)) ]; then
  tools/deliver-b64.sh "$src" "$host" "$rpath" "${rest[@]}" || {
    echo "[deliver-auto] b64 failed → scp fallback" >&2
    tools/deliver-scp.sh "$src" "$host" "$rpath" "${rest[@]}"
  }
else
  tools/deliver-scp.sh "$src" "$host" "$rpath" "${rest[@]}"
fi
echo "[deliver-auto] done ($sz bytes)"
