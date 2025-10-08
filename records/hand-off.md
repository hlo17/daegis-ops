## Incident: HaluRelayHeartbeatMissing が深夜に連発
**When:** 2025-10-08 07:54:09 UTC  
**Impact:** Slack #daegis-alerts にて `HaluRelayHeartbeatMissing` が断続的に [FIRING]。

### Findings
- `mosquitto` 起動失敗（`Error: Address already in use`）。
- conf.d 複数ファイルで **listener/認証ディレクティブ重複**。
- Relay→MQTT が不安定となり、`halu_relay_heartbeat_ts_seconds` が **15分窓で欠損**。

### Root Cause
- Mosquitto 設定の **多重定義**（`listener 1883`、`password_file`、`acl_file` の重複）。

### Fix (done)
1. `/etc/mosquitto/mosquitto.conf` を最小化（`include_dir /etc/mosquitto/conf.d` のみ）。
2. `/etc/mosquitto/conf.d/01-listener.conf` に集約：
   ```conf
   listener 1883 0.0.0.0
   allow_anonymous false
   password_file /etc/mosquitto/passwd
   acl_file /etc/mosquitto/acl
   ```
3. 競合ファイル（例: `02-hardening.conf`）は *.off へ退避。
4. 認証復旧（`mosquitto_passwd` / `acl` 再作成、権限 640）。
5. 再起動後、LISTEN: `0.0.0.0:1883` を確認。

### Verification
- `halu_relay_heartbeat_ts_seconds` : 直近 = **空**（取り込みホップ要確認）
- `absent_over_time(...[15m])` : **1**（直近15分に欠損あり）→ 継続監視

### Preventive Actions
- **Single source config**：listener/認証は 01-listener.conf のみ。
- **起動前セルフチェック**：`ss -ltnp | grep :1883` と `mosquitto -c ... -v`。
- **Alertしきい値**：`absent_over_time(...[15m])` + `for: 15m`。
- **Secrets外だし**：.env / vault、履歴からの完全除去。

### Artifacts
- Snapshot: `snapshots/ops-state-2025-10-08-165409`
  - Mosquitto: mosquitto.conf / 01-listener.conf / acl / passwd.redacted
  - Monitoring: alerts.halu.yml / Prom クエリ結果（now/absent）
  - Logs: halu-relay.log / mosquitto_listen.txt / docker_ps.txt
## Incident: HaluRelayHeartbeatMissing が深夜に連発
**When:** 2025-10-08 08:03:16 UTC  
**Impact:** Slack `#daegis-alerts` に `HaluRelayHeartbeatMissing` が断続的に [FIRING]。

### Findings
- Mosquitto は起動安定（LISTEN: `0.0.0.0:1883`）。MQTT publish OK。
- Relay は接続ログあり。
- しかし Prometheus では `absent_over_time(halu_relay_heartbeat_ts_seconds[15m])` が **1** を返却 = 収集経路（Relay→Pushgateway/Exporter→Prometheus）に未整備/未到達箇所あり。

### Root Cause
- 先行の起動失敗は conf.d の **listener/認証ディレクティブ重複**（解消済み）。
- 現時点の欠損は **メトリクス取り込み経路の未結線**が濃厚。

### Fix (done)
1. `/etc/mosquitto/mosquitto.conf` を最小化（`include_dir /etc/mosquitto/conf.d`）。
2. `/etc/mosquitto/conf.d/01-listener.conf` に集約（listener/認証）。
3. 重複ファイル（例: `02-hardening.conf`）を `.off` 退避。
4. 認証ファイル再作成 & 権限調整（640）。

### Next Actions
- Relay から Pushgateway への POST 有無を確認（Pushgateway URL/ポート、ジョブ名、TTL）。
- Prometheus の scrape 設定に対象ジョブが入っているか確認。
- 15分窓 + `for: 15m` の alert ルールで運用継続。

### Artifacts
- Snapshot: `snapshots/ops-state-2025-10-08-170316`
  - Mosquitto: mosquitto.conf / 01-listener.conf / acl / passwd.redacted
  - Monitoring: alerts.halu.yml（あれば）/ prom_heartbeat_now.json / prom_heartbeat_absent_15m.json
  - Logs: halu-relay.log / mosquitto_listen.txt / docker_ps.txt
