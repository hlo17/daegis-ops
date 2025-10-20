#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
import json, time, datetime
root = Path.home()/ "daegis" / "logs" / "halu"
src  = root / "reflection.jsonl"
if not src.exists(): raise SystemExit(0)
archive = root / f"reflection.archive.{time.strftime('%Y%m%dT%H%M%SZ', time.gmtime())}.jsonl"
tmp_active = root / "reflection.active.tmp"
now=time.time(); thr60=now-3600; kept=arch=0
with src.open("r",encoding="utf-8") as f, \
     archive.open("w",encoding="utf-8") as a, \
     tmp_active.open("w",encoding="utf-8") as w:
    for line in f:
        s=line.strip()
        if not s: continue
        try:
            o=json.loads(s); t=o.get("t","")
            ts=datetime.datetime.fromisoformat(t.replace("Z","+00:00")).timestamp() if t else 0
        except Exception: ts=0
        (w if ts>=thr60 else a).write(line+"\n")
        kept+= (ts>=thr60); arch+= (ts<thr60)
tmp_active.replace(src)
print(f"[OK] compacted reflection: kept={kept}, archived={arch}")
PY
