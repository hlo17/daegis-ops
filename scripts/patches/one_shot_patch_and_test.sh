#!/usr/bin/env bash
# One-shot patch + optional non-interactive run for router/app.py
# Usage:
#   bash scripts/patches/one_shot_patch_and_test.sh patch-only
#   bash scripts/patches/one_shot_patch_and_test.sh patch-run --yes
set -euo pipefail

MODE="${1:-patch-only}"
shift || true
AUTO_CONFIRM=0
for a in "$@"; do
  case "$a" in
    --yes|-y) AUTO_CONFIRM=1 ;;
    --debug) set -x ;;
    *) echo "Unknown arg: $a" ;;
  esac
done

LOG_DIR="/tmp"
TS=$(date -u +%FT%H%M%SZ)
LOG_APPLY="$LOG_DIR/one_shot_apply_${TS}.log"
LOG_RUN="$LOG_DIR/one_shot_run_${TS}.log"
FILE="router/app.py"

echo "one_shot: start at $(date -u +%FT%T%Z)" > "$LOG_APPLY"
echo "file: $FILE" >> "$LOG_APPLY"

[ -f "$FILE" ] || { echo "file $FILE not found; run from repo root" | tee -a "$LOG_APPLY"; exit 1; }

# Backup
BAK="${FILE}.bak_${TS}"
cp -v "$FILE" "$BAK" 2>&1 | tee -a "$LOG_APPLY"

# Idempotent patch & indentation fix via Python
python3 - "$FILE" >> "$LOG_APPLY" 2>&1 <<'PY'
import sys,re
F=sys.argv[1]
s=open(F,'r',encoding='utf-8').read()
anchor='if path == "/chat" and request.method == "POST":\n'
if anchor not in s:
    print("anchor not found; aborting")
    sys.exit(2)
# If already patched, exit 0
if 'Guard: ensure module aliases exist' in s and '_json' in s:
    print("already patched")
    sys.exit(0)
insert = (
"    # Guard: ensure module aliases exist in function locals to avoid UnboundLocalError\n"
"    try:\n"
"        _os\n"
"    except NameError:\n"
"        import os as _os\n"
"    try:\n"
"        _json\n"
"    except NameError:\n"
"        import json as _json\n"
"    try:\n"
"        _time\n"
"    except NameError:\n"
"        import time as _time\n\n"
)
s = s.replace(anchor, anchor + insert, 1)
# ensure block is indented inside the if
lines = s.splitlines(True)
for i,l in enumerate(lines):
    if anchor.strip() in l:
        j=i+1
        while j<len(lines) and lines[j].strip()!='':
            if lines[j].startswith("    ") and not lines[j].startswith("        "):
                lines[j] = "    " + lines[j]
            j+=1
        break
open(F,'w',encoding='utf-8').write(''.join(lines))
print("patched")
PY

echo "---- git diff (router/app.py) ----" >> "$LOG_APPLY"
git --no-pager diff -- "$FILE" | sed -n '1,240p' >> "$LOG_APPLY" 2>&1 || true
echo "---- apply log saved to $LOG_APPLY ----"
cat "$LOG_APPLY"

if [ "$MODE" = "patch-only" ]; then
  echo "Mode=patch-only: done."
  exit 0
fi

# patch-run: run port guard then short server
if [ "$AUTO_CONFIRM" -ne 1 ]; then
  read -p "Proceed to run port_guard and short debug server? (y/N) " ans || true
  if [ "${ans:-n}" != "y" ]; then
    echo "Aborted by user."
    exit 0
  fi
fi

# Run: capture full run logs to LOG_RUN
{
  echo "=== RUN START $(date -u +%FT%T%Z) ==="
  echo "Running port guard..."
  ./scripts/port_guard.sh || { echo "Port guard failed; abort"; exit 1; }
  echo "Starting uvicorn (debug) -> /tmp/router_debug.log ..."
  rm -f /tmp/router_debug.log /tmp/router_debug.pid || true
  [ -f .venv/bin/activate ] && source .venv/bin/activate || true
  python3 -m uvicorn router.app:app --host 0.0.0.0 --port 8080 > /tmp/router_debug.log 2>&1 &
  UV_PID=$!
  echo $UV_PID > /tmp/router_debug.pid
  sleep 1
  tail -n 80 /tmp/router_debug.log || true

  echo "Running smoke test..."
  curl -sS -X POST http://127.0.0.1:8080/chat -H 'Content-Type: application/json' -d '{"q":"halu"}' -w "\nHTTP:%{http_code}\n" -o /tmp/chat_resp || true
  echo "---- /tmp/chat_resp ----"
  cat /tmp/chat_resp || true
  echo "---- /tmp/router_debug.log tail ----"
  tail -n 200 /tmp/router_debug.log || true

  # stop server gracefully
  if [ -f /tmp/router_debug.pid ]; then
    PID=$(cat /tmp/router_debug.pid)
    echo "Stopping uvicorn pid=$PID"
    kill "$PID" || true
    rm -f /tmp/router_debug.pid
  fi
  echo "=== RUN END $(date -u +%FT%T%Z) ==="
} > "$LOG_RUN" 2>&1 || true

echo "Run log saved to: $LOG_RUN"
tail -n 200 "$LOG_RUN" || true
echo "One-shot finished. Rollback: cp -v ${BAK} ${FILE}"
