import os, aiohttp

async def call_llm(prompt: str, max_tokens: int = 600) -> str:
    key = os.getenv("OPENAI_API_KEY")
    if not key:
        raise ValueError("OPENAI_API_KEY not set")
    async with aiohttp.ClientSession() as sess:
        async with sess.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {key}", "Content-Type":"application/json"},
            json={"model":"gpt-4o-mini","messages":[{"role":"user","content":prompt}],
                  "max_tokens": max_tokens, "temperature": 0.2},
            timeout=aiohttp.ClientTimeout(total=12)
        ) as r:
            if r.status != 200:
                raise RuntimeError(f"OpenAI HTTP {r.status}")
            data = await r.json()
            return data["choices"][0]["message"]["content"].strip()
