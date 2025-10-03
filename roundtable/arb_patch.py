import os, aiohttp, json, asyncio
from typing import List
from pydantic import ValidationError
from compressor_arbitrator import SynthesizedOutput  # 既存モデルを利用

OPENAI_URL = "https://api.openai.com/v1/chat/completions"
MODEL = "gpt-4o-mini"

def _prompt(task_description: str, compressed: List[dict]) -> str:
    return (
f"""Arbitrate proposals for "{task_description}".
Input JSON: {json.dumps(compressed, ensure_ascii=False)}
Return ONLY valid JSON for SynthesizedOutput schema with keys:
- differences_table: [{{"aspect": str<=50, "proposals":[{{"ai_name":str, "summary":str<=100}}]}}]
- adopted_items:    [{{"ai_name":str, "item":str<=100, "reason":str<=50}}]
- rejected_items:   same shape as adopted_items
- synthesized_proposal: str<=500
- evaluation_weights: {{"speed_weight":float(0..1), "quality_weight":float(0..1), "other_weight":float(0..1), "formula_used":str}}
No markdown, no commentary. STRICT JSON ONLY."""
    )

async def arbitrate_openai(compressed_list: List, speed_priority: bool, quality_priority: bool, task_description: str):
    key = os.getenv("OPENAI_API_KEY")
    if not key:
        # キー無しなら既存 mock に任せたいが、ここは例外→上位のフェイルオープンに委ねる
        raise RuntimeError("OPENAI_API_KEY not set")

    # Pydanticモデルに通しやすいよう最小辞書化
    comp_dicts = []
    for c in compressed_list:
        comp_dicts.append(c.dict() if hasattr(c, "dict") else {
            "ai_name": getattr(c, "ai_name", "unknown"),
            "proposal_summary": getattr(c, "proposal_summary", ""),
            "purpose": getattr(c, "purpose", ""),
            "steps": getattr(c, "steps", []),
            "risks": getattr(c, "risks", []),
            "dependencies": getattr(c, "dependencies", []),
            "verification": getattr(c, "verification", ""),
            "total_length": getattr(c, "total_length", 0),
        })

    payload = {
        "model": MODEL,
        "messages": [{"role":"user","content": _prompt(task_description, comp_dicts)}],
        "max_tokens": 600,
        "temperature": 0.2,
    }

    timeout = aiohttp.ClientTimeout(total=12)
    async with aiohttp.ClientSession(timeout=timeout) as sess:
        async with sess.post(
            OPENAI_URL,
            headers={"Authorization": f"Bearer {key}", "Content-Type":"application/json"},
            json=payload
        ) as r:
            if r.status != 200:
                raise RuntimeError(f"OpenAI HTTP {r.status}")
            data = await r.json()
            text = data["choices"][0]["message"]["content"].strip()

    try:
        return SynthesizedOutput.parse_raw(text)
    except ValidationError as ve:
        # 返却が崩れたら最小フォールバック（既存 mock に任せたい場合はここで例外を投げ直してもOK）
        return SynthesizedOutput(
            differences_table=[],
            adopted_items=[],
            rejected_items=[],
            synthesized_proposal=f"Synthesized (fallback due to invalid JSON): {task_description}",
            evaluation_weights={"speed_weight":0.7,"quality_weight":0.3,"other_weight":0.2,"formula_used":"fallback: invalid-json"}
        )
