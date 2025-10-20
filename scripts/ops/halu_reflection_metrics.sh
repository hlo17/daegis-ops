#!/usr/bin/env bash
set -euo pipefail
REF="$HOME/daegis/logs/halu/reflection.jsonl"
OUT="$HOME/daegis/logs/prom/halu_reflection.prom"
python3 - "$REF" > "$OUT" <<'PY'
import json, time, sys, pathlib, datetime
ref = pathlib.Path(sys.argv[1])
now=time.time()
thr5 =now-300
thr60=now-3600
c5=c60=0
def ts_of(val):
  if isinstance(val,(int,float)): return float(val)
  if isinstance(val,str) and val:
    try: return datetime.datetime.fromisoformat(val.replace("Z","+00:00")).timestamp()
    except Exception: return None
  return None

if ref.exists():
  for line in ref.read_text(encoding="utf-8").splitlines():
    try:
      o=json.loads(line)
      ts_ing = ts_of(o.get("ingest_at"))  # 5分は ingest_at「だけ」で判定
      ts_evt = ts_of(o.get("t"))          # 1時間は出来事の時刻
      if ts_ing is not None and ts_ing >= thr5:  c5  += 1
      if ts_evt is not None and ts_evt >= thr60: c60 += 1
    except Exception:
      pass

print("# HELP daegis_halu_reflection_5m reflections ingested in last 5 minutes")
print("# TYPE daegis_halu_reflection_5m gauge")
print(f"daegis_halu_reflection_5m {c5}")
print("# HELP daegis_halu_reflection_1h reflections occurred in last 1 hour")
print("# TYPE daegis_halu_reflection_1h gauge")
print(f"daegis_halu_reflection_1h {c60}")
PY
echo "[OK] reflection metrics -> $OUT"
