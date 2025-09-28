
## 2025-09-29 Cloudflare Cronの動作状況を確認
_appended: 2025-09-29T00:56:24+0900_

- Daegis Chronicleの未完タスク項目に基づきCloudflare WorkerのCron設定を調査。
- 現在の設定が `0 */1 * * *` （1時間ごと）であり、既に修正済みであることを確認。
- これをもって本タスクを正式に完了とする。


## 2025-09-29 Sentry
_appended: 2025-09-29T00:57:19+0900_

OpenAI SDK v1 置換パッチ適用 -> 全ID再実行 OK


## 2025-09-29 Sentry
_appended: 2025-09-29T01:00:19+0900_

PoCまとめ: 結論=併用（API直=対話用途／Relay=運用フロー）。Hand-offに最終レビュー草案を追記。


## 2025-09-29 Chronicle Update
_appended: 2025-09-29T02:16:28+0900_

📜 Daegis Chronicle（統合版タイムライン・最新版）

## M4：常駐化・単独運転 🚧 進行中
- gemini_runner Pi常駐化（systemd） ✅  

## M5：信頼性・観測性 🚧 着手中
- Mosquitto ACL 最小構成 & 認証テスト ✅（user=f, in/out制御）
- Alertmanager→Slack 整形通知：テンプレ反映まで済、スクショ待ち ⏳  

## 📌 未完タスク
- ACL denyテスト（daegis/gemini/outへのpublish禁止）→ スクショ残し
- Decision Scribe 完成版デプロイ（最優先）
- DLQ 常駐化 + Slack 通知テスト
- Cloudflare Cron 調整（10分 → 1h or 停止）

## 🎯 直近アクション
1. Decision Scribe 完成版デプロイ & E2Eテスト
2. ACL denyテスト
3. Alertmanager→Slack 整形通知スクショ取得
4. Cloudflare Cron 調整


## 2025-09-29 ACL deny テスト（daegis/gemini/out publish 禁止）
_appended: 2025-09-29T02:23:28+0900_

## ACL deny テスト完了

**現象**: user=f が `daegis/gemini/out` に publish → ブローカーで拒否（期待どおり）

**スクショ**
- 拒否メッセージ: ![ACL deny](assets/)


## 2025-09-29 ACL deny テスト（サーバーログ補強）
_appended: 2025-09-29T02:27:08+0900_

## ACL deny テスト補強（サーバーログ）

**現象**: ブローカーが  publish を受け取り →  として拒否（期待どおり）

**スクショ**
- サーバーログ: ![mosquitto log](assets/)


## 2025-09-29 ACL deny テスト（サーバーログ補強）
_appended: 2025-09-29T02:35:00+0900_

## ACL deny テスト補強（サーバーログ）

**現象**: ブローカーが  publish を受け取り →  として拒否（期待どおり）

**スクショ**
- サーバーログ: ![mosquitto log](assets/acl_deny_log_20250929-0233.png)


## 2025-09-29 ACL deny テスト（サーバーログ補強）
_appended: 2025-09-29T02:35:29+0900_

## ACL deny テスト補強（サーバーログ）

**現象**: ブローカーが `daegis/gemini/out` publish を受け取り → `not authorised` として拒否（期待どおり）

**スクショ**
- サーバーログ: ![mosquitto log](assets/acl_deny_log_20250929-0233.png)


## 2025-09-29 Slack通知テスト完了
_appended: 2025-09-29T02:38:15+0900_

## Slack通知テスト完了

**現象**: Prometheus→Alertmanager→Slack 通知ルート、整形テンプレ反映済で表示成功。

**スクショ**
- Slack通知: ![alert_slack](assets/alert_slack_20250929-0237.png)


## 2025-09-29 Sentry
_appended: 2025-09-29T02:59:27+0900_

Hand-off PDF化完了。足りない画像は固定エイリアスで解消（alert_ui.png / api_vs_relay_table.png）。


## 2025-09-29 Alert UI スクショ追記
_appended: 2025-09-29T03:08:02+0900_

## Alertmanager Alerts 画面の証跡
- スクショ: ![alert_ui](assets/alert_ui.png)
- 目的: Slack通知の UI 側対となる二段証跡（発火元の可視化）


## 2025-09-29 Daegis Ark 採用（深層ログの城）
_appended: 2025-09-29T04:23:27+0900_

## 🛡️ Daegis Ark（アーク）採用 — 「全部残しても怖くない仕組み」

**定義**: Ark は Daegis の「深層ログ保管庫」。Chronicle（日誌）と Hand-off（要約）の下層で、
全入出力・メタ（who/what/when/which model/latency/corr）を**改ざん検知つき**で長期保全する。

**役割（3層モデル）**
- Hand-off（要約・中量）… レビュー用1枚絵
- Chronicle（経過・軽量）… 作業/証跡の連続記録
- **Ark（深層・重量）**… 原本/監査用の最終保管（耐改ざん・低頻度参照）

**設計 v0.1**
- 保管先: S3 Standard → 90日で Glacier Instant Retrieval → 180日で Deep Archive
- フォーマット: `jsonl.zst`（1GBローテーション、1行=1イベント）
- 改ざん検知: ロールアップ Merkle（1ファイルごとに`SHA256` + 日次`Merkle root`を Ledger 記載）
- 参照ガード: 既定は**書込専用（WORM）**。復元は申請→承認→一時バケットに**再水和**
- 秘密分離: 機微はトークン化（vault ref）、表示は**遅延復号**のみ
- コスト制御: 季節別サンプリングと**Policyタグ**（`team=`, `pII=`）で自動Tiering

**SLO**
- 書込到達率 99.99%（Ark Sink 成功/投入数）
- 再水和 ≤ 4h（Glacier→一時公開まで）
- 証跡完全性: 日次 Merkle 照合 100%

**次アクション**
1) Ark Sink（S3 Put + 日次 Merkle）をPoCブランチに追加
2) Chronicle/Hand-offから Ark 参照リンク（`ark://YYYY/MM/DD/<corr>.jsonl`）を埋め込む
3) “赤線公開”運用: 既定は要約のみ外部共有、深層は申請式


## 2025-09-29 Daegis Citadel（秘密情報の城塞）設計メモ
_appended: 2025-09-29T04:23:37+0900_

## 🏰 Daegis Citadel — 秘密情報の城塞（ver.1.0）

**目的**: APIキー/トークン/パスワードを**コード外**で一元管理し、起動時だけ**最小権限で動的注入**。

**構成**
- The Vault（保管庫）: `secrets.json.enc`（AES-256-GCM）。将来 HashiCorp Vault へ昇格可
- The Steward（執事）: systemd 連携の軽量ランチャ。要求サービスに必要分のみ**環境変数注入**

**起動フロー（例: relay）**
systemd → Steward → キーチェーンから Master Key 読み出し → Vault 復号
→ `OPENAI_API_KEY`, `MQTT_PASSWORD` だけ注入 → プロセス開始 → Steward はメモリ破棄

**フェーズ導入**
- P1: GPG暗号 + systemd ExecStartPre で復号→環境変数注入（平文ファイルは作らない）
- P2: HashiCorp Vault + AppRole / OIDC、**ローテーション**と**監査ログ**まで含める

**原則**: ゼロトラスト / 最小権限 / 非永続（メモリ注入） / ローテーション前提

