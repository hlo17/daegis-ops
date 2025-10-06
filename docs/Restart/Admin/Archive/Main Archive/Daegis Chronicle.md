# 🧭 Daegis Hand-off — 2025-10-05 (最新版)

## 0) スコープ
円卓（Roundtable）運用の“いま”を1枚で把握するためのハンドオフ。履歴は持たず毎回上書き。

---
## 1) 現在完了していること
- **Slack Slash → FastAPI(slack2mqtt) → MQTT → Halu / Oracle** が稼働。
  - `POST /slash/halu`, `POST /slash/oracle` は 200 即応（非同期でMQTTに橋渡し）。
  - `daegis-slack2mqtt.service`（user unit, uvicorn）が常駐。`python-multipart` を導入済み。
- **Cloudflare Tunnel（named: `bridge`）** を新設し、**`bridge.daegis-phronesis.com`** にCNAME紐付け。
  - `/etc/cloudflared/config.yml` で `service: http://127.0.0.1:8787` を終端。
  - `cloudflared-bridge.service`（system unit）で常駐、DNS衝突を解消済み。
- **評価とログの固定化**
  - Halu/Oracle の回答に **✅/🛠/❌ + reason** を付与する方針で統一。
  - Roundtable 観測：ASGI ミドルウェア `mw_log` が `/var/log/roundtable/orchestrate.jsonl` へ `status`/`latency_ms` を追記。
- **運用合意**：短期は **RAG導入 + 評価固定**、来週 **LoRA“型矯正”** を1回実施（Adaptive Hybrid Pool）。

---
## 2) 次にやること（優先度順）
1. **RAG を入れる（最小）**：Ledger/Chronicle 由来の成功事例を FAISS/SQLite-FTS で Top3 注入。
2. **評価保存の本配線**：✅/🛠/❌ を `daegis/feedback/*` にJSONLで確定、corr_idで Halu/Oracle 応答と連結。
3. **Slack 日次ダイジェスト**：`SLACK_WEBHOOK_URL` を設定し、`rt-digest.sh` の投稿をON（09:05）。
4. **Mosquitto ACL 最終化**：`grok` ユーザーの pub/sub と deny を最終検証、証跡を残す。
5. **corr_id 統一 & Bridge二重起動監視**：uuid4の全経路統一、`fuser -k 8787/tcp` 等の前処理をunitに固定。
6. **Cloudflare Zero Trust**：外部公開は Tunnel 経由に一本化（ngrok撤去）。
7. **LoRA 小スプリント**：来週、収集データ500件目安で“3行方針の型矯正”を1回。

---
## 3) 現在のリスク
- **Scribe未完成 / DLQ未常駐**：失敗時の再送とPR自動化が暫定（回避策: 手動運用 + mw_log継続）。
- **外部URLの統一/鍵管理**：ngrok 残存や環境変数未設定での不整合（回避策: Cloudflare一本化 + Citadel移行P1）。
- **MQTT認証の最終化前**：ACL穴/deny漏れの懸念（回避策: 最小ACLでの追加検証）。
- **観測の未配線**：Webhook未設定でアラート/日次が未通知（回避策: 3)で解消）。

---
## 4) Ops Quick Ref（運用ワンライナー）
- 状態確認：
  - `systemctl --user status daegis-slack2mqtt.service --no-pager -l`
  - `journalctl --user -fu daegis-slack2mqtt.service`
  - `sudo systemctl status cloudflared-bridge.service --no-pager -l`
- 外部疎通：
  - `curl -fsS https://bridge.daegis-phronesis.com/dev/null && echo ok`
- Slashローカル試験：
  - `curl -i -X POST -F 'text=このPRの要約方針を3行で' -F 'response_url=http://127.0.0.1:8787/dev/null' http://127.0.0.1:8787/slash/halu`
  - `curl -i -X POST -F 'text=eval: この変更の妥当性を評価して' -F 'response_url=http://127.0.0.1:8787/dev/null' http://127.0.0.1:8787/slash/oracle`
- Cloudflared 基本：
  - `sudo cloudflared tunnel list && sudo cloudflared tunnel info bridge`
  - `sudo cat /etc/cloudflared/config.yml`
- ダイジェスト手動：
  - `sudo systemctl start rt-digest.service && sudo journalctl -u rt-digest.service -n 50 --no-pager`

---
## 5) DAG 雛形（概略）
```
[Slash] -> slack2mqtt -> MQTT(daegis/asks/*)
    -> [Halu/Oracle workers]
    -> [Verdict + Feedback JSONL 保存]
    -> [RAG インデックス更新 (日次)]
    -> [LoRA バッチ（週次/1回）]
```

---
## 6) 重要ファイル/場所
- `/home/f/.config/systemd/user/daegis-slack2mqtt.service`
- `/etc/systemd/system/cloudflared-bridge.service`
- `/etc/cloudflared/config.yml`
- `/var/log/roundtable/orchestrate.jsonl`
- `daegis/` リポジトリ配下の `Chronicle/Hand-off/Ledger` 一式


2025-10-05: Slack Slash→FastAPI(slack2mqtt)→MQTT 経路を本番化 — /slash/halu,/slash/oracle 200 即応・user unit 常駐。
2025-10-05: Cloudflare named tunnel「bridge」を作成し CNAME をトンネルへ張替え — bridge.daegis-phronesis.com を FastAPI 終端に接続。
2025-10-05: 旧DNSレコード衝突を解消 — 既存CNAMEを整理し、tunnel UUID の cfargotunnel CNAME を登録。
2025-10-05: 評価スキーマ（✅/🛠/❌ + reason）を固定 — 集計と将来学習（RAG/LoRA）用の標準化を確立。
2025-10-05: 短期運用方針「RAG導入＋評価固定→来週LoRA“型矯正”」を決定 — 低コストの品質改善ループを開始。


## 2025-10-05: Slack Bridge開通と経路完成（M2/M3）
- 2025-10-05: FastAPI `slack2mqtt` を user unit で常駐化、`python-multipart` を導入し `/slash/halu` `/slash/oracle` が 200 即応。
- 2025-10-05: Cloudflare の **named tunnel `bridge`** を新設し、`bridge.daegis-phronesis.com` をトンネルCNAMEに張替え。`cloudflared-bridge.service` で稼働確認。
- 2025-10-05: DNS 競合を解消し、**Slack→FastAPI→MQTT→Halu/Oracle** の運用経路が完成。
- 2025-10-05: 戦略合意：短期は **RAG導入＋評価固定**、来週 **LoRA“型矯正”** を実施。評価スキーマ（✅/🛠/❌ + reason）を固定。


# 次チャット引き継ぎブリーフ（2025-10-05）

## 1) 現在の状況
- Slack Slash → FastAPI(slack2mqtt) → MQTT → Halu/Oracle が稼働。Cloudflare Tunnel `bridge` と DNS 張替え完了。
- 観測：`mw_log` が orchestrate をJSONLで計測。評価スキーマ（✅/🛠/❌+reason）を確定。
- 合意：短期は **RAG導入＋評価固定**、来週 **LoRA“型矯正”** を1回。

## 2) 次にやること（優先順位）
1. RAG 最小導入（FAISS/SQLite-FTS、成功事例Top3注入）
2. 評価保存の本配線（feedback JSONL、corr_id連結）
3. Slack日次ダイジェストON（Webhook設定）
4. Mosquitto ACL 最終化（証跡）
5. corr_id統一 & Bridge二重起動監視
6. Cloudflare Zero Trust一本化
7. 来週LoRA 1回（型矯正）

## 3) 注意点・リスク
- Scribe未完成 / DLQ未常駐、外部URLの統一未完、MQTT ACL 最終化前、観測未配線（Webhook未設定）。

## 4) 引き継ぎ用キーワード
`daegis-slack2mqtt.service`, `cloudflared-bridge.service`, `/etc/cloudflared/config.yml`, `bridge.daegis-phronesis.com`, `orchestrate.jsonl`, `rt-digest.sh`, `✅/🛠/❌`, `RAG`, `LoRA`
