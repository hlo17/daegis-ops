# Garden Gate Primer（運用入門）

## 1. 役割と関係
- **Gardener**: 調整・総括・ハンドオフ（あなた）
- **Lyra**: 仕様化・合意整理（HANDOFF_MAP）、ダッシュの運用整備
- **Kai**: 実装・スクリプト・Ops
- **Chappie**: 議長/最終承認（APPROVER）
- **Garden Gate**: hand-offカードの公式経路（Window→WORM→Ledger→Prom→Grafana→Feedback）

## 2. 主要アーティファクト
- **Windowカード**: `inbox/window/*.md`
- **WORM**: `inbox/ai_to_human/<id>.md`
- **Ledger**: `docs/chronicle/phase_ledger.jsonl`
- **Exporter**: `:9205/metrics`
- **Prometheus**: `:9090`
- **Grafana**: Stat=Instant推奨

## 3. 標準フロー（閉ループ）
1) Window Send → 2) WORM → 3) Ledger → 4) Exporter(数値のみ/情報は *_info 1)
→ 5) Prom → 6) Grafana → 7) Feedback → 1)

## 4. 最重要メトリクス（例）
- `daegis_window_send_last_ts` (GAUGE, Unix秒)
  - Last: `scalar(max(...))*1000` + Unit=Datetime local（Stat=Instant）
  - Age: `time() - scalar(max(...))`（Unit=seconds, 絶対しきい値: 300/299）
- Mood: `daegis_mood_flag{mood="JOY|FLOW|..."}`
- SLI（Recording Rule）
  - `daegis:fresh:ok = (time() - max(daegis_window_send_last_ts)) <= bool 300`
  - `daegis:exporter:up = up{job="daegis_solaris_exporter"} == bool 1`
  - `daegis:scrape:ok = scrape_samples_post_metric_relabeling{job="daegis_solaris_exporter"} > bool 0`

## 5. コマンド
- ルーティング: `scripts/ops/triage_lane.sh <agent>`
- 送信: `tools/window_send.sh`（`WINDOW_SEND_DRY=1`でDRY）
- 直近送信をPromへ: `scripts/ops/emit_overview_prom.sh`（**2行アトミック書き**）
- 健康確認:
  - Exporter: `curl -s :9205/metrics | head`
  - Prom: `curl -Gs :9090/api/v1/query --data-urlencode 'query=daegis_window_send_last_ts'`
  - Targets: `curl -s :9090/api/v1/targets | jq '...'`

## 6. ルール/しきい値（確定）
- scrape_interval: 10s（global & daegis_solaris_exporter）
- Age thresholds（Absolute）: ≤300 🟢 / >300 🔴（Stat=Instant）
- SLO%（まず15m窓 → 後で7d）
  - `avg_over_time(daegis:fresh:ok[15m]) * 100`
  - `avg_over_time(daegis:exporter:up[15m]) * 100`
  - `avg_over_time(daegis:scrape:ok[15m]) * 100`

## 7. 落とし穴
- Exporterに**非数値**が混じるとscrape失敗 → 全部ゼロに見える  
  → 数値=GAUGE / 情報=*_info{...} 1 / **2行アトミック**徹底
- Grafana Statは**必ずInstant**／件数はUnitなし／Datetimeはms想定→PromQL側で`*1000`

## 8. 確認チェック（3点）
1) `.prom` に `_ts` と `_info{...} 1` の2行  
2) `:9205/metrics` に同じ2行  
3) `:9090/api/v1/query?query=daegis_window_send_last_ts` が vector(1)

## 9. 色・絵文字（固定）
- LOVE=温かいピンク、FEAR=黄
- ステータス: 🟢OK / 🟡注意 / 🔴要対応 / 🟣保守 / ⚫抑止
