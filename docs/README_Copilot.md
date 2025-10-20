# Copilot Ops — Minimal Playbook

## How to run (serial, burst-safe)
1) セッションは1つだけ（他のCopilot/LLMは閉じる）  
2) **Diffのみ**で依頼（ユニファイドDiff、説明は不要）  
3) 失敗→**60s** 待って再実行、再失敗→ChatGPTに**同じ依頼**でDiff生成→貼付  
4) **1タスク=1ファイル=≤60行** に分割  

## Prompt snippets
- **Copilot (VS Code)**  
  `router/app.py だけ、append-only、≤60行。Unified diffのみ。アンカー: phasev_update直後。処理: tuner呼び出し1行追加。説明不要。`
- **Fallback (ChatGPT)**  
  `Unified diffだけ。router/app.py、append-only、≤60行。phasev_update直後に phasev_tune(primary_intent, latency_ms, verdict, entry) を1行追加。説明不要。`

## Always check
- `curl -s -X POST :8080/chat ...` → 200/ヘッダ/ledger  
- `tail -1 logs/decision.jsonl` → provider/ethics/tuning  
- `curl -s :8080/metrics | grep '^daegis_'`（dormantならOK）