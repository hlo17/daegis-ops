## Halu 可視化・通知の現状（ベースライン）
- Prometheus: targets/rules/alerts を取得済み（同フォルダの JSON）
- Alertmanager: active alerts / silences / status を取得済み
- Grafana: 「Halu Metrics v1」ダッシュボードを作成・UID固定、ホームに設定
- Pass/Fail & reason テレメトリ：textfile → node_exporter → Prom で取得・可視化
- 抑止（inhibit）：HaluReflectionSilent → HaluReflectionLowVolume を抑止（動作確認済み）

添付:
- halu_metrics_v1.png（ダッシュボードスクショ）
- prom_*.json, am_*.json（APIダンプ）

次アクション（Kai）:
1) reason taxonomy 固定化（grammar / hallucination / grounding / latency / format）
2) emit_halu_eval のJSONL導入（必要なら提案PR出します）
3) reflection ノート自動生成の下書き導線を用意（human-in-loopで承認）
