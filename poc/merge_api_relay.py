import csv, glob, os, pathlib, re, json, datetime

ROOT = pathlib.Path.home() / "daegis" / "poc"
API_DIR = ROOT / "outputs" / "api"
RELAY_DIR = ROOT / "inputs"

def latest(path_glob):
    files = glob.glob(str(path_glob))
    return max(files, key=os.path.getmtime) if files else None

api_csv = latest(API_DIR / "summary_*.csv")
relay_csv = str(RELAY_DIR / "relay_summary.csv")

api = {}
if api_csv:
    with open(api_csv, newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        for row in r:
            i = row.get("id","").strip()
            if not i: 
                continue
            api[i] = {"model": row.get("model",""), "latency_ms": row.get("latency_ms","")}

relay = {}
with open(relay_csv, newline="", encoding="utf-8") as f:
    r = csv.DictReader(f)
    for row in r:
        i = row.get("id","").strip()
        if not i:
            continue
        relay[i] = {"model": row.get("model",""), "latency_ms": row.get("latency_ms","")}

ids = sorted(set(api) | set(relay), key=lambda x:(len(x), x))

rows = ["| ID | API model | API latency_ms | Relay model | Relay latency_ms |",
        "|---|---|---:|---|---:|"]
for i in ids:
    a = api.get(i, {})
    b = relay.get(i, {})
    rows.append(f"| {i} | {a.get('model','-')} | {a.get('latency_ms','-')} | {b.get('model','-')} | {b.get('latency_ms','-')} |")

out_md = ROOT / "outputs" / "comparison_rows.md"
out_md.parent.mkdir(parents=True, exist_ok=True)
out_md.write_text("\n".join(rows) + "\n", encoding="utf-8")

summary = {
    "generated_at": datetime.datetime.now().isoformat(),
    "api_csv": api_csv,
    "relay_csv": relay_csv,
    "n_ids": len(ids),
}
(ROOT / "outputs" / "comparison_meta.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
print(out_md)
