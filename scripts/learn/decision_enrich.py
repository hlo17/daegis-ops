#!/usr/bin/env python3
# decision.jsonl → decision_enriched.jsonl（error_kind/route/latency を付与）
import os, sys, json

SRC = "logs/decision.jsonl"
OUT = "logs/decision_enriched.jsonl"


def kind(status):
    try:
        s = int(status)
    except Exception:
        return None
    if s >= 500:
        return "upstream_timeout" if s in (502, 504) else ("upstream_unavailable" if s == 503 else "http_5xx")
    return None


def main():
    if not os.path.isfile(SRC):
        print("[enrich] no input")
        return 0
    n = 0
    with open(SRC, "r", encoding="utf-8", errors="ignore") as f, open(OUT, "a", encoding="utf-8") as w:
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            try:
                j = json.loads(ln)
            except Exception:
                continue
            j.setdefault("error_kind", kind(j.get("status", 200)))
            j.setdefault("route", j.get("route") or j.get("path") or j.get("endpoint") or "/chat")
            if "latency_ms" not in j and (j.get("tuning") or {}).get("sla_suggested_ms"):
                try:
                    j["latency_ms"] = float(j["tuning"]["sla_suggested_ms"])
                except Exception:
                    pass
            w.write(json.dumps(j, ensure_ascii=False) + "\n")
            n += 1
    print(f"[enrich] wrote {n} → {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
