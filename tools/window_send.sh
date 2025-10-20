#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"

# 1) 最新openカードID（introspect優先）
jid=$(tac logs/introspect.jsonl 2>/dev/null | \
  jq -r 'select(.status=="open" and (.topic|test("^Windowカード: "))) | .id' | head -1 || true)

if [ -z "${jid:-}" ]; then
  f=$(ls -1t inbox/window/*.md 2>/dev/null | head -1 || true)
  [ -n "$f" ] || { echo "[ERR] no open cards"; exit 2; }
  jid="$(basename "$f" | sed 's/\..*$//')"
fi

bundle="/tmp/window_bundle.txt"
out="inbox/ai_to_human/${jid}.md"
log="logs/window_send.jsonl"
ledger="docs/chronicle/phase_ledger.jsonl"
prom="logs/prom/daegis_window_send.prom"

ts=$(date -u +%FT%TZ)
trace="wsend-$(openssl rand -hex 6)"

# 2) DRY判定
dry="${WINDOW_SEND_DRY:-}"
[ -z "${OPENAI_API_KEY:-}" ] || true
if [ -z "${OPENAI_API_KEY:-}" ]; then dry="1"; fi

# 3) 送信 or DRY
if [ "${dry:-}" = "1" ]; then
  {
    echo "### Window Send (DRY) — $ts"
    echo "- trace_id: $trace"
    echo "- note: DRY: not sent (no OPENAI_API_KEY)"
    echo
    if [ -f "$bundle" ]; then
      echo "<bundle snapshot omitted>"
    else
      echo "<no bundle>"
    fi
  } >> "$out"
  printf '{"ts":"%s","card_id":"%s","trace_id":"%s","dry":true}\n' "$ts" "$jid" "$trace" >> "$log"
  status="DRY"
else
  model="${WINDOW_SEND_MODEL:-gpt-4o-mini}"
  temp="${WINDOW_SEND_TEMP:-0.2}"
  maxtok="${WINDOW_SEND_MAXTOK:-2000}"
  resp=$(python3 ops/remote/roundtable/clients/openai_llm.py \
            --model "$model" --temperature "$temp" --max_tokens "$maxtok" \
            --from-bundle "$bundle" 2>/dev/null || echo "")
  sha=$(printf "%s" "$resp" | sha256sum | awk '{print $1}')
  {
    echo "### Window Send — $ts"
    echo "- trace_id: $trace"
    echo "- model: $model, temp: $temp, max_tokens: $maxtok"
    echo "- response_sha256: $sha"
    echo
    printf "%s\n" "$resp"
  } >> "$out"
  printf '{"ts":"%s","card_id":"%s","trace_id":"%s","response_sha":"%s"}\n' "$ts" "$jid" "$trace" "$sha" >> "$log"
  status="SENT"
fi

# 4) Ledger(v3)
mkdir -p "$(dirname "$ledger")"
printf '{"ts":"%s","intent":"window.send","component_id":"garden_gate.window","card_id":"%s","trace_id":"%s","status":"%s"}\n' \
  "$ts" "$jid" "$trace" "$status" >> "$ledger"

# 5) Prom (Beacon用)
echo "daegis_window_send_last_ts $(date +%s)" > "$prom"

echo "[ok] window_send id=$jid status=$status trace=$trace out=$out"
