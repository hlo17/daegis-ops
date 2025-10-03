import os, asyncio, logging
from typing import List, Dict, Any, Optional

from roundtable_orchestrator import validate_schema  # 既存の厳格バリデーション再利用

# 各 client の vote を読み込み（存在しないものはスキップ）
try:
    from clients.grok import vote as grok_vote
except Exception:
    grok_vote = None
try:
    from clients.chatgpt import vote as chatgpt_vote
except Exception:
    chatgpt_vote = None
try:
    from clients.perplexity import vote as perplexity_vote
except Exception:
    perplexity_vote = None
try:
    from clients.gemini import vote as gemini_vote
except Exception:
    gemini_vote = None
try:
    from clients.notebooklm import vote as notebooklm_vote
except Exception:
    notebooklm_vote = None

CLIENT_MAP = {
    "Grok4": grok_vote,
    "ChatGPT": chatgpt_vote,
    "Perplexity": perplexity_vote,
    "Gemini": gemini_vote,
    "NotebookLM": notebooklm_vote,
}

log = logging.getLogger("clients_bridge")

async def vote_all_ext(task_text: str, timeout_s: float = 30.0) -> List[Dict[str, Any]]:
    agents_str = os.getenv("RT_AGENTS", "Grok4,ChatGPT,Perplexity")
    agents = [a.strip() for a in agents_str.split(",") if a.strip()]
    tasks = []
    for a in agents:
        fn = CLIENT_MAP.get(a)
        if callable(fn):
            tasks.append(fn(task_text))
        else:
            log.warning(f"Unknown or missing client: {a}")

    if not tasks:
        return []

    try:
        results = await asyncio.wait_for(asyncio.gather(*tasks, return_exceptions=True), timeout=timeout_s)
    except asyncio.TimeoutError:
        return []

    votes, errs = [], []
    for res in results:
        if isinstance(res, dict) and validate_schema(res):
            votes.append(res)
        elif isinstance(res, Exception):
            errs.append(str(res))
    if errs:
        print("[rt] vote_all_ext errors:", errs)
    return votes
