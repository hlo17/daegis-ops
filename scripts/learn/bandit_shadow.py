#!/usr/bin/env python3
# Phase L8: Shadow Bandit (dry-run; stdlib only)
import os, json, sys, time
from collections import defaultdict

DEC = "logs/decision.jsonl"
OUT = "logs/bandit_shadow.jsonl"
DELTA_A = float(os.getenv("BANDIT_DELTA_A", "0.95"))  # -5%
DELTA_B = float(os.getenv("BANDIT_DELTA_B", "1.05"))  # +5%
WINDOW = int(os.getenv("BANDIT_WINDOW", "400"))
BASE_DEF = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000") or 3000)


def tail_decisions(path, n):
    if not os.path.isfile(path):
        return []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        lines = [line for line in f.readlines()[-n:] if line.strip()]
    out = []
    for line in lines:
        try:
            j = json.loads(line)
            it = (j.get("intent_hint") or j.get("intent") or "other").lower()
            lat = float(j.get("latency_ms") or 0.0)
            base = float(((j.get("tuning") or {}).get("sla_suggested_ms")) or BASE_DEF)
            out.append((it, lat, base))
        except Exception:
            pass
    return out


def main():
    rows = tail_decisions(DEC, WINDOW)
    if not rows:
        print("[Bandit] no data")
        return 0
    stats = defaultdict(lambda: {"A": {"w": 0, "n": 0, "d": DELTA_A}, "B": {"w": 0, "n": 0, "d": DELTA_B}})
    for it, lat, base in rows:
        for arm in ("A", "B"):
            d = stats[it][arm]["d"]
            thr = base * d
            win = (lat <= thr) and (thr > 0)
            s = stats[it][arm]
            s["n"] += 1
            s["w"] += 1 if win else 0
    ts = time.time()
    os.makedirs("logs", exist_ok=True)
    with open(OUT, "a", encoding="utf-8") as w:
        for it in sorted(stats.keys()):
            A = stats[it]["A"]
            B = stats[it]["B"]
            rec = {
                "event": "bandit_shadow",
                "ts": ts,
                "intent": it,
                "A_delta": A["d"],
                "A_win_rate": round((A["w"] / A["n"]) if A["n"] else 0.0, 4),
                "A_n": A["n"],
                "B_delta": B["d"],
                "B_win_rate": round((B["w"] / B["n"]) if B["n"] else 0.0, 4),
                "B_n": B["n"],
            }
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print("[Bandit] wrote shadow metrics →", OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
