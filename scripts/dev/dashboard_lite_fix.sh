#!/usr/bin/env sh
# Safe dashboard generator (append-only) that tolerates JSON flags
set -eu
OUT="docs/runbook/dashboard_lite.md"
mkdir -p docs/runbook
{
  echo "### Auto-adopt gate (safe)"
  echo "- AUTO_TUNE_ALLOW_INTENTS=${AUTO_TUNE_ALLOW_INTENTS:-"(unset)"}"
  if [ -f flags/L105_COOLDOWN_UNTIL ]; then
    RAW="$(cat flags/L105_COOLDOWN_UNTIL 2>/dev/null || echo "")"
    NOW=$(date +%s)
    if printf "%s\n" "$RAW" | grep -q '{'; then
      if command -v jq >/dev/null 2>&1; then
        U="$(printf "%s" "$RAW" | jq -r '.until_ts // empty' || true)"
      else
        U="$(printf "%s" "$RAW" | sed -n 's/.*"until_ts":[ ]*\([0-9.]*\).*/\1/p')"
      fi
      U="${U%.*}"
      if [ -n "${U:-}" ]; then
        echo "- Cooldown parsed until: ${U} (rem=$((U-NOW))s)"
      else
        echo "- Cooldown: unreadable flag"
      fi
    else
      RAW="${RAW%.*}"
      [ -n "${RAW}" ] && echo "- Cooldown until: ${RAW} (rem=$((RAW-NOW))s)" || echo "- Cooldown: flag empty"
    fi
  else
    echo "- Cooldown: none"
  fi
  echo ""
} >> "$OUT"
echo "[dash-lite-fix] appended → $OUT"