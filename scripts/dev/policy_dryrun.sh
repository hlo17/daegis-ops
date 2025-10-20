#!/usr/bin/env sh
set -eu
SRC="${1:-logs/decision.jsonl}"
OUT="${OUT:-logs/policy_decision.jsonl}"
[ -f "$SRC" ] || { echo "[dryrun] missing $SRC"; exit 0; }
mkdir -p "$(dirname "$OUT")"
has_jq=0; command -v jq >/dev/null 2>&1 && has_jq=1
if [ $has_jq -eq 1 ]; then
  while read -r line; do
    ts=$(printf '%s' "$line" | jq -r '.event_time // .decision_time // (now|todate)')
    id=$(printf '%s' "$line" | jq -r '.episode_id // .corr_id // null')
    intent=$(printf '%s' "$line" | jq -r '.intent_hint // .intent // "other"')
    lat=$(printf '%s' "$line" | jq -r '.latency_ms // 0')
    sug=$(printf '%s' "$line" | jq -r '.tuning.sla_suggested_ms // null')
    win="false"; [ "$sug" != "null" ] && [ "$(printf '%.0f' "$lat")" -le "$(printf '%.0f' "$sug")" ] && win="true"
    printf '{"ts":"%s","episode_id":%s,"intent":"%s","latency_ms":%s,"suggested_ms":%s,"win":%s}\n' \
      "$ts" "$( [ "$id" = "null" ] && echo null || printf '"%s"' "$id")" "$intent" "$lat" "$sug" "$win" >> "$OUT"
  done < "$SRC"
else
  echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"episode_id\":null,\"intent\":\"other\",\"latency_ms\":0,\"suggested_ms\":null,\"win\":false}" >> "$OUT"
fi
echo "[dryrun] appended → $OUT"
exit 0