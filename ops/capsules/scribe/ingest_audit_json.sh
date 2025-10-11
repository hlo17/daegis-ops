#!/usr/bin/env bash
set -euo pipefail
# inputs: audits JSONL (stdin or file path)
# steps: normalize -> fill governance defaults -> assign trace_id -> rebuild system_map / rollup
ROOT="${ROOT:-$PWD}"
IN="${1:-/dev/stdin}"
OUT_DIR="$ROOT/docs/chronicle"
ROLL_DIR="$ROOT/docs/rollup"
mkdir -p "$OUT_DIR" "$ROLL_DIR"

tmp="$(mktemp)"
cat "$IN" > "$tmp"

# normalize governance defaults & trace_id
python3 - "$tmp" "$OUT_DIR/phase_ledger.norm.jsonl" <<'PY'
import sys, json, hashlib, time
inp, outp = sys.argv[1], sys.argv[2]
def h(s): return hashlib.sha1(s.encode()).hexdigest()[:12]
with open(inp) as f, open(outp, "w") as o:
    for line in f:
        if not line.strip(): continue
        rec=json.loads(line)
        gov=rec.get("governance",{})
        gov.setdefault("classification","Internal")
        gov.setdefault("storage","Citadel")
        gov.setdefault("egress","Bridge")
        gov.setdefault("dlp_hits","None")
        gov.setdefault("trace_id", f"trace-{h(str(time.time())+rec.get('component_id','unknown'))}")
        rec["governance"]=gov
        rec.setdefault("status","Confirmed")
        o.write(json.dumps(rec, ensure_ascii=False)+"\n")
print(outp)
PY

NORM="$OUT_DIR/phase_ledger.norm.jsonl"

# very-light builders for system_map.json / rollup/current.json
python3 - "$NORM" "$OUT_DIR/system_map.json" "$ROLL_DIR/current.json" <<'PY'
import sys, json, statistics as st
norm, sysmap, roll = sys.argv[1], sys.argv[2], sys.argv[3]
nodes, edges = [], []
kpi = {"canary_verdict":"unknown","hold_rate":"unknown","e5xx":"unknown","p95_ms":"unknown","adopt_block_last200":"unknown"}
by_id = {}
with open(norm) as f:
    for ln in f:
        r=json.loads(ln)
        cid=r.get("component_id","unknown")
        by_id[cid]=r
        nodes.append({
            "id": cid,
            "phase": r.get("phase","unknown"),
            "layer": r.get("layer",[]),
            "topic": r.get("topic",""),
            "status": r.get("status","Pending"),
            "evaluation": r.get("evaluation",{}),
            "files": r.get("files",[]),
            "interfaces": r.get("interfaces",{})
        })
# trivial edge inference (canary→gate)
if "oracle.l13" in by_id and "apply.l10_5_gate" in by_id:
    edges.append({"from":"oracle.l13","to":"apply.l10_5_gate","type":"data",
                  "reason":"policy_canary_verdict.jsonl → gate input"})
sysmap_obj={"generated_at":"now","phase_active":by_id.get("oracle.l13",{}).get("phase","unknown"),
            "nodes":nodes,"edges":edges,"conflicts":[]}
with open(sysmap,"w") as o: json.dump(sysmap_obj,o,ensure_ascii=False,indent=2)

# rollup KPI pick (best-effort)
if "oracle.l13" in by_id:
    ev=by_id["oracle.l13"].get("evaluation",{})
    kpi["canary_verdict"]=ev.get("verdict","unknown")
    # 試験的：evidence 文字列から数値を抽出（なければ unknown のまま）
import re
evs = by_id.get("oracle.l13",{}).get("evidence",[])
m=" ".join(evs)
def grab(name,pat):
    mm=re.search(pat,m); return float(mm.group(1)) if mm else "unknown"
kpi["hold_rate"]=grab("hold_rate", r'hold_rate\":([0-9.]+)')
kpi["e5xx"]=grab("e5xx", r'e5xx\":([0-9.]+)')
kpi["p95_ms"]=grab("p95_ms", r'p95_ms\":([0-9.]+)')
roll_obj={"phase":by_id.get("oracle.l13",{}).get("phase","unknown"),
          "goal":"考査期間の自動観測維持と情報資産防護",
          "kpi":kpi,
          "components_status":{k:v.get("evaluation",{}).get("verdict","unknown") for k,v in by_id.items()},
          "governance_summary":{"classification":"Internal","storage":"Citadel","egress":"Bridge","dlp_hits":"None","trace_id":"auto"},
          "open_gaps":["Dashboard KPI evidence","Cron snapshot","trace_id rule hardening"]}
with open(roll,"w") as o: json.dump(roll_obj,o,ensure_ascii=False,indent=2)
print(sysmap); print(roll)
PY

echo "[OK] scribe.ingest_audit_json → rebuilt system_map / rollup from: $NORM"
