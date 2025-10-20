#!/usr/bin/env sh
# L10.6 Runner (append-only): fire gate once when cooldown passed and no VETO
set -eu
ROOT="${ROOT:-$(pwd)}"
FLAG_VETO="${ROOT}/flags/L5_VETO"
FLAG_CD="${ROOT}/flags/L105_COOLDOWN_UNTIL"
now="$(date +%s)"

[ -f "$FLAG_VETO" ] && { echo "[auto-adopt-ready] VETO present; abort"; exit 0; }

if [ -f "$FLAG_CD" ]; then
  RAW="$(cat "$FLAG_CD" 2>/dev/null || echo "")"
  if printf "%s" "$RAW" | grep -q '{'; then
    if command -v jq >/dev/null 2>&1; then
      UNTIL="$(printf "%s" "$RAW" | jq -r '.until_ts // empty' || true)"
    else
      UNTIL="$(printf "%s" "$RAW" | sed -n 's/.*"until_ts":[ ]*\([0-9.]*\).*/\1/p')"
    fi
  else
    UNTIL="$RAW"
  fi
  UNTIL="${UNTIL%.*}"
  if [ -n "${UNTIL:-}" ] && [ "$UNTIL" -gt "$now" ] 2>/dev/null; then
    echo "[auto-adopt-ready] cooldown active; remaining=$((UNTIL-now))s"
    exit 0
  else
    rm -f "$FLAG_CD" || true
  fi
fi

AUTO_TUNE_ALLOW_INTENTS="${AUTO_TUNE_ALLOW_INTENTS:-}" 
bash "${ROOT}/scripts/learn/auto_adopt_gate.sh"
exit 0