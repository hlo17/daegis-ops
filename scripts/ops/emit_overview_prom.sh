#!/usr/bin/env bash
set -euo pipefail
source "$HOME/daegis/scripts/lib/prom_emit.sh"

now="$(date +%s)"
card_id="${CARD_ID:-6d669c49eb50}"
trace_id="${TRACE_ID:-wsend-$(date +%s)}"

# 2行分のペイロードを一度に書く（上書きは1回だけ）
payload=""
payload+="daegis_window_send_last_ts ${now}\n"
payload+="daegis_window_send_last_info{card_id=\"${card_id}\",trace=\"${trace_id}\"} 1\n"

_prom_atomic_write "daegis_window_send" "$payload"
