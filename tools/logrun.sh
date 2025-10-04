#!/usr/bin/env bash
set -Eeuo pipefail
name="${1:-run}"; shift || true
[ "${1:-}" = "--" ] && shift
ts="$(date -u +%Y%m%dT%H%M%SZ)"
log="$HOME/daegis/logs/${name}_${ts}.log"
mkdir -p "${log%/*}"
rc=0
trap 'printf "[%(%FT%TZ)T] logrun end: rc=%s\n" -1 "$rc"' EXIT
{
  printf "[%(%FT%TZ)T] logrun start: %s\n" -1 "$name"
  if [ "$#" -gt 0 ]; then "$@" || rc=$?; else rc=0; fi
} 2>&1 | tee "$log"
exit "$rc"
