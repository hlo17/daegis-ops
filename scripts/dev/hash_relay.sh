#!/usr/bin/env sh
set -eu
NODES="${DAEGIS_NODES:-http://127.0.0.1:8080}"
echo "== Hash Relay (dry) =="
count=0
for n in $(echo "$NODES" | tr ',' ' '); do
  curl -s -X POST "$n/chat" -H 'Content-Type: application/json' -d '{"user":"relay","content":"ping"}' >/dev/null 2>&1 || true
  if [ -f logs/decision.jsonl ]; then
    sha="$(sha256sum logs/decision.jsonl | awk '{print $1}')"
    if command -v jq >/dev/null 2>&1; then
      ts="$(tail -1 logs/decision.jsonl 2>/dev/null | jq -r '.decision_time? // .event_time? // "-"' || echo "-")"
    else
      ts="-"
    fi
  else
    sha="MISSING"; ts="-"
  fi
  echo "NODE=$n LOCAL_LEDGER_SHA=$sha DECISION_TIME=$ts"
  count=$((count+1))
done
echo "SUMMARY nodes=$count distributed_consistency=UNKNOWN"

# --- Real check: compare local vs remote via /hash ---
echo ""
echo "== Hash Relay (real check) =="
NODES="${DAEGIS_NODES:-http://127.0.0.1:8080}"
lc_sha="$(sha256sum logs/decision.jsonl 2>/dev/null | awk '{print $1}')"
[ -z "$lc_sha" ] && lc_sha="MISSING"
c=0; ok=0; drift=0; unk=0
for n in $(echo "$NODES" | tr ',' ' '); do
  body="$(curl -s "$n/hash" 2>/dev/null || echo "")"
  if [ -n "$body" ]; then
    if command -v jq >/dev/null 2>&1; then
      rs="$(echo "$body" | jq -r '.ledger_sha // "MISSING"')"
    else
      rs="$(printf "%s" "$body" | sed -n 's/.*"ledger_sha":"\([^"]*\)".*/\1/p')"
      [ -z "$rs" ] && rs="MISSING"
    fi
    if [ "$lc_sha" != "MISSING" ] && [ "$rs" != "MISSING" ]; then
      st=$([ "$lc_sha" = "$rs" ] && echo CONSISTENT || echo DRIFT)
    else
      st=UNKNOWN
    fi
  else
    rs="MISSING"; st=UNKNOWN
  fi
  echo "NODE=$n LOCAL_SHA=$lc_sha REMOTE_SHA=$rs STATUS=$st"
  c=$((c+1)); [ "$st" = "CONSISTENT" ] && ok=$((ok+1)) || true
  [ "$st" = "DRIFT" ] && drift=$((drift+1)) || true
  [ "$st" = "UNKNOWN" ] && unk=$((unk+1)) || true
done
dc="UNKNOWN"
if [ $c -gt 0 ] && [ $ok -eq $c ]; then dc="YES"; elif [ $drift -gt 0 ]; then dc="NO"; fi
echo "SUMMARY nodes=$c consistent=$ok drift=$drift unknown=$unk distributed_consistency=$dc"
exit 0