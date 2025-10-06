# AI-Handoff — Runbook v1.0
updated: 2025-10-05T19:00JST
owner: f (@round-table)

---

## 🎯 目的
Daegis プロジェクトのチャット／作業を別セッションへ安全に引き継ぐための手順を最短化する。  
**原則：「手順ゼロのハンドオフ」**を目指す。

---

## 🚀 手順（5分完了）

| 手順 | コマンド | 内容 |
|------|-----------|------|
| 1️⃣ | `./tools/init-brief.sh` | 今日の `brief.md` 雛形を生成 |
| 2️⃣ | `./tools/init-chronicle.sh` | 今日の日付ブロックを Chronicle に追記 |
| 3️⃣ | `git add -A && git commit -m "handoff: daily update $(date +%F)" && git push` | コミット＋プッシュ |
| 4️⃣ | ChatGPT に “Daegis Hand-off 実施” とだけ伝える | 最新ブリーフを自動反映して新チャットに引き継ぎ |
| 5️⃣ | （オプション） `./tools/rt-digest.sh` | Slack ダイジェスト投稿を実行 |

---

## ⚙️ 管理ポリシー
- **Brief.md**：常に最新の状態を1枚で維持（上書き）
- **Chronicle.md**：事実を日付順に追記（改竄禁止）
- **Archive/**：過去資産（直接編集禁止）
- **Runbook自身**：更新時は `docs:` prefix でコミット

---

## 📎 関連
- README.md → 「Daegis Docs Policy」
- tools/init-brief.sh
- tools/init-chronicle.sh

---

✅ **最終目標**：  
誰がチャットを開いても、`brief.md` を見るだけで「今どこ・次何」が分かる状態。

---

## 🤖 自動ハンドオフ補助（v2.0）

| 区分 | 内容 |
|------|------|
| **Slack投稿** | `./tools/rt-digest.sh` が `brief.md` の要約を Slack に投稿 |
| **ChatGPT要約** | 新チャット開始時に `[Daegis Hand-off 実施]` とだけ入力すると自動で要約生成 |
| **設定ファイル** | `.env` または `~/.config/daegis.env` に `SLACK_WEBHOOK_URL` を記載 |

✅ これにより、更新・共有・引き継ぎがすべて1コマンドで完結します。

---

# 🚀 Daegis Handoff v3.0 — 完全自動フェーズ
updated: 2025-10-05T19:15JST
owner: f (@round-table)

---

## 🎯 目的
「手順ゼロで運用・共有・引き継ぎ」が完結する状態を維持する。  
Slack・ChatGPT・Grafana が自律的に同期し、  
人間の操作は“確認だけ”に縮退することを最終目標とする。

---

## 🪶 引き継ぎ時にやること（人間がやる最小作業）

| 区分 | 操作 | コマンド |
|------|------|-----------|
| **A. 状況更新（朝／任意）** | 雛形生成＋履歴追記 | `./tools/init-brief.sh && ./tools/init-chronicle.sh` |
| **B. 更新反映＆共有** | Git反映＋Slack投稿 | `git add -A && git commit -m "handoff: daily update $(date +%F)" && git push && ./tools/rt-digest.sh` |
| **C. 引き継ぎトリガー** | 新しいChatGPTチャット開始時に貼る | `[Daegis Hand-off 実施]` |
| **D. 状況確認（自動投稿確認）** | Slack /logs 確認 | `tail -n 20 /home/f/daegis/logs/rt-digest.log` |

---

## 🤖 全自動ワンコマンド（フルサイクル）
※人間が介入せず、すべて自動化する場合に使用。

```bash
# === daily-auto-handoff.sh ===
#!/usr/bin/env bash
set -euo pipefail
cd /home/f/daegis

# 1. 雛形更新
./tools/init-brief.sh && ./tools/init-chronicle.sh

# 2. Git反映
git add -A
git commit -m "handoff: daily auto-update $(date +%F)" || true
git push || true

# 3. Slack投稿
./tools/rt-digest.sh

---

## 🤖 v3.1 — Zero-Handoff仕様（AI構文対応）
- Slack投稿は `[handoff_digest_start] ... [handoff_digest_end]` タグで構造化
- AIはこの範囲を自動抽出し、次セッションの初期状態を再構成
- 人間はSlack本文を見れば全体把握可能
- 実運用ファイル: tools/rt-digest.sh（整形済み投稿）
- 手動引き継ぎは不要：「[Daegis Hand-off 実施]」だけでOK
