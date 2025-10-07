# daegis-ops
Daegis の運用 Runbook / Sentry スクリプト置き場。
- Runbook: ops/runbooks/
- Sentry:  ops/sentry/sentry.sh

## Hooks
Run `bash tools/setup-hooks.sh` after cloning.

## Hooks
Run `bash tools/setup-hooks.sh` after cloning.


## Guides / Runbooks
- DRB Status (2025-10-04): ops/runbooks/DRB-Status-2025-10-04.md
- Utility Manual: ops/runbooks/Daegis Utility Manual.md

> **Start here for any AI:** ops/runbooks/AI-Handoff.md

---

## 🧭 Daegis Docs Policy（ハンドオフ運用ルール）

| 項目 | 内容 |
|------|------|
| **Daily (日次)** | `brief.md` を上書き更新（最新状況だけ） |
| **Weekly (週次)** | `docs/Daegis Chronicle.md` に追記（決定・履歴） |
| **Never** | `docs/archive/` のファイルを直接編集しない |
| **Commit message** | `handoff: daily update YYYY-MM-DD` |
| **更新手順** | 1️⃣ `./tools/init-brief.sh` → 2️⃣ `./tools/init-chronicle.sh` → 3️⃣ `git add -A && git commit -m "handoff: daily update $(date +%F)" && git push` |

これで、チャット引き継ぎ時に迷うことがゼロになります。

---

## ✅ Daegis Handoff v2.0 — 2025-10-05

- Slack自動投稿（#daegis-brief）導入完了
- ChatGPTハンドオフ要約連携稼働
- Runbook v2.0 反映済み（AI-Handoff.md）
- Pi上で毎朝9:00に自動ブリーフ投稿 (`cron`)
- 以後は **brief + chronicle のみ運用**（更新・履歴の2ファイル体制）

**運用確認**
```bash
# 手動テスト
/home/f/daegis/tools/rt-digest.sh
tail -n 20 /home/f/daegis/logs/rt-digest.log
# cron登録確認
crontab -l | grep digest
