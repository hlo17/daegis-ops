#!/usr/bin/env bash
# Summarize last 1h reflection → ledger + bus + prom
set -euo pipefail
ROOT="$HOME/daegis"
REF="$ROOT/logs/halu/reflection.jsonl"
LED="$ROOT/docs/ledger/halu.jsonl"
BUS="$ROOT/logs/halu/bus.jsonl"
PROM="$ROOT/logs/prom/halu_reflection_summary.prom"

python3 - "$REF" "$LED" "$BUS" "$PROM" <<'PY'
import sys, json, time, pathlib, datetime, collections

ref = pathlib.Path(sys.argv[1])
led = pathlib.Path(sys.argv[2]); led.parent.mkdir(parents=True, exist_ok=True)
bus = pathlib.Path(sys.argv[3]); bus.parent.mkdir(parents=True, exist_ok=True)
pro = pathlib.Path(sys.argv[4]); pro.parent.mkdir(parents=True, exist_ok=True)

def ts_of(val):
    if isinstance(val,(int,float)): return float(val)
    if isinstance(val,str) and val:
        try: return datetime.datetime.fromisoformat(val.replace("Z","+00:00")).timestamp()
        except Exception: return None
    return None

now   = time.time()
thr60 = now - 3600
rows  = []
if ref.exists():
    for line in ref.read_text(encoding="utf-8", errors="ignore").splitlines():
        try:
            o=json.loads(line)
        except Exception:
            continue
        t = ts_of(o.get("t"))
        if t is None or t < thr60: 
            continue
        rows.append(o)

total = len(rows)
by_src = collections.Counter(o.get("source","") for o in rows)
by_int = collections.Counter((o.get("intent") or "").strip() for o in rows if o.get("intent"))
top_int = [k for k,_ in by_int.most_common(3)]

iso_now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
# ledger（人間が読める一行）
led.write_text(led.read_text(encoding="utf-8") if led.exists() else "", encoding="utf-8")
with led.open("a", encoding="utf-8") as L:
    L.write(json.dumps({
        "t": iso_now, "act":"reflect.summarize", "window":"1h",
        "total": total, "by_source": by_src, "top_intents": top_int, "stage":"L2"
    }, ensure_ascii=False) + "\n")

# busにも軽く刻む
with bus.open("a", encoding="utf-8") as B:
    B.write(json.dumps({"ts": int(now), "agent":"halu","event":"reflect.summarize","total": total}, ensure_ascii=False) + "\n")

# prom（メトリクス2本）
pro.write_text(
    "daegis_halu_reflection_summary_total_1h {}\n"
    "daegis_halu_reflection_summary_last_ts {}\n".format(total, int(now)),
    encoding="utf-8"
)

print(f"[OK] summarize last1h: total={total}, by_source={dict(by_src)}, top_intents={top_int}")
PY
