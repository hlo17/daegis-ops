#!/usr/bin/env python3
# Phase L12: Canary Apply (dry) — plan-only, no real apply
import os, sys, time, json, pathlib

CAND = "scripts/dev/env_candidates.sh"
OUT = "logs/policy_canary_apply.jsonl"
ENV_OUT = "scripts/dev/env_canary.sh"

RATIO = float(os.getenv("CANARY_RATIO", "0.05"))  # 5%
MAX_PER_RUN = int(os.getenv("CANARY_MAX_KEYS", "4"))


def load_candidates(path=CAND):
    if not os.path.isfile(path):
        return []
    out = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            ln = ln.strip()
            if not ln or ln.startswith("#"):
                continue
            if (
                ln.startswith("export ")
                and "_SLA_" in ln
                and ln.endswith(("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"))
            ):
                try:
                    kv = ln.split(None, 1)[1]
                    k, v = kv.split("=", 1)
                    v = int(v)
                    out.append((k.strip(), v))
                except Exception:
                    pass
    return out


def main():
    cand = load_candidates()
    if not cand:
        print("[L12] no candidates")
        return 0
    os.makedirs("logs", exist_ok=True)
    pathlib.Path(os.path.dirname(ENV_OUT) or ".").mkdir(parents=True, exist_ok=True)
    picked = cand[:MAX_PER_RUN]
    ts = time.time()
    with open(OUT, "a", encoding="utf-8") as w:
        for k, v in picked:
            rec = {"event": "canary_apply_plan", "ts": ts, "key": k, "proposed_ms": v, "ratio": RATIO, "dry_run": True}
            w.write(json.dumps(rec, separators=(",", ":")) + "\n")
    with open(ENV_OUT, "a", encoding="utf-8") as e:
        for k, v in picked:
            e.write(f"# canary {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(ts))} ratio={RATIO}\n")
            e.write(f"export {k}={v}\n")
    print(f"[L12] canary plan n={len(picked)} → {OUT} and {ENV_OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
