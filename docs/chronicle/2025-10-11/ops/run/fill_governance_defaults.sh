#!/usr/bin/env bash
set -euo pipefail
IN="docs/chronicle/phase_ledger.jsonl"
OUT="docs/chronicle/phase_ledger.norm.jsonl"
[ -f "$IN" ] || { echo "[ERR] $IN not found"; exit 1; }
python3 - <<'PY'
import json, pathlib
IN="docs/chronicle/phase_ledger.jsonl"
OUT="docs/chronicle/phase_ledger.norm.jsonl"
defs={"classification":"Internal","storage":"Citadel","egress":"Bridge","dlp_hits":"None","trace_id":"unknown"}
lines=[ln for ln in pathlib.Path(IN).read_text(encoding="utf-8").splitlines() if ln.strip()]
out=[]
for ln in lines:
    try:
        rec=json.loads(ln)
        if not isinstance(rec,dict): continue
    except: 
        continue
    g=rec.get("governance") or {}
    if not isinstance(g,dict): g={}
    for k,v in defs.items():
        if g.get(k) in (None,"","unknown"): g[k]=v
    rec["governance"]=g
    out.append(json.dumps(rec, ensure_ascii=False))
pathlib.Path(OUT).write_text("\n".join(out)+"\n", encoding="utf-8")
print(f"[ok] wrote {OUT} ({len(out)} recs)")
PY
