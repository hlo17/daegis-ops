---
tags:
  - Daegis_Chronicle
aliases:
created: 2025-09-28 21:21
modified: 2025-09-28 21:23
Prev: "[[Daegis Chronicle 2025-09-27]]"
Next:
---

# 📜 Daegis Chronicle（統合版タイムライン・最新版）

## M0：基盤構築 ✅ 完了

- Mosquitto 導入（QoS=1, JSON, health トピック）
- Gemini / Grok 疎通テスト成功（demo-003）、Protocol v0.9 確立
- ダッシュボード MVP（可視化／状態／ログ表示）稼働

---

## M1：可視化と外部公開 ✅ 完了（暫定）

- Caddy + `/mqtt` 逆プロキシ構成
- ngrok 経由で外部アクセス確認（LAN/外部ともに “Connected to MQTT”）
- ws/wss 自動判別ロジック導入
⚠️ 残課題：ngrok Free制限（URL変動／1セッション制限）→ **Cloudflare Tunnel 恒久化**

---

## M2：運用モデル合意 ✅ 完了

- 「二段階ハイブリッド」方式採択（基礎層＝並列収集／編集層＝状況別編集長）
- Verdict バッジ設計（✅/⚠️/🔴）、KPI指標案確定
- 円卓役割（Chappie, Gemini, Grok, Perplexity, NotebookLM）明文化
⚠️ 残課題：Verdict 実データの実装は未開始

---

## M3：自律ループ構築 ✅ 達成

- Halu-RAG 修正 → テスト 5/5 GREEN
- 自動書記官 MVP：`[DECISION] → Markdown → GitHub PR` 線路確保
- 暫定 Consistency Gate (GitHub Actions) 導入可能状態
⚠️ 見落とし注意：Decision Scribe 完成版デプロイ未了、PR冪等化不透明

---

## M4：常駐化・単独運転 🚧 進行中

- 4騎士の常駐 agent 化設計
- Bridge により Slack 不要でも「問い→要約→[DECISION]素案→PR」可能な単独運転ループ
⚠️ 残課題：systemd 起動順、PYTHONUNBUFFERED、相関ID統一

---

## M5：信頼性・観測性 🚧 着手中

- DLQ + 再送タイマー設計済（15分周期／指数バックオフ／Slack通知）
- Prometheus Exporter 指標案（PR件数、失敗件数、レイテンシ、稼働時間）
- Grafana ダッシュボード v0.1 計画
⚠️ 残課題：DLQ 常駐化と Slack 通知未稼働、Bridge 二重起動監視

---

## M6：通信セキュリティ 🚧 未導入

- Mosquitto TLS (8883) + クライアント証明書必須 + ACL 設計
- 中期は Dynamic Security プラグイン検討
⚠️ 注意：MQTT 外部公開せず、Grafana のみ公開。Bridge API は X-Auth-Token で保護（ローテーション必須）

---

## M7：外部公開恒久化 ⏸ 待機

- ngrok → **Cloudflare Tunnel + Zero Trust** へ切替予定
- Grafana のみ公開、Scribe API は公開せず

---

## M8：アーカイブ・検索 ⏸ 中期計画

- `logbook/` を S3 に nightly ミラー、180日後に Glacier Deep Archive
- OpenSearch 検索基盤導入（NotebookLM 補助）

---

## M9：NotebookLM ゲート本実装 ⏸ 待機

- PR 後に Webhook 非同期判定 → GitHub Status Check 更新
- 現在は暫定 Gate（必須メタ検証のみ）
⚠️ 課題：NotebookLM 用 read-only PAT の 90日更新／四半期監査 未整備

---

## 📌 未完・見落としやすいタスク

- Decision Scribe 完成版デプロイ（最優先）
- Mosquitto ACL & 認証テスト（grokユーザー pub/sub 最終確認）
- DLQ 常駐化 + Slack 通知テスト
- Cloudflare Cron 調整（10分 → 1h or 停止）
- corr (uuid4) の全経路統一
- Bridge (:8787) の二重起動監視
- pre-commit 除外設定 + CI smoke test 固定
- Cloudflare Tunnel 一本化（ngrok URL 廃止）

---

## 🎯 直近の優先アクション

1. **Decision Scribe 完成版デプロイ & E2Eテスト**
2. **Mosquitto ACL 安定化**
3. **Cloudflare Cron 調整**

---

✅ 到達点：**「動く最小国家」は完成**（疎通・可視化・PR 生成）
⚠️ 最大のリスク：**Scribe未完成・DLQ未導入・MQTT認証未最終化・外部URL未統一**

---

📅 **日付**: 2025-09-28（更新）
- 2025-09-28 21:24:45: Chronicle sync test
