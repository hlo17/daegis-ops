#!/usr/bin/env python3
import os, csv, json
from collections import defaultdict
IN="logs/train_ready_v2.csv"; OUT="logs/simbrain_v2.jsonl"
MIN_N=int(os.getenv("CC_MIN_N","40"))
RHO_MID=float(os.getenv("CC_CONSIST_RHO","0.6"))
RHO_HI=float(os.getenv("CC_CONSIST_RHO_HI","0.75"))
by=defaultdict(list)
try:
  with open(IN, newline="", encoding="utf-8") as f:
    for r in csv.DictReader(f):
      by[(r["intent"], r["window_start"])].append(float(r["lat_ms_norm"]))
except FileNotFoundError:
  print("[confidence_calibrate] no input"); raise SystemExit(0)
def tag(n,rho):
  if n<MIN_N: return "low"
  if rho>=RHO_HI: return "high"
  if rho>=RHO_MID: return "mid"
  return "low"
app=0
with open(OUT,"a",encoding="utf-8") as f:
  for (intent,win), vals in by.items():
    if not vals: continue
    pos=sum(1 for v in vals if v>=0); rho=max(pos,len(vals)-pos)/len(vals)
    conf=tag(len(vals),rho)
    f.write(json.dumps({"event":"confidence_calibrated","intent":intent,"window_start":int(win),
                        "n":len(vals),"rho":round(rho,3),"confidence_tag":conf},
                       ensure_ascii=False)+"\n"); app+=1
print(f"[confidence_calibrate] appended={app} -> {OUT}")
