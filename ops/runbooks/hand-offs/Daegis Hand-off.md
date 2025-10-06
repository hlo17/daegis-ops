
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

\`\`\`bash
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
\`\`\`

登録例（cron）：
\`\`\`
0 8 * * * /home/f/daegis/daily-auto-handoff.sh >> /home/f/daegis/logs/daily-auto.log 2>&1
\`\`\`

---

## 📊 可観測性 (Grafana/Prometheus連携)

| 項目 | ソース | 説明 |
|------|--------|------|
| **Slack投稿履歴** | `/home/f/daegis/logs/rt-digest.log` | LokiまたはPromtail経由でGrafana可視化 |
| **成功率／失敗率** | `grep -c "✅ Slack投稿完了"` vs `"❌"` | 成功率メトリクス生成可 |
| **ブリーフ変化量** | `git diff --stat HEAD~1 brief.md` | 日次の更新行数をGrafanaパネル化 |

---

## 🧠 ChatGPT 自動ブリーフ生成（次段階）

> `brief.md` をAIが要約・生成し、自動で commit/push する仕組み。

テンプレート呼び出し（ChatGPTへ入力）：
\`\`\`
[Daegis Auto-Brief]
・Chronicleと過去briefを参照し、最新状況／次やること／リスクを3–5行ずつ生成。
・出力は brief.md にそのまま書き込めるMarkdown形式。
・出力冒頭に `# Daegis Brief — Handoff (Rolling)` を含める。
\`\`\`

このテンプレートを毎朝 ChatGPT API に投げると、自動で brief.md を更新できます。

---

## ✅ まとめ

| 要素 | 状態 | 更新手段 |
|------|------|-----------|
| brief.md | 最新状態1枚 | 自動／手動両対応 |
| docs/Daegis Chronicle.md | 履歴追記 | init-chronicle.sh |
| tools/rt-digest.sh | Slack連携 | cron自動／手動OK |
| daily-auto-handoff.sh | 全自動統括 | cron登録推奨 |
| Grafana | 観測ダッシュボード | Loki + Promtail で展開可 |
| ChatGPT | 要約＆ブリーフ生成 | API or [Daegis Auto-Brief] トリガ |

---
