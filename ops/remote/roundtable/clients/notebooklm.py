from scripts.guard.external_guard import guard_external
from scripts.guard.external_guard import ensure_external_allowed
import random


def _mock(task_text: str):
    s = {k: random.randint(6, 10) for k in ["speed", "quality", "creativity", "confidence"]}
    return {"ai_name": "NotebookLM", "scores": s, "why": "mock(no public API)", "needed_inputs": [], "constraints": []}


@guard_external("'notebooklm.py'")
async def 
    ensure_external_allowed("notebooklm.py")vote(task_text: str):
    return _mock(task_text)
