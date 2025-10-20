#!/usr/bin/env bash
# Ingest logs/decision_enriched.jsonl → logs/halu/reflection.jsonl
# - 増分（ウォーターマーク .ingest.pos）
# - 取り込み時刻 ingest_at を付与
# - 壊れた時刻はスキップ（メトリクス暴騰を防止）
set -euo pipefail
ROOT="$HOME/daegis"
SRC="${1:-$ROOT/logs/decision_enriched.jsonl}"
REF="$ROOT/logs/halu/reflection.jsonl"
POS="$ROOT/logs/halu/.ingest.pos"
mkdir -p "$ROOT/logs/halu"

python3 - "$SRC" "$REF" "$POS" <<'PY'
import sys, json, datetime, pathlib
src = pathlib.Path(sys.argv[1]); ref = pathlib.Path(sys.argv[2]); posf = pathlib.Path(sys.argv[3])
if not src.exists():
    print(f"[ERR] source not found: {src}", file=sys.stderr); sys.exit(2)

def to_iso(ts):
    if isinstance(ts,(int,float)):
        return datetime.datetime.utcfromtimestamp(ts).strftime("%Y-%m-%dT%H:%M:%SZ")
    if isinstance(ts,str) and ts:
        try:
            return (datetime.datetime.fromisoformat(ts.replace("Z","+00:00"))
                    .astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
        except Exception:
            return ""   # ← 解釈できない時刻は捨てる
    return ""

size = src.stat().st_size
pos  = int((posf.read_text().strip() or "0")) if posf.exists() else 0
if pos > size: pos = 0  # rotation

n=0
now_iso = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
with src.open("r", encoding="utf-8", errors="ignore") as f, ref.open("a", encoding="utf-8") as out:
    f.seek(pos)
    for line in f:
        s=line.strip()
        if not s: continue
        try:
            o=json.loads(s)
        except Exception:
            continue

        # ソースの時刻を優先的に解決（全部ダメならスキップ）
        iso = (to_iso(o.get("decision_time"))
               or to_iso(o.get("event_time"))
               or to_iso(o.get("observed_time"))
               or to_iso(o.get("t")))
        if not iso:
            continue

        actor  = (o.get("actor") or "").lower()
        source = "lyra" if "lyra" in actor else ("copilot" if "copilot" in actor else "eval")
        intent = o.get("intent_hint") or o.get("intent") or ""
        note   = (o.get("note") or "")[:160]

        rec = {"t": iso, "act":"eval-reflect", "source": source,
               "intent": intent, "note": note, "ingest_at": now_iso}
        out.write(json.dumps(rec, ensure_ascii=False) + "\n")
        n+=1
    pos_new = f.tell()

posf.write_text(str(pos_new))
print(f"[OK] ingested {n} lines (pos {pos}->{pos_new}) into reflection")
PY

# 取り込み後はメトリクスを再計算（冪等）
bash "$ROOT/scripts/ops/halu_reflection_metrics.sh" >/dev/null 2>&1 || true
