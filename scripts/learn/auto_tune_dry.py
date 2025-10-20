#!/usr/bin/env python3
# Phase L9: Auto-Tune (dry) — select SimBrain proposals; no apply
import os, json, sys
from datetime import datetime

SRC = "logs/simbrain_proposals.jsonl"
OUT = "logs/policy_auto_tune.jsonl"
MIN_DELTA = float(os.getenv("AT_MIN_DELTA", "0.03"))
MAX_DELTA = float(os.getenv("AT_MAX_DELTA", "0.25"))
ALLOW = set((os.getenv("AT_ALLOW", "TIGHTEN,KEEP,WIDEN")).split(","))


def tail_proposals(n=500):
    if not os.path.isfile(SRC):
        return []
    out = []
    with open(SRC, "r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            try:
                out.append(json.loads(ln))
            except Exception:
                pass
    return out[-n:]


def main():
    rows = tail_proposals()
    if not rows:
        print("[AutoTune] no proposals")
        return 0
    os.makedirs("logs", exist_ok=True)
    t = datetime.utcnow().isoformat(timespec="seconds") + "Z"
    n = 0
    with open(OUT, "a", encoding="utf-8") as w:
        for r in rows:
            it = (r.get("intent") or "other").lower()
            act = (r.get("action") or "").upper()
            before = float(r.get("sla_before") or 0)
            after = float(r.get("sla_after_proposed") or 0)
            if before <= 0 or after <= 0:
                continue
            delta = abs(after - before) / before if before > 0 else 0.0
            ok = (act in ALLOW) and (MIN_DELTA <= delta <= MAX_DELTA)
            w.write(
                json.dumps(
                    {
                        "event": "auto_tune_dry",
                        "t_run": t,
                        "intent": it,
                        "action": act,
                        "sla_before": round(before, 2),
                        "sla_after": round(after, 2),
                        "delta": round(delta, 4),
                        "candidate": bool(ok),
                    },
                    separators=(",", ":"),
                )
                + "\n"
            )
            n += 1
    print(f"[AutoTune] candidates → {OUT} (n={n})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
