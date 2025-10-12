#!/usr/bin/env bash
set -euo pipefail
f="${1:?usage: dna_validate.sh <dna.jsonl>}"
ok=0; ng=0
re_iso='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
while IFS= read -r line; do
  [ -n "$line" ] || continue
  kind=$(printf '%s\n' "$line" | jq -r '.kind // empty' 2>/dev/null || true)
  agent=$(printf '%s\n' "$line" | jq -r '.agent // empty' 2>/dev/null || true)
  ts=$(printf '%s\n' "$line"   | jq -r '.ts // empty'    2>/dev/null || true)
  enum_ok=0; case "$kind" in hash_rely|halu_rely|spirit_fingerprint|finalize) enum_ok=1;; esac
  iso_ok=0; [[ "$ts" =~ $re_iso ]] && iso_ok=1
  val_ok=1
  if [ "$kind" = "hash_rely" ]; then
    v=$(printf '%s\n' "$line" | jq -r '.value // empty' 2>/dev/null || true)
    [ -n "$v" ] || val_ok=0
  fi
  if [ -n "$kind" ] && [ -n "$agent" ] && [ -n "$ts" ] && [ $enum_ok -eq 1 ] && [ $iso_ok -eq 1 ] && [ $val_ok -eq 1 ]; then
    ok=$((ok+1))
  else
    ng=$((ng+1))
  fi
done < "$f"
echo "[dna_validate] ok=$ok ng=$ng file=$f"
[ "$ng" -eq 0 ]
