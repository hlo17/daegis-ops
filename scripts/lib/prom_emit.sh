#!/usr/bin/env bash
set -euo pipefail
# emit_gauge "metric{label=\"v\"}" value "ns"  -> logs/prom/<ns>.prom を atomic 書換
emit_gauge(){
  local key="$1" val="$2" ns="${3:-custom}"
  local dir="$HOME/daegis/logs/prom"
  mkdir -p "$dir"
  local tmp="$dir/${ns}.prom.tmp" out="$dir/${ns}.prom"
  # 既存をベースに他行を保ったまま、このkeyだけ置換
  if [ -s "$out" ]; then cp -f "$out" "$tmp"; else : > "$tmp"; fi
  # 同名行を削除→末尾に再出力（重複回避）
  grep -v -F -- "$key " "$tmp" 2>/dev/null > "${tmp}.f" || true
  mv "${tmp}.f" "$tmp"
  printf "%s %s\n" "$key" "$val" >> "$tmp"
  mv -f "$tmp" "$out"
}
