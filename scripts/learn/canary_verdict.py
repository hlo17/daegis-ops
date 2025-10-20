#!/usr/bin/env python3
# Phase L13: Canary Verdict (dry) — aggregate recent canary window and record a verdict
# stdlib only / append-only
import os, json, sys, time, pathlib

DECISION = "logs/decision.jsonl"
OUT = "logs/policy_canary_verdict.jsonl"
# knobs
WIN_SEC = int(float(os.getenv("L13_WINDOW_SEC", "1800")))  # 30min default
MAX_HOLD = float(os.getenv("L13_MAX_HOLD", "0.20"))  # hold <= 20%
MAX_5XX = int(os.getenv("L13_MAX_5XX", "0"))  # hard: no 5xx by default
MAX_P95_MS = float(os.getenv("L13_MAX_P95_MS", "3500"))  # rough latency guard
DEF_LAT = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))


def _f(x, d=None):
    try:
        return float(x)
    except Exception:
        return d


def load_recent(path, win_sec):
    # allow override / enriched source
    path = os.getenv("L13_DECISIONS_PATH", path)
    if os.path.isfile("logs/decision_enriched.jsonl") and not os.getenv("L13_DECISIONS_PATH"):
        path = "logs/decision_enriched.jsonl"
    now = time.time()
    rows = []
    p = pathlib.Path(path)
    if not p.exists():
        return rows
    with p.open("r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            try:
                o = json.loads(ln)
                ts = _f(o.get("ts"), None) or _f(o.get("time"), None) or None
                if ts is None:
                    # accept recent lines without ts (best-effort)
                    ts = now
                if now - ts <= win_sec:
                    rows.append(o)
            except Exception:
                pass
    return rows


def percentile(vals, p):
    if not vals:
        return None
    vals = sorted(vals)
    k = (len(vals) - 1) * p
    f = int(k)
    c = min(f + 1, len(vals) - 1)
    if f == c:
        return vals[f]
    return vals[f] + (vals[c] - vals[f]) * (k - f)


def _intent_list(env_name="AUTO_TUNE_CANARY_INTENTS"):
    raw = (os.getenv(env_name, "") or "").strip()
    if not raw:
        return []
    return [p.strip().lower() for p in raw.split(",") if p.strip()]


def _filter_by_intents(rows, intents):
    if not intents:
        return rows
    s = set(intents)
    return [r for r in rows if r.get("intent", "").lower() in s]


def main():
    rows = load_recent(DECISION, WIN_SEC)
    cl = _intent_list()
    rows = _filter_by_intents(rows, cl)
    if not rows:
        print("[L13] no recent decisions; verdict=INSUFFICIENT")
        rec = {
            "event": "canary_verdict",
            "ts": time.time(),
            "window_sec": WIN_SEC,
            "verdict": "INSUFFICIENT",
            "reason": "NO_DATA",
            "canary_intents": cl,
        }
        pathlib.Path("logs").mkdir(exist_ok=True)
        open(OUT, "a", encoding="utf-8").write(json.dumps(rec) + "\n")
        return 0
    holds = 0
    n = 0
    e5 = 0
    lats = []
    for o in rows:
        v = ((o.get("ethics") or {}).get("verdict") or "PASS").upper()
        if v == "HOLD":
            holds += 1
        st = int(o.get("status") or 200)
        if st >= 500:
            e5 += 1
        lat = _f(o.get("latency_ms"), None)
        if lat is not None:
            lats.append(lat)
        n += 1
    hr = (holds / n) if n else 0.0
    p95 = percentile(lats, 0.95) if lats else None
    verdict = "PASS"
    reason = []
    if hr > MAX_HOLD:
        verdict = "FAIL"
        reason.append(f"HOLD_RATE>{MAX_HOLD}")
    if e5 > MAX_5XX:
        verdict = "FAIL"
        reason.append(f"HTTP_5XX>{MAX_5XX}")
    if p95 is not None and p95 > MAX_P95_MS:
        verdict = "FAIL"
        reason.append(f"P95>{int(MAX_P95_MS)}ms")
    if not reason:
        reason.append("OK")
    rec = {
        "event": "canary_verdict",
        "ts": time.time(),
        "window_sec": WIN_SEC,
        "canary_intents": cl,
        "n": n,
        "hold_rate": round(hr, 4),
        "e5xx": e5,
        "p95_ms": (round(p95, 2) if p95 is not None else None),
        "verdict": verdict,
        "reason": ";".join(reason),
    }
    pathlib.Path("logs").mkdir(exist_ok=True)
    with open(OUT, "a", encoding="utf-8") as w:
        w.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print(f"[L13] verdict={verdict} hr={hr:.3f} e5xx={e5} p95={p95 if p95 is not None else 'na'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
