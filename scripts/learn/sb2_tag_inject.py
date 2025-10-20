#!/usr/bin/env python3
# Append-only: inject SimBrain v2 proposals into policy_auto_tune.jsonl
# - tolerant to both simbrain_proposals.jsonl (event="simbrain_v2_proposal"/"sb2_proposal")
#   and simbrain_v2.jsonl (event="sb2_proposal")
import os, sys, json
from datetime import datetime

IN_FILES = [
    "logs/simbrain_proposals.jsonl",
    "logs/simbrain_v2.jsonl",
]
OUT = "logs/policy_auto_tune.jsonl"


def nowZ():
    return datetime.utcnow().isoformat(timespec="seconds") + "Z"


def iter_lines(paths):
    for p in paths:
        if not os.path.isfile(p):
            continue
        with open(p, "r", encoding="utf-8", errors="ignore") as f:
            for ln in f:
                ln = ln.strip()
                if ln:
                    yield ln


def main():
    os.makedirs("logs", exist_ok=True)
    n = 0
    with open(OUT, "a", encoding="utf-8") as w:
        for ln in iter_lines(IN_FILES):
            try:
                j = json.loads(ln)
            except Exception:
                continue
            ev = (j.get("event") or "").lower()
            if ev not in ("simbrain_v2_proposal", "sb2_proposal"):
                continue
            it = (j.get("intent") or "other").lower()
            conf = (j.get("confidence_tag") or j.get("confidence") or "low").lower()
            after = j.get("after_ms") or j.get("sla_after_proposed")
            try:
                after = float(after)
            except Exception:
                continue
            rec = {
                "event": "auto_tune_dry",
                "candidate": True,
                "t_run": nowZ(),
                "intent": it,
                "proposed_ms": round(after, 2),
                "sla_after": round(after, 2),
                "source": "simbrain_v2",
                "confidence_tag": conf,
            }
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
            n += 1
    print(f"[sb2-tag] injected {n} → {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
