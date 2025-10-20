#!/usr/bin/env python3
# Phase L10.5: Auto-Adopt (append-only; safe; no router changes)
# - If VETO flag exists → skip
# - Enforce cooldown and max daily delta
# - Append chosen exports to env_local.sh
# - Write audit row to policy_apply_controlled.jsonl
import os, sys, re, json, time, pathlib

# --- allowlist: 昇格対象 intent を限定（例: "plan,publish"）---
_ALLOW = [s.strip().lower() for s in (os.getenv("AUTO_TUNE_ALLOW_INTENTS", "") or "").split(",") if s.strip()]


def _allowed(it: str) -> bool:
    return (not _ALLOW) or (it.lower() in _ALLOW)


# --- cooldown marker（待ち明け自動実行のための手掛かり）---
_FLAG_DIR = pathlib.Path("flags")
_FLAG_DIR.mkdir(parents=True, exist_ok=True)
_COOL_FLAG = _FLAG_DIR / "L105_COOLDOWN_UNTIL"


def _write_cooldown_until(seconds_from_now: float, intents):
    until_ts = time.time() + max(0.0, seconds_from_now)
    rec = {"event": "l105_cooldown_until", "until_ts": until_ts, "intents": sorted(set(intents))}
    with open(_COOL_FLAG, "w", encoding="utf-8") as w:
        w.write(json.dumps(rec))
    return until_ts


CAND_FILE = os.getenv("L10_CAND_FILE", "scripts/dev/env_candidates.sh")
ENV_FILE = os.getenv("L5_ENV_FILE", "scripts/dev/env_local.sh")
LOG_FILE = os.getenv("L10_AUDIT_FILE", "logs/policy_apply_controlled.jsonl")
VETO_FLAG = "flags/L5_VETO"

MAX_DELTA = float(os.getenv("L52_MAX_DAILY_DELTA_PCT", "10")) / 100.0  # e.g. 0.10
COOLDOWN_H = int(os.getenv("L52_COOLDOWN_HOURS", "2"))
BASELINE = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000") or 3000)

EXPORT_RE = re.compile(r"^\s*export\s+(DAEGIS_SLA_[A-Z0-9_]+_MS)\s*=\s*([0-9]+)\s*$")


def now_ts():
    return time.time()


def read_exports(path):
    d = {}
    if not os.path.isfile(path):
        return d
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            m = EXPORT_RE.match(ln.strip())
            if m:
                k, v = m.group(1), int(m.group(2))
                d[k] = v
    return d


def last_autoadopt_ts():
    p = pathlib.Path(LOG_FILE)
    if not p.exists():
        return 0.0
    last = 0.0
    with p.open("r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            try:
                j = json.loads(ln)
                if j.get("event") == "auto_adopt" and float(j.get("ts", 0)) > last:
                    last = float(j.get("ts", 0))
            except Exception:
                pass
    return last


def append_env(k, v):
    pathlib.Path(pathlib.Path(ENV_FILE).parent).mkdir(parents=True, exist_ok=True)
    with open(ENV_FILE, "a", encoding="utf-8") as f:
        f.write(f"export {k}={int(v)}\n")


def audit(rec):
    pathlib.Path("logs").mkdir(exist_ok=True)
    with open(LOG_FILE, "a", encoding="utf-8") as w:
        w.write(json.dumps(rec, separators=(",", ":")) + "\n")


def main():
    # VETO guard
    if os.path.exists(VETO_FLAG):
        audit({"event": "auto_adopt_skip", "ts": now_ts(), "reason": "VETO_PRESENT"})
        print("[L10.5] skip: VETO present")
        return 0
    # cooldown guard
    last_ts = last_autoadopt_ts()
    if last_ts and (now_ts() - last_ts) < COOLDOWN_H * 3600:
        audit({"event": "auto_adopt_skip", "ts": now_ts(), "reason": "COOLDOWN"})
        print("[L10.5] skip: cooldown")
        return 0

    cand = read_exports(CAND_FILE)
    if not cand:
        audit({"event": "auto_adopt_skip", "ts": now_ts(), "reason": "NO_CANDIDATE"})
        print("[L10.5] no candidates")
        return 0

    cur = read_exports(ENV_FILE)
    adopted = 0
    considered_intents = []
    for k, after in sorted(cand.items()):
        # Extract intent from key (assuming format like DAEGIS_SLA_PLAN_MS)
        parts = k.split("_")
        intent = parts[2].lower() if len(parts) > 2 else "other"

        if not _allowed(intent):
            continue  # allowlist で除外

        before = cur.get(k, int(BASELINE))
        if before <= 0 or after <= 0:
            audit({"event": "auto_adopt_skip", "ts": now_ts(), "key": k, "reason": "NONPOSITIVE"})
            continue
        delta = (after - before) / before
        if abs(delta) > MAX_DELTA:
            audit(
                {
                    "event": "auto_adopt_skip",
                    "ts": now_ts(),
                    "key": k,
                    "before": before,
                    "after": after,
                    "delta_pct": round(delta, 4),
                    "reason": "DELTA_EXCEEDS_LIMIT",
                }
            )
            continue

        # Check cooldown
        last_ts = last_autoadopt_ts()
        if last_ts and (now_ts() - last_ts) < COOLDOWN_H * 3600:
            considered_intents.append(intent)
            rem = COOLDOWN_H * 3600 - (now_ts() - last_ts)
            until = _write_cooldown_until(rem, considered_intents)
            audit({"event": "auto_adopt_skip", "ts": now_ts(), "key": k, "reason": "COOLDOWN", "cooldown_until": until})
            continue

        # adopt (append-only)
        append_env(k, after)
        audit(
            {
                "event": "auto_adopt",
                "ts": now_ts(),
                "key": k,
                "before": before,
                "after": after,
                "delta_pct": round(delta, 4),
                "cooldown_h": COOLDOWN_H,
                "max_delta_pct": MAX_DELTA,
            }
        )
        adopted += 1

    print(
        f"[L10.5] adopted={adopted} (limit={int(MAX_DELTA * 100)}% / cooldown={os.getenv('L52_COOLDOWN_HOURS', '2')}h)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
