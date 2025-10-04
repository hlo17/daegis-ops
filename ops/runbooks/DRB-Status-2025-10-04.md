# Daegis Roundtable Status — 2025-10-04


Daegis Roundtable — 全体像（2025-10-04）
目的
Daegis Roundtable (DRB) は「AI協働ネットワーク」のMVP基盤。Guidelines v0.3（協調・適応・検証）に沿って Day0–3: 基盤構築 ≈80%／Day4–7: 比較・レビュー準備中。
✅ 完了（要点）
- 基盤・鍵管理：Python/venv、キーはKeychain/環境変数化、PoCログ雛形。
- API直叩き：OpenAI直叩き動作（レイテンシ記録）。
- Relay/Scribe：常駐・Ledger自動追記（answers-YYYYMMDD.jsonl）、Slack投稿（permalink取得）。
- Slack通知配線：Alertmanager→Slack 経路確立（テンプレ適用、見栄え微調整残）。
- MQTT/Broker：Mosquitto最小構成（認証/ACL/systemd）、gemini_runner購読、research-factory購読、UI最小カード、ACL拡充（result/status）。
- 運用ツール：Sentry（Chronicle追記）、mdput/mdappend/ledgerdiff、Daegis Map v3.1反映、paho-mqtt v1警告は既知（v2移行予定）。
- Orchestrator：/orchestrate 稼働、G1投票（RT_AGENTS=Grok4,ChatGPT モック含む）、G2仲裁（OpenAI固定/注記）、G3 Ledger拡張（rt_agents/arb_backend/latency_ms/status 等フィールド）、同時実行上限（ROUND_MAX_CONCURRENCY=2）。
- normalize導入：orchestrate_patch.py に応答正規化ミドルウェア。RT_SYNTH_KEYSで synthesized_proposal のフォールバック順を動的指定（例：summary,note,message,task）。デフォルトは note,message,task,("synth: (none)")。
- Digestバッチ：rt-digest を systemd timer（毎日09:05）で運用、手動実行OK。
- 秘密情報対策（自己防衛レイヤ）：
    - GitHub Push Protectionを解除不要にするレベルで履歴からの秘匿情報除去（filter-branch適用後、再プッシュ）。
    - ローカルHook：.githooks/pre-commit（Slack webhook検出＋文字種正規化）、.githooks/pre-push（BLOBスキャン）。
    - CI：secret-grep.yml（Slack webhookパターン検出）、md-typography-guard.yml（スマート引用符/ダッシュ/不可視空白検出）。
    - 運用：tools/setup-hooks.sh、tools/scan-typography.sh、tools/fix-typography.sh。
⏳ 残タスク（優先度順）
1. 比較整理（API直 vs Relay）：1枚スライド（数値＋スクショ）
2. Alertmanager見栄え：テンプレ微調整
3. mRNA本実装：DAGトピック差し替え＆JSONスキーマ準拠
4. UI/ACLテスト証跡：result/status表示・拒否分のスクショ
5. Gemini呼び出し：runnerエコー→実API、Rate制御
6. 月次Ledgerサマリー：>30日の圧縮＆重複マージ
48時間アクション
- Day 1（今日）：Digest投稿確認・KPI抽出・Slash Commandリスク診断ドラフト
- Day 2（明日）：Runbook v1レビュー（権限・corr_id・systemd順序）
KPIスナップショット（直近観測の例）
- ステータス：ok 継続
- レイテンシ：平均 ≈ 1ms（テスト経路／モック混在）
- 協調者比率：ChatGPT ≈ 57%（モック含む）、未定義/空は改善中
- 投票：0〜2票の低頻度（PoC仕様）
リスク・注記
- votes と arb_backend の未充足があり、KPI精度の解像度は限定的。ただし運用継続に支障はなし。
- paho-mqtt v2への移行で非推奨警告は解消予定。
付録A：使い方（現場ショートリファレンス）
- Hooks 有効化：
    bash tools/setup-hooks.sh
    （core.hooksPath を .githooks に設定）
- ホットキー：

```
source tools/hotkeys.sh
hk help
hk deliver <DST>     # <=96KBはheredoc、それ以外はbase64で安全搬送
hk hooks-fix         # フックのシバン/改行/pipefailを自動修復
```

- 文字種ガード：
    - 検出のみ：bash tools/scan-typography.sh
    - 自動修正：bash tools/fix-typography.sh（修正後に git add して再コミット）
- RT 正規化フォールバックの指定：
    /etc/roundtable/rt.env に RT_SYNTH_KEYS="summary,note,message,task" を設定 → systemctl restart roundtable

# Daegis Roundtable Status — 2025-10-04


Daegis Roundtable — 全体像（2025-10-04）
目的
Daegis Roundtable (DRB) は「AI協働ネットワーク」のMVP基盤。Guidelines v0.3（協調・適応・検証）に沿って Day0–3: 基盤構築 ≈80%／Day4–7: 比較・レビュー準備中。
✅ 完了（要点）
- 基盤・鍵管理：Python/venv、キーはKeychain/環境変数化、PoCログ雛形。
- API直叩き：OpenAI直叩き動作（レイテンシ記録）。
- Relay/Scribe：常駐・Ledger自動追記（answers-YYYYMMDD.jsonl）、Slack投稿（permalink取得）。
- Slack通知配線：Alertmanager→Slack 経路確立（テンプレ適用、見栄え微調整残）。
- MQTT/Broker：Mosquitto最小構成（認証/ACL/systemd）、gemini_runner購読、research-factory購読、UI最小カード、ACL拡充（result/status）。
- 運用ツール：Sentry（Chronicle追記）、mdput/mdappend/ledgerdiff、Daegis Map v3.1反映、paho-mqtt v1警告は既知（v2移行予定）。
- Orchestrator：/orchestrate 稼働、G1投票（RT_AGENTS=Grok4,ChatGPT モック含む）、G2仲裁（OpenAI固定/注記）、G3 Ledger拡張（rt_agents/arb_backend/latency_ms/status 等フィールド）、同時実行上限（ROUND_MAX_CONCURRENCY=2）。
- normalize導入：orchestrate_patch.py に応答正規化ミドルウェア。RT_SYNTH_KEYSで synthesized_proposal のフォールバック順を動的指定（例：summary,note,message,task）。デフォルトは note,message,task,("synth: (none)")。
- Digestバッチ：rt-digest を systemd timer（毎日09:05）で運用、手動実行OK。
- 秘密情報対策（自己防衛レイヤ）：
    - GitHub Push Protectionを解除不要にするレベルで履歴からの秘匿情報除去（filter-branch適用後、再プッシュ）。
    - ローカルHook：.githooks/pre-commit（Slack webhook検出＋文字種正規化）、.githooks/pre-push（BLOBスキャン）。
    - CI：secret-grep.yml（Slack webhookパターン検出）、md-typography-guard.yml（スマート引用符/ダッシュ/不可視空白検出）。
    - 運用：tools/setup-hooks.sh、tools/scan-typography.sh、tools/fix-typography.sh。
⏳ 残タスク（優先度順）
1. 比較整理（API直 vs Relay）：1枚スライド（数値＋スクショ）
2. Alertmanager見栄え：テンプレ微調整
3. mRNA本実装：DAGトピック差し替え＆JSONスキーマ準拠
4. UI/ACLテスト証跡：result/status表示・拒否分のスクショ
5. Gemini呼び出し：runnerエコー→実API、Rate制御
6. 月次Ledgerサマリー：>30日の圧縮＆重複マージ
48時間アクション
- Day 1（今日）：Digest投稿確認・KPI抽出・Slash Commandリスク診断ドラフト
- Day 2（明日）：Runbook v1レビュー（権限・corr_id・systemd順序）
KPIスナップショット（直近観測の例）
- ステータス：ok 継続
- レイテンシ：平均 ≈ 1ms（テスト経路／モック混在）
- 協調者比率：ChatGPT ≈ 57%（モック含む）、未定義/空は改善中
- 投票：0〜2票の低頻度（PoC仕様）
リスク・注記
- votes と arb_backend の未充足があり、KPI精度の解像度は限定的。ただし運用継続に支障はなし。
- paho-mqtt v2への移行で非推奨警告は解消予定。
付録A：使い方（現場ショートリファレンス）
- Hooks 有効化：
    bash tools/setup-hooks.sh
    （core.hooksPath を .githooks に設定）
- ホットキー：

```
source tools/hotkeys.sh
hk help
hk deliver <DST>     # <=96KBはheredoc、それ以外はbase64で安全搬送
hk hooks-fix         # フックのシバン/改行/pipefailを自動修復
```

- 文字種ガード：
    - 検出のみ：bash tools/scan-typography.sh
    - 自動修正：bash tools/fix-typography.sh（修正後に git add して再コミット）
- RT 正規化フォールバックの指定：
    /etc/roundtable/rt.env に RT_SYNTH_KEYS="summary,note,message,task" を設定 → systemctl restart roundtable

