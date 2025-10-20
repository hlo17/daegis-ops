#!/usr/bin/env sh
# Recover cooldown flag from logs (append-only)
set -eu
ROOT="${ROOT:-$(pwd)}"
LOG="${ROOT}/logs/policy_apply_controlled.jsonl"
OUT="${ROOT}/flags/L105_COOLDOWN_UNTIL"
mkdir -p "${ROOT}/flags"
if ! [ -f "$LOG" ]; then
  echo "[mark-cooldown] no log"; exit 0
fi
if command -v jq >/dev/null 2>&1; then
  CD="$(tac "$LOG" | jq -c 'select(.event=="auto_adopt_skip" and (.reason|ascii_upcase)=="COOLDOWN")' | head -1 || true)"
  if [ -n "${CD:-}" ]; then
    U="$(printf "%s" "$CD" | jq -r '.until_ts // empty' || true)"
    I="$(printf "%s" "$CD" | jq -r '.intent // empty' || true)"
    S="$(printf "%s" "$CD" | jq -r '.ts // empty' || true)"
    H="$(printf "%s" "$CD" | jq -r '.cooldown_h // empty' || true)"
    if [ -n "$U" ]; then
      printf '{"until_ts": %s, "intent": "%s", "src_ts": %s, "cooldown_h": %s}\n' "$U" "$I" "$S" "$H" > "$OUT"
      echo "[mark-cooldown] wrote $OUT until=${U} intent=${I}"
      exit 0
    fi
  fi
  AD="$(tac "$LOG" | jq -c 'select(.event=="auto_adopt")' | head -1 || true)"
  if [ -n "${AD:-}" ]; then
    TS="$(printf "%s" "$AD" | jq -r '.ts // now')"
    H="$(printf "%s" "$AD" | jq -r '.cooldown_h // 2')"
    SEC=$(awk "BEGIN{printf "%d", ${H}*3600}")
    U=$(( ${TS%.*} + SEC ))
    I="$(printf "%s" "$AD" | jq -r '.key // empty' | sed -n 's/DAEGIS_SLA_\([A-Z_]*\)_MS/\L\1/p')"
    printf '{"until_ts": %s, "intent": "%s", "src_ts": %s, "cooldown_h": %s}\n' "$U" "$I" "$TS" "$H" > "$OUT"
    echo "[mark-cooldown] wrote $OUT until=${U} intent=${I}"
    exit 0
  fi
fi
echo "[mark-cooldown] nothing to mark"
exit 0# --- [append-only] cooldown restore fallback v2025-10-10 ---
# 最後の採択イベントから固定クールダウン（例：15分）を再計算
CD_SEC=${CD_SEC:-900}
LAST=$(tac logs/policy_apply_controlled.jsonl 2>/dev/null | grep -m1 '"adopt_ready"' || true)
if [ -n "$LAST" ]; then
  TS=$(printf '%s' "$LAST" | sed -n 's/.*"ts":[ ]*\([0-9]*\).*/\1/p')
  UNTIL=$((TS+CD_SEC))
  printf '{"until_ts":%s,"src":"restore"}\n' "$UNTIL" > flags/L105_COOLDOWN_UNTIL
fi
# --- end ---
