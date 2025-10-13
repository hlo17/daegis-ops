# HANDOFF_MAP v1 — Garden

## CONTEXT
- 目的: Garden Dashboard を運用仕様へ落とす
- 範囲/非目標:

## SNAPSHOT
- Prom scrape=10s / exporter=127.0.0.1:9205
- メトリクス: daegis_window_send_last_ts (GAUGE), daegis_window_send_last_info{...} 1
- 落とし穴: Exporterは数値のみ、infoは *_info{...} 1

## RUNBOOK
### Freshness 復旧ワンライナー
    set -euo pipefail
    now="$(date +%s)"; card="6d669c49eb50"; trace="wsend-$(date +%s)"
    payload=$(printf 'daegis_window_send_last_ts %s\n%s\n' "$now" "daegis_window_send_last_info{card_id=\"$card\",trace=\"$trace\"} 1")
    out="$HOME/daegis/logs/prom/daegis_window_send.prom"
    tmp="${out}.$$.tmp"
    printf '%s' "$payload" > "$tmp" && mv -f "$tmp" "$out"

## SLO/SLA（週次）
- Freshness%  : `avg_over_time(daegis:fresh:ok[7d]) * 100`
- Uptime%     : `avg_over_time(daegis:exporter:up[7d]) * 100`
- Scrape%     : `avg_over_time(daegis:scrape:ok[7d]) * 100`

## INCIDENT / 失敗博物館
- 事象 / 原因 / 恒久対応 / 参照

## 変更管理（Change Log）

## 承認ログ
- Owner: あなた / Reviewer: Lyra / Approver: Chappie
