#!/usr/bin/env sh
# Phase L11: Safety Sentinel (append-only, no apply)
set -eu
SRC="${SRC:-logs/decision.jsonl}"
FLAG_DIR="flags"; FLAG="$FLAG_DIR/L5_VETO"
mkdir -p "$FLAG_DIR"
[ -f "$SRC" ] || { echo "[sentinel] no decisions"; exit 0; }

# 直近からの"連続ストリーク"を厳密に算出（jq あり/なし両対応）
TMP_IN="/tmp/dec.tail.$$"; TMP_SEQ="/tmp/dec.seq.$$"
trap 'rm -f "$TMP_IN" "$TMP_SEQ" 2>/dev/null || true' EXIT
tail -300 "$SRC" > "$TMP_IN" || true

if command -v jq >/dev/null 2>&1; then
  # 形式: PASS/HOLD <tab> STATUS   （最新が先頭になるよう tac）
  tac "$TMP_IN" | jq -r '[.ethics.verdict//"PASS", (.status//200)] | @tsv' > "$TMP_SEQ" 2>/dev/null || true
else
  # jq 無しの簡易抽出
  tac "$TMP_IN" | awk '
    {v="PASS"; s=200}
    /"ethics"/ {if($0~/"HOLD"/) v="HOLD"}
    /"status"/ {match($0,/"status": *([0-9]+)/,m); if(m[1]!="") s=m[1]}
    {print v "\t" s}
  ' > "$TMP_SEQ"
fi

# 先頭（＝最新）から連続カウント。非該当が出たらその軸は終了。
H=0; E=0
while IFS="$(printf '\t')" read -r V S; do
  # HOLD 連続
  if [ "$V" = "HOLD" ]; then H=$((H+1)); else break; fi
done < "$TMP_SEQ"

# 5xx 連続（H判定とは独立に再走査）
while IFS="$(printf '\t')" read -r V S; do
  case "${S:-200}" in
    ''|*[!0-9]*) break;;
    *) if [ "$S" -ge 500 ]; then E=$((E+1)); else break; fi;;
  esac
done < "$TMP_SEQ"

HN="${HOLD_N:-5}"; EN="${E5XX_N:-3}"
if [ "$H" -ge "$HN" ] || [ "$E" -ge "$EN" ]; then
  date -u +%FT%TZ > "$FLAG"
  echo "[sentinel] VETO (H=$H/$HN, E=$E/$EN) → $FLAG"
else
  rm -f "$FLAG" 2>/dev/null || true
  echo "[sentinel] OK (no veto)"
fi
exit 0