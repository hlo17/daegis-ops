#!/usr/bin/env python3
# Phase L7: SimBrain (dry-run proposer) · stdlib only · append-only
import os, json, sys
from datetime import datetime

DECISION = "logs/decision.jsonl"
OUT_LOG = "logs/simbrain_proposals.jsonl"

# policy knobs (env-tunable; safe defaults)
HOLD_TARGET_LO = float(os.getenv("SB_HOLD_TARGET_LO", "0.05"))  # tighten if far below
HOLD_TARGET_HI = float(os.getenv("SB_HOLD_TARGET_HI", "0.15"))  # widen if above
SLA_MIN = float(os.getenv("SB_SLA_MIN", "500"))
SLA_MAX = float(os.getenv("SB_SLA_MAX", "8000"))
UP_STEP = float(os.getenv("SB_UP_STEP", "0.10"))  # +10% when too many HOLDs
DOWN_STEP = float(os.getenv("SB_DOWN_STEP", "0.05"))  # -5%  when too few HOLDs
BASELINE = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))


def _f(x, d=None):
    try:
        return float(x)
    except Exception:
        return d


def load_recent(n=1000):
    if not os.path.isfile(DECISION):
        return []
    with open(DECISION, "r", encoding="utf-8", errors="ignore") as f:
        lines = [line for line in f.readlines()[-n:] if line.strip()]
    out = []
    for line in lines:
        try:
            j = json.loads(line)
            intent = (j.get("intent_hint") or j.get("intent") or "other").lower()
            sla = _f((j.get("tuning") or {}).get("sla_suggested_ms"), None)
            verdict = ((j.get("ethics") or {}).get("verdict") or "PASS").upper()
            out.append((intent, sla, verdict))
        except Exception:
            pass
    return out


def propose(items):
    # aggregate by intent
    agg = {}
    for it, sla, vd in items:
        g = agg.setdefault(it, {"sum": 0.0, "n": 0, "hold": 0, "tot": 0})
        if sla is not None:
            g["sum"] += sla
            g["n"] += 1
        if vd == "HOLD":
            g["hold"] += 1
        g["tot"] += 1
    if not agg:
        print("[SimBrain] no data")
        return 0
    os.makedirs("logs", exist_ok=True)
    ts = datetime.utcnow().isoformat(timespec="seconds") + "Z"
    with open(OUT_LOG, "a", encoding="utf-8") as w:
        for it, g in sorted(agg.items()):
            mean = (g["sum"] / g["n"]) if g["n"] > 0 else BASELINE
            hr = (g["hold"] / g["tot"]) if g["tot"] > 0 else 0.0
            if hr > HOLD_TARGET_HI:
                after = min(SLA_MAX, mean * (1.0 + UP_STEP))
                action = "WIDEN"
            elif hr < HOLD_TARGET_LO:
                after = max(SLA_MIN, mean * (1.0 - DOWN_STEP))
                action = "TIGHTEN"
            else:
                after = max(SLA_MIN, min(SLA_MAX, mean))
                action = "KEEP"
            rec = {
                "event": "simbrain_proposal",
                "t_run": ts,
                "intent": it,
                "hold_rate": round(hr, 4),
                "sla_before": round(mean, 2),
                "sla_after_proposed": round(after, 2),
                "action": action,
                "dry_run": True,
            }
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print(f"[SimBrain] proposals written → {OUT_LOG}")
    return 0


def main():
    return propose(load_recent())


if __name__ == "__main__":
    sys.exit(main())
