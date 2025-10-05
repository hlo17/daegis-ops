
## 2025-10-05 (M2/M3)
- Slack Slash → FastAPI(slack2mqtt) → MQTT → Halu/Oracle 経路 本稼働。
- Cloudflare named Tunnel 「bridge」 作成 → DNS 張替え 完了。
- 評価スキーマ (✅ / 🛠 / ❌ + reason) を固定。
- 短期運用方針: RAG導入 + 評価固定 → 来週 LoRA “型矯正”。

### Decisions
- 2025-10-05: Cloudflare Tunnel へ恒久移行 — ngrok 制約回避と URL 安定化。
- 2025-10-05: RAG→評価固定→来週 LoRA 1 回 — 学習投資を最小に素早く回す。
