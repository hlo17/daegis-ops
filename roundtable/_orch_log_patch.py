from pathlib import Path
from datetime import datetime, timezone
import json, os, uuid, sys, traceback

_ORCH_FILE = Path("/var/log/roundtable/orchestrate.jsonl")

def _safe(obj):
    try:
        # Pydantic等なら dict() を試す
        if hasattr(obj, "dict"):
            return obj.dict()
        return obj
    except Exception:
        return str(obj)

def _orch_log(task, votes, coordinator, arbitrated,
              source="orchestrate_patch",
              arb_backend=None, rt_agents=None,
              latency_ms=None, status="ok"):
    try:
        print("[rt] JSONL about to write", {
            "task": task, "arb_backend": arb_backend,
            "latency_ms": latency_ms, "status": status
        })
    except Exception:
        pass

    syn = ""
    try:
        a = _safe(arbitrated)
        if isinstance(a, dict):
            syn = a.get("synthesized_proposal", "") or ""
    except Exception:
        syn = ""

    entry = {
        "ts": datetime.now(timezone.utc).isoformat(),
        "corr_id": str(uuid.uuid4()),
        "task": task,
        "votes": votes,
        "coordinator": coordinator,
        "arbitrated": {"summary_len": len(syn.encode("utf-8"))},
        "source": source,
        "arb_backend": arb_backend,
        "rt_agents": rt_agents,
        "latency_ms": latency_ms if isinstance(latency_ms, (int, float)) else None,
        "status": status,
    }

    try:
        _ORCH_FILE.parent.mkdir(parents=True, exist_ok=True)
        with _ORCH_FILE.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        print("[rt] orchestrate jsonl logged", entry["corr_id"], entry["task"])
    except Exception as e:
        print("[rt] JSONL WRITE ERROR:", str(e))
        traceback.print_exc(file=sys.stdout)
