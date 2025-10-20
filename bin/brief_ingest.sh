#!/usr/bin/env bash
set -e -o pipefail
ROOT="$HOME/daegis"
INBOX="$ROOT/inbox/ai_to_human"
OUTDIR="$ROOT/bridges/obsidian/mirror/docs_chronicle/brief"
DONE="$INBOX/_done"
LOGDIR="$ROOT/logs/worm"
JOURNAL="$LOGDIR/brief_ingest.journal"
mkdir -p "$OUTDIR" "$DONE" "$LOGDIR"
if [ "$(uname -s)" = "Darwin" ]; then
  mtime_of(){ stat -f %m "$1"; }; sha256_of(){ shasum -a 256 "$1" | awk '{print $1}'; }; iso_utc(){ date -u -r "$1" +%FT%TZ; }
else
  mtime_of(){ stat -c %Y "$1"; }; sha256_of(){ sha256sum "$1" | awk '{print $1}'; }; iso_utc(){ date -u -d "@$1" +%FT%TZ; }
fi
touch "$JOURNAL"
find "$INBOX" -maxdepth 1 -type f -name '*.md' -print0 | while IFS= read -r -d '' f; do
  h=$(sha256_of "$f")
  if grep -q "$h" "$JOURNAL"; then echo "[skip dup] $f"; mv -f "$f" "$DONE/" 2>/dev/null || true; continue; fi
  mt=$(mtime_of "$f"); ts=$(iso_utc "$mt"); out="$OUTDIR/ferment_${ts}.md"
  { echo '---'; echo 'source: ai_to_human'; echo "origin_path: ${f#$HOME/}"; echo "ingested: $(date -u +%FT%TZ)"; echo "hash: $h"; echo '---';
    echo "# Brief • $ts"; echo; cat "$f"; echo; } > "$out"
  printf "%s %s -> %s\n" "$(date -u +%FT%TZ)" "$h" "${out#$HOME/}" >> "$JOURNAL"
  mv -f "$f" "$DONE/"; echo "[ingested] $f -> $out"
done
