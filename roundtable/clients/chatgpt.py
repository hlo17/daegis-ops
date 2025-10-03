import os, json, random, aiohttp
from typing import Optional, Dict, Any
from tenacity import retry, stop_after_attempt, wait_exponential_jitter

def _mock(task_text: str) -> Dict[str, Any]:
    s = {k: random.randint(6,10) for k in ["speed","quality","creativity","confidence"]}
    return {"ai_name":"ChatGPT","scores":s,"why":f"fallback(mock) for {task_text[:20]}...","needed_inputs":[],"constraints":[]}

async def vote(task_text: str) -> Optional[Dict[str, Any]]:
    key = os.getenv("OPENAI_API_KEY")
    if not key:
        return _mock(task_text)

    prompt = (f'You are ChatGPT. Evaluate the task "{task_text}" (0-10 for speed/quality/creativity/confidence). '
              'ONLY JSON: {"ai_name":"ChatGPT","scores":{"speed":int,"quality":int,"creativity":int,"confidence":int},"why":"<=100","needed_inputs":[],"constraints":[]}')

    @retry(stop=stop_after_attempt(2), wait=wait_exponential_jitter(min=1,max=4))
    async def call():
        async with aiohttp.ClientSession() as sess:
            async with sess.post(
                "https://api.openai.com/v1/chat/completions",
                headers={"Authorization": f"Bearer {key}","Content-Type":"application/json"},
                json={"model":"gpt-4o-mini","messages":[{"role":"user","content":prompt}],"max_tokens":200,"temperature":0.2},
                timeout=aiohttp.ClientTimeout(total=12)
            ) as r:
                if r.status != 200:
                    raise RuntimeError(f"HTTP {r.status}")
                data = await r.json()
                text = data["choices"][0]["message"]["content"].strip()
                return json.loads(text)

    try:
        return await call()
    except Exception:
        return _mock(task_text)
