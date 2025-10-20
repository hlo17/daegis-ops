#!/usr/bin/env bash
set -euo pipefail
ROOT="${DAEGIS_ROOT:-$HOME/daegis}"
cd "$ROOT"
IN="docs/chronicle/phase_ledger.jsonl"
OUT="docs/chronicle/phase_ledger.norm.jsonl"
[ -f "$IN" ] || { echo "[ERR] $IN not found (run the 12-2 apply step first)"; exit 1; }

python3 - <<'PY'
import json, pathlib
IN="docs/chronicle/phase_ledger.jsonl"
OUT="docs/chronicle/phase_ledger.norm.jsonl"
defs={"classification":"Internal","storage":"Citadel","egress":"Bridge","dlp_hits":"None","trace_id":"unknown"}
p = pathlib.Path(IN)
lines=[ln for ln in p.read_text(encoding="utf-8").splitlines() if ln.strip()]
out=[]
for ln in lines:
    try:
        rec=json.loads(ln)
        if not isinstance(rec,dict): continue
    except Exception:
        continue
    g=rec.get("governance") or {}
    if not isinstance(g,dict): g={}
    for k,v in defs.items():
        if g.get(k) in (None,"","unknown"): g[k]=v
    rec["governance"]=g
    out.append(json.dumps(rec, ensure_ascii=False))
pathlib.Path(OUT).parent.mkdir(parents=True, exist_ok=True)
pathlib.Path(OUT).write_text("\n".join(out)+"\n", encoding="utf-8")
print(f"[ok] wrote {OUT} ({len(out)} recs)")
PY
