#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$HOME/daegis}"
FIX="${FIX:-0}"  # FIX=1 で自動修復

err=0
note(){ printf '%s\n' "$*"; }
do_fix(){
  [ "$FIX" = "1" ] || return 0
  sudo chown -R f:f "$ROOT" || true
  chmod -R u+rwX "$ROOT" || true
}

note "[check-perms] root=$ROOT fix=$FIX"
# 1) 所有権
OWN_ISSUES=$(find "$ROOT" \! -user f -o \! -group f | wc -l || echo 0)
if [ "$OWN_ISSUES" -gt 0 ]; then
  err=1
  note "[warn] ownership mismatch: $OWN_ISSUES"
  note "      suggest: sudo chown -R f:f \"$ROOT\""
fi

# 2) 実行に必要なビット（bin配下は+x推奨）
BIN_ISSUES=$(find "$ROOT/ops/bin" -type f -name '*.sh' -o -name '*.py' 2>/dev/null \
  | xargs -r -I{} bash -c 'test -x "{}" || echo "{}"' | wc -l)
if [ "${BIN_ISSUES:-0}" -gt 0 ]; then
  err=1
  note "[warn] non-executable files in ops/bin: $BIN_ISSUES"
  note "      suggest: chmod +x \$(find \"$ROOT/ops/bin\" -type f -name \"*.sh\" -o -name \"*.py\")"
fi

# 3) 空白を含む主要ファイルの存在と書込権限
LEDGER="$ROOT/Daegis Ledger.md"
if [ ! -f "$LEDGER" ]; then
  err=1
  note "[warn] missing: $LEDGER (will create on first append)"
fi
if [ -f "$LEDGER" ] && [ ! -w "$LEDGER" ]; then
  err=1
  note "[warn] not writable: $LEDGER"
fi

# 自動修復（任意）
if [ "$err" -ne 0 ]; then
  do_fix
  [ "$FIX" = "1" ] && note "[fix] attempted auto-fix (ownership/perm)"
fi

[ "$err" -eq 0 ] && note "[ok] perms clean" || exit 1
