# Daegis Brief — Handoff (Rolling)
updated: 2025-10-05T18:24JST
owner: f (@round-table)

## 1) 現在の状況
- Slack Slash → FastAPI(slack2mqtt) → MQTT → Halu / Oracle が稼働。Cloudflare Tunnel `bridge` でDNS確定。
- 観測: `mw_log` が /orchestrate を JSONL 計測、評価スキーマ (✅ / 🛠 / ❌ + reason) 固定。
- 短期方針: RAG導入＋評価固定 → 来週 LoRA “型矯正” 1 回。

## 2) 次にやること (優先順)
1. Decision Scribe 完成版 デプロイ & E2E ([DECISION]→PR→Gate)
2. Mosquitto ACL 最終確認 (grok pub/sub deny 証跡)
3. Slack Webhook を rt-digest.sh に設定し 日次投稿 ON
4. RAG Index 初期化 (faiss/duckdb) ＋ 評価スキーマ 確定（✅/🛠/❌ + reason）
5. Bridge :8787 二重起動 ガード / corr_id ルール統一

## 3) 注意点・リスク
- Scribe未完成／DLQ未常駐／MQTT認証 未最終化。外部URL・認証は Cloudflare に統一。
- cost cap と 外部AIゲート (confidence<0.7) を維持。
- PIIマスク前データ は学習禁止。評価ログは JSONL 固定。

## 4) 引き継ぎキーワード
- files: brief.md, docs/Daegis Chronicle.md, ops/runbooks/AI-Handoff.md
- cmds:
  - `systemctl --user status daegis-slack2mqtt.service`
  - `journalctl --user -fu daegis-slack2mqtt.service`
  - `cloudflared tunnel info bridge`
  - `mosquitto_pub -h 127.0.0.1 -p 1883 -u f -P nknm -t daegis/_probe -n`
- urls: https://bridge.daegis-phronesis.com/slash/halu , /slash/oracle

---
📎 固定リンク（参照用）
- Map → docs/Daegis Map.md
- Guidelines → docs/Daegis Guidelines.md
