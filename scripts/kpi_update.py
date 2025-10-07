import csv
import json
import pathlib
import sys
import time

CSV = pathlib.Path("ops/kpi_log.csv")
CSV.parent.mkdir(parents=True, exist_ok=True)
row = json.loads(sys.argv[1])
row["ts"] = int(time.time())
header = ["ts", "task", "ttr_min", "keystrokes", "copilot_accepts", "copilot_total", "test_pass"]
with CSV.open("a", newline="") as f:
    w = csv.DictWriter(f, fieldnames=header)
    if CSV.stat().st_size == 0:
        w.writeheader()
    w.writerow({k: row.get(k) for k in header})
print(f"Wrote KPI to {CSV}")
