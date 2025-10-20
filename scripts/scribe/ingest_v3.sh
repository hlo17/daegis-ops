#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
IN="${1:?usage: scripts/scribe/ingest_v3.sh <v3.json>}"

# must be pure JSON and contain minimum keys
jq -e 'type=="object" and has("phase") and has("component_id") and has("topic")' "$IN" >/dev/null

ts="$(date -u +%FT%TZ)"
sha="$(sha256sum "$IN" | awk "{print \$1}")"
base="v3_$(date -u +%Y%m%dT%H%M%SZ)_${sha:0:8}.json"

# 1) keep original (WORM-ish inbox)
mkdir -p "$ROOT/docs/chronicle/audit_inbox"
cp "$IN" "$ROOT/docs/chronicle/audit_inbox/$base"

# 2) normalize → append 1-line JSON to phase_ledger.jsonl
norm="$(mktemp)"
jq --arg ts "$ts" --arg sha "$sha" '
  . + {ingested_at:$ts} |
  . as $o |
  . + {governance: ($o.governance // {})} |
  (.governance.trace_id // $sha) as $tid |
  .governance.trace_id = $tid
' "$IN" > "$norm"
jq -c . "$norm" >> "$ROOT/docs/chronicle/phase_ledger.jsonl"

# 3) audit journal
mkdir -p "$ROOT/logs"
jq -nc --arg ts "$ts" --arg file "$base" --arg sha "$sha" \
  '{ts:$ts,event:"ingest_v3",file:$file,sha:$sha}' >> "$ROOT/logs/ingest_v3.jsonl"

echo "[ingest] appended to phase_ledger.jsonl :: $base"
