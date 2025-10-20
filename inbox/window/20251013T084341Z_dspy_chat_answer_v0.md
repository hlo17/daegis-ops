---
window: garden-gate
type: handoff
topic: "DSPy: COPRO [chat_answer] — DRY eval v0"
from: "agent:lyra"
to: "agent:kai"
priority: high
due: "+24h"
---

## 🎯 目的
chat_answer intent の誤反応低減（要約と回答の混線除去）

## 🧪 DoD（5+1行形式）
- metric: daegis_dspy_best_score{intent="chat_answer"}
- threshold: best_score >= 0.70
- timeout: 180s
- safety: DryRun
- output: docs/overview/dspy/chat_answer_summary.md
- context: train_ready_v2.csv#sha1

## ⚙️ 制約
- すべてDRYモード（外部API・書込禁止）
- Factory Gate=B（監視）で運転
- logs/dspy/*.jsonl, docs/overview/dspy/ への出力のみ許可

## 🕒 期限
- 発行から24時間以内に result カード（to: agent:lyra）を返却

## 備考
初回DRYテスト。成功後に GEPAへ移行可。
