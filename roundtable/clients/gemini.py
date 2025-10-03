import os, json, random, aiohttp
from typing import Optional, Dict, Any
from tenacity import retry, stop_after_attempt, wait_exponential_jitter

def _mock(task_text: str) -> Dict[str, Any]:
    s = {k: random.randint(6,10) for k in ["speed","quality","creativity","confidence"]}
    return {"ai_name":"Gemini","scores":s,"why":f"fallback(mock) for {task_text[:20]}...","needed_inputs":[],"constraints":[]}

async def vote(task_text: str) -> Optional[Dict[str, Any]]:
    key = os.getenv("GOOGLE_API_KEY")
    if not key:
        return _mock(task_text)

    prompt = (f'You are Gemini. Evaluate the task "{task_text}" (0-10). '
              'ONLY JSON: {"ai_name":"Gemini","scores":{"speed":int,"quality":int,"creativity":int,"confidence":int},"why":"<=100","needed_inputs":[],"constraints":[]}')

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={key}"
    body = {"contents":[{"parts":[{"text":prompt}]}]}

    @retry(stop=stop_after_attempt(2), wait=wait_exponential_jitter(min=1,max=4))
    async def call():
        async with aiohttp.ClientSession() as sess:
            async with sess.post(url, json=body, timeout=aiohttp.ClientTimeout(total=12)) as r:
                if r.status != 200:
                    raise RuntimeError(f"HTTP {r.status}")
                data = await r.json()
                text = data["candidates"][0]["content"]["parts"][0]["text"].strip()
                return json.loads(text)

    try:
        return await call()
    except Exception:
        return _mock(task_text)
