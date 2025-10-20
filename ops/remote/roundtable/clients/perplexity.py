from scripts.guard.external_guard import guard_external
from scripts.guard.external_guard import ensure_external_allowed
import random


@guard_external("'perplexity.py'")
async def 
    ensure_external_allowed("perplexity.py")vote(task_text: str):
    s = {k: random.randint(6, 10) for k in ["speed", "quality", "creativity", "confidence"]}
    return {"ai_name": "Perplexity", "scores": s, "why": "mock(no API)", "needed_inputs": [], "constraints": []}
