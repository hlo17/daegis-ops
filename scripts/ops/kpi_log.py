#!/usr/bin/env python3
import json, sys, time, hashlib, os
from pathlib import Path
HOME=os.environ.get("DAEGIS_HOME", str(Path.home())); LOG=f"{HOME}/daegis/logs/kpi.jsonl"
os.makedirs(f"{HOME}/daegis/logs", exist_ok=True)

def h(x): return hashlib.sha256(str(x).encode()).hexdigest()[:12]

def _int(x, d=0):
    try: return int(float(str(x)))
    except: return d
def _float(x, d=0.0):
    try: return float(str(x))
    except: return d

now=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

# 入力例: task_id=abc chain="grok>perplexity>gemini" tokens=12000 tool_min=6 rating=4 lead_s=540 rework=0
data={}
for arg in sys.argv[1:]:
    if '=' in arg:
        k,v=arg.split('=',1); data[k]=v
rec={
  "ts": now,
  "task_id_hash": h(data.get("task_id","-")),
  "chain": data.get("chain","std"),
  "tokens": _int(data.get("tokens",0)),
  "tool_minutes": _float(data.get("tool_min",0)),
  "user_rating": _float(data.get("rating",0)),
  "lead_time_s": _float(data.get("lead_s",0)),
  "rework_count": _int(data.get("rework",0)),
  "cost_estimate": (0.000002 * _int(data.get("tokens",0))) + (0.02 * _float(data.get("tool_min",0)))  # 例: $2/1M tok, $0.02/min
}
with open(LOG,"a",encoding="utf-8") as f: f.write(json.dumps(rec,ensure_ascii=False)+"\n")
print(json.dumps({"ok":True,"saved":rec},ensure_ascii=False))
