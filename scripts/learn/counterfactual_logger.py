#!/usr/bin/env python3
import json, pathlib
AP="logs/policy_apply_plan.jsonl"; L13="logs/policy_canary_verdict.jsonl"; OUT="logs/counterfactuals.jsonl"
def verdict_tail():
  v="unknown"
  p=pathlib.Path(L13)
  if not p.exists(): return v
  for line in p.read_text(encoding="utf-8").splitlines()[-200:]:
    try:
      j=json.loads(line)
      if j.get("event")=="canary_verdict": v=j.get("verdict","unknown")
    except: pass
  return v
ver=verdict_tail(); wrote=0
p=pathlib.Path(AP)
if not p.exists(): print("[counterfactual] no apply_plan"); raise SystemExit(0)
with open(OUT,"a",encoding="utf-8") as out, open(AP,encoding="utf-8") as f:
  for line in f:
    try: j=json.loads(line)
    except: continue
    if j.get("event") not in ("apply_plan","apply_plan_skip"): continue
    intent=j.get("intent","unknown")
    actual=j.get("proposed_ms") or j.get("after")
    alt=j.get("prev_ms") or j.get("before")
    if actual is None or alt is None: continue
    out.write(json.dumps({"event":"counterfactual","intent":intent,"cf_actual_ms":actual,
                           "cf_alt_ms":alt,"delta_ms":(actual-alt),"l13_verdict":ver},
                          ensure_ascii=False)+"\n"); wrote+=1
print(f"[counterfactual] appended={wrote} -> {OUT}")
