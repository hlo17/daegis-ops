#!/usr/bin/env python3
# Phase L10: Apply Planner - 信頼度ゲート付き
import os, json, sys, time
from datetime import datetime

# --- Append-only: confidence gate for SimBrain proposals ---
# 最低採用タグ（low|mid|high）。既定=mid（安全側）
SB_MIN_CONF_TAG = os.getenv("SB_MIN_CONF_TAG", "mid").lower()
_RANK = {"low": 0, "mid": 1, "high": 2}


def _append_plan_log(rec: dict, path="logs/policy_apply_plan.jsonl"):
    try:
        rec = dict(rec)
        rec.setdefault("t_run", time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
        with open(path, "a", encoding="utf-8") as w:
            w.write(json.dumps(rec, ensure_ascii=False) + "\n")
    except Exception:
        pass


SRC = "logs/policy_auto_tune.jsonl"
OUT = "logs/policy_apply_plan.jsonl"
ENV_OUT = os.getenv("L10_ENV_CANDIDATES", "scripts/dev/env_candidates.sh")
PREFIX = "DAEGIS_SLA_"


def load_candidates(n=200):
    if not os.path.isfile(SRC):
        return []
    out = []
    with open(SRC, "r", encoding="utf-8", errors="ignore") as f:
        for ln in f:
            try:
                j = json.loads(ln)
                if j.get("event") == "auto_tune_dry" and j.get("candidate") is True:
                    out.append(j)
            except Exception:
                pass
    return out[-n:]


def env_key(intent: str) -> str:
    return f"{PREFIX}{intent.upper().replace('-', '_')}_MS"


def main():
    cands = load_candidates()
    if not cands:
        print("[Planner] no candidates")
        return 0
    os.makedirs("logs", exist_ok=True)
    os.makedirs(os.path.dirname(ENV_OUT) or ".", exist_ok=True)
    t = datetime.utcnow().isoformat(timespec="seconds") + "Z"
    wrote = 0
    with open(OUT, "a", encoding="utf-8") as w, open(ENV_OUT, "a", encoding="utf-8") as e:
        for c in cands:
            # ❶ v2 由来を判定（confidence_tag がある or source が SB2）
            tag_raw = c.get("confidence_tag", None)
            src_raw = str(c.get("source", "")).lower()
            is_v2 = (tag_raw is not None) or (src_raw in ("sb2", "simbrain_v2"))

            # ② v2 のみ confidence gate を適用。従来(タグ無し)は通す
            if is_v2:
                tag = str(tag_raw or "low").lower()
                if _RANK.get(tag, 0) < _RANK.get(SB_MIN_CONF_TAG, 1):
                    _append_plan_log(
                        {
                            "event": "apply_plan_skip",
                            "intent": c.get("intent"),
                            "proposed_ms": c.get("proposed_ms"),
                            "confidence_tag": tag_raw,
                            "reason": "CONFIDENCE_BELOW_MIN",
                            "min_tag": SB_MIN_CONF_TAG,
                        }
                    )
                    continue

            it = (c.get("intent") or "other").lower()
            after = float(c.get("sla_after") or 0)
            if after <= 0:
                continue
            plan = {"event": "apply_plan", "t_run": t, "intent": it, "proposed_ms": round(after, 2), "source": "L10"}
            w.write(json.dumps(plan, ensure_ascii=False) + "\n")
            e.write(f"export {env_key(it)}={int(round(after))}\n")
            _append_plan_log(
                {
                    "event": "apply_plan",
                    "intent": it,
                    "proposed_ms": round(after, 2),
                    "source": ("sb2" if is_v2 else c.get("source", "L10")),
                    "confidence_tag": (tag_raw if is_v2 else None),
                }
            )
            wrote += 1
    print(f"[Planner] wrote plan={wrote} → {OUT} and env candidates → {ENV_OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
