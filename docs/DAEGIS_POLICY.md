## Rate-limit & Burst Control (v2)
**Intent:** Keep development flowing under Copilot/LLM short-term rate limits.
**Scope:** Workflow only（コードの挙動は変更しない）

### Rules (must)
1. **Single session**: 同時に開く Copilot/LLM チャットは **1** つだけ（Web/VSCode/他端末は閉じる）。
2. **Diff-only**: 生成要求は「**Unified diffのみ**」で、説明文は別フェーズ。
3. **Granularity**: **1タスク=1ファイル=≤60行**。大きい変更は分割。
4. **Backoff**: 失敗時は **60s → 120s → 180s** の指数バックオフ。連打禁止。
5. **Fallback**: バックオフ1回目で ChatGPT/代替AIに切替え、同じ**Diff**を生成→貼付。
6. **Idempotent**: 追記は重複しないように「存在すれば何もしない」を徹底。

### Prompts (templates)
- Copilot: *"router/app.py だけ、append-only、≤60行。**Diffのみ**。アンカー：phasev_update直後。処理：…。"*
- ChatGPT フォールバック: *"Unified diff だけ返して。router/app.py、append-only、≤60行。…説明不要。"*

### Success criteria
- 直列運用で **API-one proof** が毎サイクル通る
- バックオフと代替系で "作業停止時間=最小"

### Notes
- 環境変数は**再起動時に適用**（scripts/dev/env_local.sh 経由で恒久化）
- metrics は dormant→active の切替を**再初期化1回**に限定（重複登録の抑止）