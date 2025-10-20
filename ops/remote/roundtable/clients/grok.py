from scripts.guard.external_guard import guard_external
from scripts.guard.external_guard import ensure_external_allowed
import os, json, random, aiohttp
from typing import Optional, Dict, Any
from tenacity import retry, stop_after_attempt, wait_exponential_jitter


def _mock(ai_name: str, task_text: str) -> Dict[str, Any]:
    s = {k: random.randint(6, 10) for k in ["speed", "quality", "creativity", "confidence"]}
    return {
        "ai_name": ai_name,
        "scores": s,
        "why": f"fallback(mock) for {task_text[:20]}...",
        "needed_inputs": [],
        "constraints": [],
    }


@guard_external("'grok.py'")
async def 
    ensure_external_allowed("grok.py")vote(task_text: str) -> Optional[Dict[str, Any]]:
    key = os.getenv("GROK_API_KEY")
    if not key:
        return _mock("Grok4", task_text)

    prompt = (
        f'You are Grok4. Evaluate the task "{task_text}" on speed, quality, creativity, confidence (0-10). '
        'Respond ONLY JSON: {"ai_name":"Grok4","scores":{"speed":int,"quality":int,"creativity":int,"confidence":int},"why":"<=100","needed_inputs":[],"constraints":[]}'  # noqa: E501
    )

    @retry(stop=stop_after_attempt(2), wait=wait_exponential_jitter(min=1, max=4))
    async def call():
        async with aiohttp.ClientSession() as sess:
            async with sess.post(
                "https://api.x.ai/v1/chat/completions",
                headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
                json={
                    "model": "grok-beta",
                    "messages": [{"role": "user", "content": prompt}],
                    "max_tokens": 200,
                    "temperature": 0.2,
                },
                timeout=aiohttp.ClientTimeout(total=12),
            ) as r:
                if r.status != 200:
                    raise RuntimeError(f"HTTP {r.status}")
                data = await r.json()
                text = data["choices"][0]["message"]["content"].strip()
                # JSONでない場合は例外→retry/fallback
                return json.loads(text)

    try:
        return await call()
    except Exception:
        return _mock("Grok4", task_text)
