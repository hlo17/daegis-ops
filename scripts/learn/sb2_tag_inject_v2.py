#!/usr/bin/env python3
# SimBrain v2 tag injector (append-only / stdlib only)
# - Reads SB2-like proposals from:
#   logs/simbrain_proposals.jsonl   (mixed legacy + v2)
#   logs/simbrain_v2.jsonl          (optional)
# - Normalizes to auto_tune_candidate lines with confidence_tag
# - Appends to: logs/policy_auto_tune.jsonl

import os, sys, json
from datetime import datetime

SRC_FILES = [
    ("logs/simbrain_proposals.jsonl", ["simbrain_v2_proposal", "sb2_proposal", "simbrain_proposal"]),
    ("logs/simbrain_v2.jsonl", ["simbrain_v2_proposal", "sb2_proposal"]),
]
OUT = "logs/policy_auto_tune.jsonl"


def _float(x):
    try:
        return float(x)
    except Exception:
        return None


def _pick(d, keys):
    for k in keys:
        if k in d and d[k] not in (None, ""):
            return d[k]
    return None


def _is_v2(evt: str, src_hint: str):
    evt = (evt or "").lower()
    src = (src_hint or "").lower()
    if "v2" in evt or "sb2" in evt:
        return True
    if src in ("sb2", "simbrain_v2"):
        return True
    return False


def _norm_intent(s):
    s = (s or "").strip().lower()
    if not s:
        return "other"
    # common aliases
    if s in ("plan_create", "plan"):
        return "plan"
    return s


def iter_candidates():
    for path, ok_events in SRC_FILES:
        if not os.path.isfile(path):
            continue
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for ln in f:
                ln = ln.strip()
                if not ln:
                    continue
                try:
                    j = json.loads(ln)
                except Exception:
                    continue
                evt = (j.get("event") or "").lower()
                src = j.get("source") or ""
                if evt and evt not in [e.lower() for e in ok_events]:
                    # allow legacy "simbrain_proposal" if confidence fields exist
                    if not (
                        "simbrain_proposal" in evt
                        and ("confidence" in j or "confidence_tag" in j or "sb2" in (src or "").lower())
                    ):
                        continue
                intent = _norm_intent(j.get("intent") or j.get("intent_hint"))
                ms = _float(_pick(j, ["proposed_ms", "after_ms", "sla_after_proposed", "sla_ms"]))
                if ms is None:
                    # last fallback: tuning.sla_suggested_ms
                    t = j.get("tuning") or {}
                    ms = _float(t.get("sla_suggested_ms"))
                if ms is None:
                    continue
                conf = _pick(j, ["confidence_tag", "confidence"])
                if isinstance(conf, (int, float)):
                    conf = "low" if conf < 0.5 else ("mid" if conf < 0.8 else "high")
                conf = (conf or "low").strip().lower()
                v2 = _is_v2(evt, src)
                yield {
                    "event": "auto_tune_dry",
                    "candidate": True,
                    "t_run": datetime.utcnow().isoformat(timespec="seconds") + "Z",
                    "intent": intent,
                    "proposed_ms": round(ms, 2),
                    "sla_after": round(ms, 2),
                    "confidence_tag": conf,
                    "source": "simbrain_v2" if v2 else (src or "simbrain_v2"),
                }


def main():
    os.makedirs("logs", exist_ok=True)
    n = 0
    with open(OUT, "a", encoding="utf-8") as w:
        for rec in iter_candidates():
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
            n += 1
    print(f"[sb2-tag v2] injected {n} → {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())  # --- [append-only hotfix v2025-10-10] SB2 v2 normalized injector ---
import sys, time

ALLOW_INTENTS = set((os.getenv("SB2_ALLOW_INTENTS") or "plan,publish").split(","))
MIN_TAG = os.getenv("SB_MIN_CONF_TAG", "mid")  # low, mid, high
TAG_RANK = {"low": 0, "mid": 1, "high": 2}


def _tag_ok(t):
    return TAG_RANK.get(str(t).lower(), -1) >= TAG_RANK.get(MIN_TAG, 1)


def emit_auto_tune_candidate(ev):
    # ev: normalized {intent, confidence_tag, proposed_ms, source, reason}
    out = {
        "ts": time.time(),
        "event": "auto_tune_candidate",
        "intent": ev["intent"],
        "proposed_ms": ev.get("proposed_ms"),
        "confidence_tag": ev.get("confidence_tag", "low"),
        "source": ev.get("source", "simbrain_v2"),
        "reason": ev.get("reason", "(sb2)"),
    }
    with open("logs/policy_auto_tune.jsonl", "a") as f:
        f.write(json.dumps(out, ensure_ascii=False) + "\n")


def normalize_and_emit(line):
    try:
        obj = json.loads(line)
    except Exception:
        return
    # accept both "simbrain_v2_proposal" or "sb2_proposal"
    if not any(k in obj for k in ("simbrain_v2_proposal", "sb2_proposal")):
        return
    rec = obj.get("simbrain_v2_proposal") or obj.get("sb2_proposal") or {}
    intent = rec.get("intent")
    ctag = (rec.get("confidence_tag") or "low").lower()
    if not intent or intent not in ALLOW_INTENTS:
        return
    if not _tag_ok(ctag):
        return
    ev = {
        "intent": intent,
        "confidence_tag": ctag,
        "proposed_ms": rec.get("sla_after_proposed") or rec.get("proposed_ms"),
        "source": "simbrain_v2",
        "reason": rec.get("reason", ""),
    }
    emit_auto_tune_candidate(ev)


if __name__ == "__main__":
    # pass-through: read from stdin or recent proposals log
    path = "logs/simbrain_proposals.jsonl"
    try:
        with open(path) as fp:
            for line in fp:
                normalize_and_emit(line)
    except FileNotFoundError:
        for line in sys.stdin:
            normalize_and_emit(line)
# --- end hotfix ---
