#!/usr/bin/env bash
set -Eeuo pipefail
source ops/factory/_lib.sh
echo "[factory] watching $QUEUE_DIR"
mkdir -p "$QUEUE_DIR/processed" "$QUEUE_DIR/failed"
while true; do
for f in "$QUEUE_DIR"/*.json; do
[[ -e "$f" ]] || continue
base="$(basename "$f")"; job="${base%.json}"
# path guards
[[ -L "$f" ]] && { echo "[skip] symlink:$base"; continue; }
real="$(realpath -e "$f" 2>/dev/null || true)"
[[ -z "$real" ]] && { echo "[skip] no-realpath:$base"; continue; }
queue_real="$(realpath -e "$QUEUE_DIR")/"
[[ "$real" != "$queue_real"* ]] && { echo "[skip] outside:$base"; continue; }
# schema guard (must have job_id, commands[], length>0)
if ! jq -e 'has("job_id") and (has("commands") and (.commands|type=="array") and (.commands|length>0))' "$f" >/dev/null; then
journal_append "$(json_line ts="$(now_ts)" id="$job" event="deny" reason="schema_invalid" file="$base")"
mkdir -p "$QUEUE_DIR/failed"; mv "$f" "$QUEUE_DIR/failed/${base}.invalid.$(date +%s).json" 2>/dev/null || true
continue
fi
if lock_acquire "$job"; then
echo "[factory] run $base"
if ops/factory/run_job.sh "$f"; then
mv "$f" "$QUEUE_DIR/processed/${base}.$(date +%s).ok.json" 2>/dev/null || true
else
mkdir -p "$QUEUE_DIR/failed"
mv "$f" "$QUEUE_DIR/failed/${base}.$(date +%s).ng.json" 2>/dev/null || true
fi
lock_release "$job"
fi
done
sleep 3
done
