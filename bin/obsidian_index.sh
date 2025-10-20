#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/daegis"
SRC="$ROOT/bridges/obsidian/mirror"
OUT="$ROOT/bridges/obsidian/derived/index.jsonl"
TMP="${OUT}.$$".tmp
LOG="$ROOT/logs/worm/obsidian_index_skips.log"

mkdir -p "$(dirname "$OUT")" "$ROOT/logs/worm"

# mac / linux で mtime 取得
if [ "$(uname -s)" = "Darwin" ]; then mtime_of(){ stat -f %m "$1"; }
else mtime_of(){ stat -c %Y "$1"; }
fi

# JSON 文字列に安全化（\ " CR LF をエスケープ）
json_sanitize(){ LC_ALL=C perl -0777 -pe 's/\\/\\\\/g; s/"/\\"/g; s/\r//g; s/\n/\\n/g'; }

: > "$TMP"
[ "${VERBOSE:-0}" = "1" ] && : > "$LOG"

# symlink も辿る
find -L "$SRC" -type f -name '*.md' -print0 \
| while IFS= read -r -d '' f; do
  rel="${f#$SRC/}"
  mtime=$(mtime_of "$f") || { [ "${VERBOSE:-0}" = "1" ] && echo "[skip mtime] $rel" >> "$LOG"; continue; }
  title=$(basename "$f" .md)

  # frontmatter
  fm=$(awk 'f==0 && $0=="---"{f=1;next} f==1 && $0=="---"{f=2} f==1{print}' "$f" \
        | json_sanitize) || fm=""

  # body プレビュー（frontmatter の後ろから先頭400B）
  body=$(awk 'p{print} /^---$/{c++} c==2{p=1}' "$f" \
        | head -c 400 \
        | json_sanitize) || body=""

  # フォールバック：本文取れなければファイル先頭から
  if [ -z "$body" ]; then
    [ "${VERBOSE:-0}" = "1" ] && echo "[fallback body] $rel" >> "$LOG"
    body=$(LC_ALL=C sed $'s/\r//g' "$f" | head -c 400 | json_sanitize) || body=""
  fi

  printf '{"path":"%s","title":"%s","mtime":%s,"frontmatter":"%s","preview":"%s"}\n' \
         "$rel" "$title" "$mtime" "$fm" "$body" >> "$TMP" \
    || { [ "${VERBOSE:-0}" = "1" ] && echo "[skip print] $rel" >> "$LOG"; continue; }
done || true

mv -f "$TMP" "$OUT"
items=$(wc -l < "$OUT" | tr -d ' ')
echo "[obsidian_index] indexed items=$items -> $OUT"
