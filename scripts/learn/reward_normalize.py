#!/usr/bin/env python3
import json, os, statistics as st
from pathlib import Path
IN = Path("logs/decision_enriched.jsonl"); IN2 = Path("logs/decision.jsonl")
OUT = Path("logs/train_ready_v2.csv")
WIN = int(os.getenv("RN_WINDOW_SEC","900"))
WINSOR = float(os.getenv("RN_WINSOR_PCT","0.02"))
ZMAX = float(os.getenv("RN_Z_MAX","3.5"))
def rows(p):
  if not p.exists(): return []
  for line in p.read_text(encoding="utf-8").splitlines():
    try: yield json.loads(line)
    except: pass
data=[]  # (ts,it,lat,stc)
for j in (list(rows(IN)) or list(rows(IN2))):
  ts=j.get("ts") or j.get("time") or 0
  it=j.get("intent") or j.get("intent_hint") or "unknown"
  lat=float(j.get("latency_ms", j.get("p95_ms", 0)) or 0)
  stc=int(j.get("status", j.get("status_code", 0)) or 0)
  if lat>0 and it!="unknown": data.append((ts,it,lat,stc))
from collections import defaultdict
b=defaultdict(list)
for ts,it,lat,stc in data: b[(it,int(ts//WIN))].append((lat,stc))
OUT.parent.mkdir(parents=True, exist_ok=True)
wrote=0
with OUT.open("w",encoding="utf-8") as f:
  f.write("intent,window_start,lat_ms_norm,hold,e5xx,causal\n")
  for (it,win), lst in b.items():
    lats=[x[0] for x in lst]
    if len(lats)<5:
      for lat,stc in lst:
        f.write(f"{it},{win*WIN},{lat},0,{1 if 500<=stc<600 else 0},neutral\n"); wrote+=1
      continue
    s=sorted(lats); k=max(1,int(len(s)*WINSOR)); lo,hi=s[k],s[-k-1]
    lats_w=[min(max(x,lo),hi) for x in lats]
    mu=st.mean(lats_w); sd=st.pstdev(lats_w) or 1.0
    for (lat,stc),zw in zip(lst,[(x-mu)/sd for x in lats_w]):
      if abs(zw)>ZMAX: continue
      hold=1 if lat>3000 else 0; e5=1 if 500<=stc<600 else 0
      causal="neutral" if e5 else "affected"
      lat_norm=((min(max(lat,lo),hi)-mu)/sd) if sd else 0
      f.write(f"{it},{win*WIN},{lat_norm},{hold},{e5},{causal}\n"); wrote+=1
print(f"[reward_normalize] rows={wrote} out=logs/train_ready_v2.csv")
