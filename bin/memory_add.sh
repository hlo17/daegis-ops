#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"
MEM="$ROOT/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/memory"
mkdir -p "$MEM"
ts=$(date -u +%FT%TZ)

case "${1:-}" in
  fact)
    shift
    echo "- [$ts] $*  #fact" >> "$MEM/facts.md"
    ;;
  decision)
    shift
    echo "- [$ts] $*  #decision" >> "$MEM/decisions.md"
    ;;
  *)
    echo "usage: memory_add.sh {fact|decision} <text>"; exit 1;;
esac
