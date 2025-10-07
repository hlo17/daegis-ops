import datetime as dt
import glob
import json
import pathlib

import matplotlib.pyplot as plt

rec = pathlib.Path.home() / "daegis/records"
rows = []
for f in sorted(glob.glob(str(rec / "kpi-*.jsonl"))):
    with open(f) as fh:
        for line in fh:
            try:
                o = json.loads(line)
                o["dt"] = dt.datetime.fromisoformat(o["ts"])
                rows.append(o)
            except Exception:
                pass
rows.sort(key=lambda x: x["dt"])
if not rows:
    print("no data")
    raise SystemExit(0)

t = [r["dt"] for r in rows]
imp = [r.get("improvement") for r in rows]
pv = [r.get("p_value") for r in rows]
ppl = [r.get("ppl") for r in rows]

fig = plt.figure(figsize=(8, 7))
ax1 = fig.add_subplot(311)
ax1.plot(t, imp, marker="o")
ax1.set_title("Improvement (Δ)")
ax2 = fig.add_subplot(312)
ax2.plot(t, pv, marker="o")
ax2.axhline(0.05, linestyle="--")
ax2.set_title("p-value (dashed=0.05)")
ax3 = fig.add_subplot(313)
ax3.plot(t, ppl, marker="o")
ax3.set_title("Train PPL")
for ax in (ax1, ax2, ax3):
    ax.grid(True, alpha=0.3)
    ax.tick_params(axis="x", rotation=20)
fig.tight_layout()
out = str(rec / "kpi.png")
plt.savefig(out, dpi=150)
print(out)
