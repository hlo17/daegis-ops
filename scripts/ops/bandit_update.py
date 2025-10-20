#!/usr/bin/env python3
import os, json, time, math
from pathlib import Path
HOME=str(Path.home())
KPI=f"{HOME}/daegis/logs/kpi.jsonl"
POL=f"{HOME}/daegis/state/policy.json"
os.makedirs(f"{HOME}/daegis/state", exist_ok=True)

# 報酬: -cost + a*rating + b*(baseline - lead), baseline=900s
A=1.0; B=0.001; BASE=900.0
scores={}
if os.path.exists(KPI):
    for ln in open(KPI,encoding="utf-8"):
        try: r=json.loads(ln)
        except: continue
        rew = -float(r.get("cost_estimate",0)) + A*float(r.get("user_rating",0)) + B*(BASE - float(r.get("lead_time_s",0)))
        c   = r.get("chain","std")
        scores.setdefault(c, []).append(rew)

# EMAで平滑
def ema(xs, alpha=0.4):
    v=None
    for x in xs:
        v = x if v is None else (alpha*x + (1-alpha)*v)
    return v if v is not None else 0.0

means={c:ema(v) for c,v in scores.items()}
if not means: means={"std":1.0}
# softmax→確率
mx=max(means.values()); exps={c:math.exp(v-mx) for c,v in means.items()}
s=sum(exps.values()); probs={c:round(exps[c]/s,3) for c in exps}
open(POL,"w",encoding="utf-8").write(json.dumps({"ts":time.time(),"probs":probs},ensure_ascii=False))
print(json.dumps({"ok":True,"probs":probs},ensure_ascii=False))
