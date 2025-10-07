#!/usr/bin/env bash
set -euo pipefail
L="$HOME/daegis/Daegis Ledger.md"
H=127.0.0.1; P=1883; U=f; PW=nknm
TOP_IN="daegis/decision/new"
TOP_OUT="daegis/notify/scribe"
mosquitto_sub -h $H -p $P -u $U -P $PW -t "$TOP_IN" -v | \
while IFS= read -r line; do
  j="${line#* }"
  ts=$(jq -r '.ts // now | todate' <<<"$j")
  title=$(jq -r '.title' <<<"$j")
  who=$(jq -r '.who // "f"' <<<"$j")
  why=$(jq -r '.why // ""' <<<"$j")
  printf "%s: %s — by %s. %s\n" "$(date -u +%F)" "$title" "$who" "$why" >> "$L"
  mosquitto_pub -h $H -p $P -u $U -P $PW -t "$TOP_OUT" -m "[ledger] $title ✅"
done
