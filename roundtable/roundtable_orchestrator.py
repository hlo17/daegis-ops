import os, asyncio, random
from typing import List, Dict, Any, Optional

# 既存のvalidate_schemaは簡易版で内蔵
def validate_schema(data: Dict[str, Any]) -> bool:
    need = ["ai_name","scores","why"]
    if not all(k in data for k in need): return False
    s = data["scores"]
    for k in ["speed","quality","creativity","confidence"]:
        v = s.get(k)
        if not isinstance(v,int) or not (0<=v<=10): return False
    return True

# クライアント
from clients.grok import vote as grok_vote
from clients.chatgpt import vote as chatgpt_vote
from clients.gemini import vote as gemini_vote
from clients.notebooklm import vote as notebooklm_vote

CLIENT_MAP = {
    "Grok4": grok_vote,
    "ChatGPT": chatgpt_vote,
    "Gemini": gemini_vote,
    "NotebookLM": notebooklm_vote,
}

async def vote_all(task_text: str, timeout_s: float = 30.0) -> List[Dict[str, Any]]:
    agents = [a.strip() for a in os.getenv("RT_AGENTS","Grok4,ChatGPT,Gemini").split(",") if a.strip()]
    tasks = [CLIENT_MAP[a](task_text) for a in agents if a in CLIENT_MAP]
    try:
        res = await asyncio.wait_for(asyncio.gather(*tasks, return_exceptions=True), timeout=timeout_s)
    except asyncio.TimeoutError:
        return []
    votes=[]
    for r in res:
        if isinstance(r,dict) and validate_schema(r): votes.append(r)
    return votes

def _hist_score(m: Dict[str,float], maxv: Dict[str,float]) -> float:
    lt_norm = m.get("lead_time",0) / (maxv.get("lead_time",300) or 300)
    rc_norm = m.get("rework_count",0) / (maxv.get("rework_count",3) or 3)
    lt = 5 - lt_norm*5
    rc = 5 - rc_norm*5
    ur = min(m.get("user_rating",0)*2,10)
    return 0.3*lt + 0.3*rc + 0.4*ur

def select_coordinator(votes: List[Dict[str,Any]], hist: Dict[str,Dict[str,float]], alpha: float=0.6) -> Optional[str]:
    if not votes: return None
    max_lt = max([m.get("lead_time",0) for m in hist.values()] or [300])
    max_rc = max([m.get("rework_count",0) for m in hist.values()] or [3])
    maxv = {"lead_time":max_lt,"rework_count":max_rc}
    totals={}
    for v in votes:
        ai=v["ai_name"]
        cur=sum(v["scores"].values())/4.0
        h=_hist_score(hist.get(ai,{"lead_time":300,"rework_count":3,"user_rating":1.0}), maxv)
        totals[ai]=alpha*cur+(1-alpha)*h
    top=max(totals.values())
    cands=[a for a,s in totals.items() if abs(s-top)<1e-6]
    if len(cands)==1: return cands[0]
    max_ur=max(hist.get(a,{"user_rating":1.0}).get("user_rating",1.0) for a in cands)
    c2=[a for a in cands if abs(hist.get(a,{"user_rating":1.0}).get("user_rating",1.0)-max_ur)<1e-6]
    import random as _r
    return c2[0] if len(c2)==1 else _r.choice(c2)
