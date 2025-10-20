#!/usr/bin/env python3
# SimBrain v2 (bootstrap, append-only, stdlib only)
# - Input : logs/decision_enriched.jsonl (あれば) / なければ logs/decision.jsonl
# - Output: logs/simbrain_proposals.jsonl に v2提案を追記（event=simbrain_v2_proposal）
# - 目的  : intentごとの直近ウィンドウで hold率/5xx を評価し、±5%の微調整提案＋confidence_tag＋reason を付与

import os, json, time, math, collections, statistics

WIN_SEC = int(os.getenv("SB2_WINDOW_SEC", os.getenv("L13_WINDOW_SEC", "300")) or 300)
SLA_MIN = float(os.getenv("SB2_SLA_MIN", "400"))
SLA_MAX = float(os.getenv("SB2_SLA_MAX", "5000"))
STEP_PCT = float(os.getenv("SB2_STEP_PCT", "0.05"))  # ±5%
HOLD_LO = float(os.getenv("SB2_HOLD_TARGET_LO", "0.05"))
HOLD_HI = float(os.getenv("SB2_HOLD_TARGET_HI", "0.15"))
CANARY = [s.strip().lower() for s in (os.getenv("AUTO_TUNE_CANARY_INTENTS", "")).split(",") if s.strip()]

SRC_ENR = "logs/decision_enriched.jsonl"
SRC_RAW = "logs/decision.jsonl"
OUT_LOG = "logs/simbrain_proposals.jsonl"


def _now():
    return time.time()


def _records():
    path = SRC_ENR if os.path.isfile(SRC_ENR) else SRC_RAW
    t0 = _now() - WIN_SEC
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for ln in f:
                ln = ln.strip()
                if not ln:
                    continue
                try:
                    j = json.loads(ln)
                except Exception:
                    continue
                ts = float(j.get("ts") or j.get("time") or 0)
                if not ts or ts < t0:
                    continue
                it = (j.get("intent_hint") or j.get("intent") or "other").lower()
                if CANARY and it not in CANARY:
                    continue
                st = int(j.get("status") or 200)
                vd = (j.get("ethics", {}) or {}).get("verdict") or j.get("verdict") or "PASS"
                lat = j.get("latency_ms")
                try:
                    lat = float(lat) if lat is not None else None
                except Exception:
                    lat = None
                yield {"ts": ts, "intent": it, "status": st, "verdict": str(vd).upper(), "latency_ms": lat}
    except FileNotFoundError:
        return


def _conf_tag(n_eff, hold_rate, hold_mid):
    # データ密度＋ズレ量でタグ化
    delta = abs(hold_rate - hold_mid)
    if n_eff >= 200 and delta >= 0.05:
        return "high"
    if n_eff >= 80 and delta >= 0.03:
        return "mid"
    return "low"


def _sla_baseline(intent):
    # 既存ENVをヒントに（無ければ 2850 を中庸値に）
    key = f"DAEGIS_SLA_{intent.upper()}_MS"
    try:
        return float(os.getenv(key, "2850"))
    except Exception:
        return 2850.0


def main():
    by = collections.defaultdict(lambda: {"n": 0, "hold": 0, "e5xx": 0, "lat": []})
    for r in _records():
        it = r["intent"]
        by[it]["n"] += 1
        if r["verdict"] == "HOLD":
            by[it]["hold"] += 1
        if r["status"] >= 500:
            by[it]["e5xx"] += 1
        if isinstance(r["latency_ms"], (int, float)):
            by[it]["lat"].append(float(r["latency_ms"]))

    if not by:
        print("[SB2] no recent data; nothing to propose")
        return 0

    os.makedirs("logs", exist_ok=True)
    t_run = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    with open(OUT_LOG, "a", encoding="utf-8") as w:
        for it, s in sorted(by.items()):
            n = s["n"]
            hold_rate = (s["hold"] / n) if n else 0.0
            p95 = None
            if s["lat"]:
                xs = sorted(s["lat"])
                k = max(0, min(len(xs) - 1, int(math.ceil(0.95 * len(xs)) - 1)))
                p95 = xs[k]
            mean_lat = statistics.fmean(s["lat"]) if s["lat"] else _sla_baseline(it)
            hold_mid = (HOLD_LO + HOLD_HI) / 2.0
            tag = _conf_tag(n, hold_rate, hold_mid)
            before = max(SLA_MIN, min(SLA_MAX, mean_lat))
            # ルール：HOLDが高ければ+5%、低すぎれば-5%、レンジ内ならKEEP
            if hold_rate > HOLD_HI:
                after = min(SLA_MAX, before * (1.0 + STEP_PCT))
                action = "WIDEN"
                reason = f"hold={hold_rate:.3f}>{HOLD_HI:.2f} → widen"
            elif hold_rate < HOLD_LO:
                after = max(SLA_MIN, before * (1.0 - STEP_PCT))
                action = "TIGHTEN"
                reason = f"hold={hold_rate:.3f}<{HOLD_LO:.2f} → tighten"
            else:
                after = before
                action = "KEEP"
                reason = f"hold in [{HOLD_LO:.2f},{HOLD_HI:.2f}] → keep"
            reward_est = max(0.0, 1.0 - hold_rate) - (1.0 if s["e5xx"] > 0 else 0.0) * 0.5
            rec = {
                "event": "simbrain_v2_proposal",
                "t_run": t_run,
                "intent": it,
                "hold_rate": round(hold_rate, 4),
                "e5xx": int(s["e5xx"]),
                "p95_ms": round(p95, 2) if p95 is not None else None,
                "sla_before": round(before, 2),
                "sla_after_proposed": round(after, 2),
                "action": action,
                "confidence_tag": tag,
                "n_eff": n,
                "reward_est": round(reward_est, 4),
                "reason": reason,
                "dry_run": True,
            }
            # 既存L9/L10が読むファイルに追記（互換運用）
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
    print(f"[SB2] proposals appended → {OUT_LOG}")
    return 0


if __name__ == "__main__":
    import sys

    sys.exit(main())
