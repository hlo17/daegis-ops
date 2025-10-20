#!/usr/bin/env bash
set -euo pipefail
ROOT="${DAEGIS_ROOT:-$HOME/daegis}"
cd "$ROOT"
TODAY="$(date +%F)"
OUT="docs/chronicle/${TODAY}/summary.md"
mkdir -p "docs/chronicle/${TODAY}"

python3 - <<'PY'
import json, pathlib, datetime
today = datetime.date.today().isoformat()
ledger = pathlib.Path("docs/chronicle/phase_ledger.jsonl")
items = []
if ledger.exists():
    for ln in ledger.read_text(encoding="utf-8").splitlines():
        try:
            r=json.loads(ln); items.append(r)
        except: pass
title="# Phase V — 監査NDJSON 統合サマリ（最新5件）\n\n"
body=[]
for r in items[-5:]:
    cid=r.get("component_id","unknown")
    topic=r.get("topic","")
    layer=", ".join(r.get("layer",[]))
    ev=r.get("evaluation",{}).get("verdict","INSUFFICIENT")
    body.append(f"## {cid} — {topic}\n- **Layer**: {layer}\n- **Evaluation**: **{ev}**\n")
out=title+"\n".join(body)
pathlib.Path(f"docs/chronicle/{today}/summary.md").write_text(out, encoding="utf-8")
print("[ok] rewrote summary.md")
PY
echo "[ok] wrote docs/chronicle/${TODAY}/summary.md"
