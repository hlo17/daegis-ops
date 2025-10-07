import csv
import pathlib
import statistics
import time

CSV = pathlib.Path("ops/kpi_log.csv")
now, week = int(time.time()), 7 * 24 * 3600
rows = []
if CSV.exists():
    with CSV.open() as f:
        for r in csv.DictReader(f):
            if int(r["ts"]) >= now - week:
                rows.append(r)


def avg(k):
    vals = [float(x[k]) for x in rows if x.get(k) not in ("", None)]
    return round(statistics.mean(vals), 2) if vals else 0.0


def rate(n, d):
    nsum = sum(float(x[n]) for x in rows)
    dsum = sum(float(x[d]) or 1 for x in rows) or 1
    return round(100 * nsum / dsum, 1)


print("=== KPI Weekly Summary ===")
print(f"TTR_min(avg): {avg('ttr_min')}")
print(f"Keystrokes(avg): {avg('keystrokes')}")
print(f"Copilot accept rate: {rate('copilot_accepts', 'copilot_total')}%")
print(f"Samples: {len(rows)}")
