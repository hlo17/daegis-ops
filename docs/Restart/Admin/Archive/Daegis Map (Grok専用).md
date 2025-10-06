# Daegis Map v3.6 — 秘書型エンジン＋役割分担（共有サマリ・統合版）

**title**: "📜 Daegis Map — unified v3.6"  
**modified**: 20251002  
**note**: 作業中にAIは**ルール追記が必要**と判断した場合、**回答末尾に追記提案**（対象ファイル明記）を必ず添える。原則：**簡潔・再現可能・安全**。

## 0) Guiding Principles & 現在地ダッシュ
1. **Simplicity** — 最もシンプルな解を優先。迷ったら最小構成を選択し、複雑化は最後に検討。  
2. **UserCentricity** — マスターの認知負荷最小化を最終基準に。  
3. **Evolution** — 完璧な計画よりも可逆な小変更の連続を優先。  

**レイヤー位置**: L4 騎士団（Halu自発化＋役割固定） ↔ L5 司令室（Slack集約・要約運用）  
**進捗**: M3 自律ループ✅ / M4 常駐化🚧 / M5 信頼性🚧 / M6 セキュリティ(未)  
**直近12hの焦点**: ①秘書型定義確定 ②プロンプト統一 ③Slack集約テスト  

## 1) Active Tasks
直近の最優先事項は以下の通りです（48時間以内に完了目標）：  
1. **Halu Relayの活性化**（Slack L5司令室の開通）。  
2. **Alertmanager→Slackへの通知貫通**（M5の完了と秘書型報告の実現）。  
3. **Decision Scribeの重複判定恒久化**（DEDUPE_OFF=1状態の解消）。  
4. **Daegis Citadel P1設計の開始**（GPG暗号＋systemd注入による機密管理、Ledger追記前提、M5 SLO基準準拠）。

## 2) Development & Operations Process & コード・ガード
**壊れた行は既知の良形へ丸ごと置換**。  

**実行単位の原則**  
- **ブロック実行**：ヒアドキュメント、SSH内でさらにシェル、複合パイプ/サブシェル、クォート3段以上、長い置換。  
- **行ごと実行**：単発確認、`export/chmod/bash n/systemctl/journalctl` 等。  
- **編集系の固定手順**：生成/置換 → **CRLF/BOM/ZWSP掃除** → `bash n` → 実行。  

実行環境の明示：`Mac:` / `Pi:` 接頭辞。  
デプロイ標準：`__pycache__`削除 → systemd再起動 → 経路テスト。  
障害切り分け順：**Broker/Bridge → Bus(MQTT) → Relay → Scribe → Slack**。  
詳細規約：`commandexecutionguide.md`（別紙）。  

**SSH × JSON × クォート運用（抜粋）**  
原則：外側 `"..."`、内側 `"` は `\"`。  
`'` を含む場合：`'...'"$VAR"'...'`（閉じ→展開→再開）。  
JSONは `printf '%s\n' "$payload"` パイプ or ヒアドキュメントで渡す。  

**ローカル出力ツールの原則**  
ツールは単一のディレクトリ（例：`~/bin`）に置き、`$PATH`に追加。  
実行は`source`コマンドではなく、`$PATH`に追加された実行可能ファイルとして直接呼び出す。  
置き場は ~/daegis/docs/。  

**Terminal Hygiene（実行粒度の基準）**  
- **ブロック実行が必須**：`<<'EOF' ... EOF`／多段クォート／リモートで `sh lc`／複合パイプ／長置換。  
- **行ごとでOK**：`systemctl status`, `journalctl ... | tail`, `export`, `chmod`, `bash n`。  
- **SSHでJSONを渡す**：外側ダブルクォート／`\"`／`printf`パイプ。  
- **トラブル時の順番**：Sentry → relay tail（自動）→ scribe “appended/skip” → Ledger → Slack permalink。  

**運用ショートカット**  
- **mdput（クリップボード→安全上書き）**：`python3 ~/daegis/ops/bin/mdput_clip.py "Daegis Map.md" clean fromclip`  
- **Ledger 追記**：`mdappend` ブロック or `mdput_clip.py "Daegis Ledger.md" fromclip`  
- **バックアップ**：保存時に `*.bak.YYYYMMDD_HHMMSS.md` を自動生成（Finderで閲覧可）。  

### 更新メモ
v3.6（20251002）：v3.4を基盤に円卓原則を§1へ正式統合。役割整理を更新（Grok斥候＋鍛冶屋補助、ChatGPT実装専任）。ガバナンスの定義を強化し、ドキュメント出力ツールの原則を明文化。SLO/KPIと運用ショートカットを維持。**既存ルール（0〜2章・付録）は変更せず整形のみ**。  
今後は **Map＝恒久ルール**、Tips/ワンライナーは **Ops Notes** に寄せる。

## 3) System Overview（把握用の統合） & 騎士団の固定役割
### 🧠 記憶と知性（Core）
**Halu**：対話中枢（議長）。  
**Daegis Memory Records**：**Logbook**（日誌）と**Daegis Ledger**（不可逆の決定録）。  
**支援構想**：Halu Relay（外部連携）/ Knowledge Engine（知識検索）は未稼働に近い。  

### ⚡️ 神経系と肉体（Infra）
**Daegis Raspberry Node**：常時稼働の心臓部。  
**Daegis Bus（MQTT）**：中枢神経。  
**Daegis Bridge / Caddy**：外部⇔内部の唯一の公式ゲートウェイ。  
**Mosquitto（127.0.0.1:1883, WSS 経由で外部）** **アカウント最小権限**：`f`（管理/UI）, `factory`（ワーカー）。  
**ACL 最小化**：必要トピックだけ read/write。  
近未来：**TLS/8883 + クライアント証明書**、Dynamic Security 検討。  
**常駐サービス（systemd）**  
- `geminirunner.service`：人間の承認/差し戻しの頭脳（control→out/status を発行）。  
- `daegisresearchlistener.service`：control を受信 → ACK → DAG 起動。  
- `researchfactory.service`：**ResearchFactory DAG の入口**（`research/out`購読）。  
  > 起動順：`After=networkonline.target mosquitto.service`。  
  > 機密は **systemd 環境（ドロップイン）**を単一の正とする（.env は置かない）。  

### 👀 感覚と反射（Observability）
収集＝**Prometheus**、可視化＝**Grafana**。  
通知＝**Alertmanager**→Slack `#daegisalerts`。  
将来：**Daegis Proactive Engine**で予兆検知と先回り提案へ。  

### 🌍 外部との接続（Interface / Tooling）
主要UI：**Slack Integration**（Halu Relay経由）。  
開発ツール：**VS Code / GitHub / Docker**。  

### Daegis Solaris / Luna / Ark（役割整理）
**Solaris**（ゲートウェイ&公開境界）  
役割：TLS終端・WSSリバプロ（Caddy/Nginx）、ZeroTrust 連携（Cloudflare Tunnel）。  
境界原則：**MQTTは外部直公開しない**。WSS 経由のみ。  
**Luna**（UIサーフェス）  
役割：`daegis/factory/research/result` / `daegis/status/research` を可視化（カード表示）。  
要件：受信は **QoS=1 + retain** を前提。相関ID（task_id）表示必須。  
**Ark**（保管・アーカイブ）  
役割：ログ/成果物の長期保存（S3→Glacier）、検索（将来 OpenSearch）。  
原則：PII/資格情報は**保管しない**。暗号化/ライフサイクル管理を徹底。  

### ✨ 将来の魂（Vision）
**Sora**：物語化・創造的対話の対となる存在。  
**Zappie構想**：判断→実行の完全自動化という最終ゴール。  

## 4) ResearchFactory DAG（標準パターン） & 秘書型完成（自発報告エンジン）の定義
**入力**：`daegis/factory/research/out`（承認済みタスク）。  
**段階**：`plan → fanout → synth → qa → publish`。  
**各段のI/Oトピック**：`daegis/factory/research/<stage>/req|res`。  
**メッセージ基底スキーマ**:  
- task_id: "string" (相関ID、必須)  
- stage: "plan|fanout|synth|qa|publish" (段階名)  
- payload: {} (段階ごとの内容)  
- meta: { "by":"worker", "ts":"RFC3339" } (実行者(by)とタイムスタンプ(ts))  
失敗時：`daegis/status/research` に `{"task_id","stage","reason","at"}` を QoS=1 / retain で通知。  
完了：`daegis/factory/research/result` に カード JSON を QoS=1 / retain で発行。  

mRNA 実装はこの雛形に差し替え、段間 JSON は 最小必須フィールド + 追加可 の前方互換。

## 5) Security & Configuration Management & Slack 集約設計
MQTTは**最小権限の専用アカウント**を発行（セクション3参照）。  
機密設定のSSOTは **systemd dropin** に集約（/etc/systemd/system/<unit>.d/override.conf）。  
将来の城塞：Daegis Citadel（Secrets 分離・集中管理）を第1優先で整備。  
公開面の原則：  
- MQTT ブローカー直公開しない。  
- 可視化/ダッシュボードのみ外部公開（ZeroTrust配下）。  
- ブリッジ/内部 API は トークン必須（ローテーション前提）。  
変更は **Ledger** に必ず確定記録（誰が／何を／なぜ）。  

**Slack 集約設計**  
- 現行（無料枠）：#daegisaidrafts に全AIの出力を集約 → Slack AIが一次要約 → NotebookLM が整合監査。  
- 中期（有料化 $20–30/月）：Zapier/Make で「集約→一次要約→NotebookLM 監査→戻し」まで自動化。  
- CrewAI/LangGraph：円卓国家フェーズで評価（今は導入しない）。

## 6) Governance: Singularity's Role & Terminal Hygiene
我々は 「完全自動化」ではなく「共同体としての意思決定」 を核に据える。  
ヒトの承認（approve/reject）を第一級のイベントとして扱い、AIは準備・整形・提示に注力。  
決定は 可逆性 を重視し、短いサイクルでの進化を前提に記録（Ledger）→配布（Handoff）。
