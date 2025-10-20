#!/usr/bin/env python3
# Phase XIX-A: Memory Curator (append-only, stdlib only)
import os, json, csv, sys
from datetime import datetime
from collections import defaultdict

LOGS = "logs"
SRC_FILES = [
    (os.path.join(LOGS, "decision.jsonl"), "decision"),
    (os.path.join(LOGS, "policy_dryrun.jsonl"), "policy"),
]
OUT_JSONL = os.path.join(LOGS, "memory_dataset.jsonl")
OUT_CSV = os.path.join(LOGS, "train_ready.csv")


def _get(d, *ks, default=None):
    for k in ks:
        cur = d
        for part in k if isinstance(k, (list, tuple)) else [k]:
            if isinstance(cur, dict) and part in cur:
                cur = cur[part]
            else:
                cur = None
                break
        if cur is not None:
            return cur
    return default


def read_events():
    evts = []
    for path, src in SRC_FILES:
        if not os.path.isfile(path):
            continue
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    j = json.loads(line)
                except Exception:
                    continue
                ts = _get(j, "event_time", "observed_time", "timestamp", "time", default=None)
                intent = (_get(j, "intent") or _get(j, "intent_hint") or "other").lower()
                eth = _get(j, "ethics") or {}
                verdict = (eth.get("verdict") or _get(j, "verdict") or "UNKNOWN").upper()
                sc = _get(j, "consensus_score", "score", default=None)
                reason = eth.get("hint") or _get(j, "reason", "message", "hint", default="")
                evts.append(
                    {"ts": ts, "intent": intent, "verdict": verdict, "score": sc, "reason": reason, "source": src}
                )
    return evts


def aggregate(evts):
    grp = defaultdict(
        lambda: {
            "total": 0,
            "PASS": 0,
            "HOLD": 0,
            "FAIL": 0,
            "OTHER": 0,
            "score_sum": 0.0,
            "score_n": 0,
            "by_source": defaultdict(int),
        }
    )
    for e in evts:
        it = e["intent"] or "other"
        v = e["verdict"]
        grp[it]["total"] += 1
        if v in ("PASS", "HOLD", "FAIL"):
            grp[it][v] += 1
        else:
            grp[it]["OTHER"] += 1
        sc = e["score"]
        if isinstance(sc, (int, float)):
            grp[it]["score_sum"] += float(sc)
            grp[it]["score_n"] += 1
        grp[it]["by_source"][e["source"]] += 1
    return grp


def append_jsonl(grp, t_run):
    with open(OUT_JSONL, "a", encoding="utf-8") as w:
        for intent, g in sorted(grp.items()):
            mean = (g["score_sum"] / g["score_n"]) if g["score_n"] else None
            out = {
                "t_run": t_run,
                "intent": intent,
                "total": g["total"],
                "pass": g["PASS"],
                "hold": g["HOLD"],
                "fail": g["FAIL"],
                "other": g["OTHER"],
                "score_mean": mean,
                "sources": dict(g["by_source"]),
            }
            w.write(json.dumps(out, ensure_ascii=False) + "\n")


def append_csv(evts, t_run):
    new = not os.path.isfile(OUT_CSV) or os.path.getsize(OUT_CSV) == 0
    with open(OUT_CSV, "a", encoding="utf-8", newline="") as w:
        wr = csv.writer(w)
        if new:
            wr.writerow(["t_run", "ts", "intent", "verdict", "score", "reason", "source"])
        for e in evts:
            wr.writerow(
                [
                    t_run,
                    e["ts"],
                    e["intent"],
                    e["verdict"],
                    e["score"] if e["score"] is not None else "",
                    e["reason"],
                    e["source"],
                ]
            )


def main():
    t_run = datetime.utcnow().isoformat(timespec="seconds") + "Z"
    evts = read_events()
    grp = aggregate(evts)
    append_jsonl(grp, t_run)
    append_csv(evts, t_run)
    print(f"[MemoryCurator] ok: intents={len(grp)} events={len(evts)} run={t_run}")


if __name__ == "__main__":
    sys.exit(main())
