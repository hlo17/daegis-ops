from pathlib import Path
from datetime import datetime, timezone
import uuid, json, os, time, types, inspect, sys

_ORCH_DIR = Path("/var/log/roundtable")
_ORCH_DIR.mkdir(parents=True, exist_ok=True)
_ORCH_FILE = _ORCH_DIR / "orchestrate.jsonl"

def _write_entry(entry):
    try:
        with _ORCH_FILE.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        print("[rt] _rt_monkey: JSONL appended", entry.get("corr_id"), entry.get("task"))
    except Exception as e:
        print("[rt] _rt_monkey: JSONL append ERROR:", e, file=sys.stderr)

def _extract_task(args, kwargs, resp):
    # 取り得る場所を総当り（kwargs, pydantic的args[0], dict, resp）
    cand = []
    cand.append(kwargs.get("task"))
    if args:
        a0 = args[0]
        cand.append(getattr(a0, "task", None))
        cand.append(a0.get("task") if isinstance(a0, dict) else None)
    if isinstance(resp, dict):
        cand.append(resp.get("task"))
        # body echo系で "input" や "text" に入ることも
        cand.append(resp.get("input"))
        cand.append(resp.get("text"))
    for v in cand:
        if isinstance(v, str) and v.strip():
            return v.strip()
    return None

def _extract_arbitrated(resp):
    if isinstance(resp, dict):
        return resp.get("arbitrated") or {}
    return {}

def install(module):
    """
    1) _orch_log があればそれを包む
    2) なければ orchestrate(FASTAPIハンドラ) を包む
    """
    # --- 1) _orch_log を包む
    orig_log = getattr(module, "_orch_log", None)
    if isinstance(orig_log, (types.FunctionType, types.MethodType)):
        def _wrap_log(task, votes, coordinator, arbitrated, source="orchestrate_patch", *args, **kwargs):
            print("[rt] _rt_monkey: wrapping _orch_log -> pass-through + append")
            try:
                orig_log(task, votes, coordinator, arbitrated, source=source)
            finally:
                a = arbitrated.dict() if hasattr(arbitrated, "dict") else arbitrated
                syn = ""
                if isinstance(a, dict):
                    syn = (a.get("synthesized_proposal") or "")
                entry = {
                    "ts": datetime.now(timezone.utc).isoformat(),
                    "corr_id": str(uuid.uuid4()),
                    "task": task,
                    "votes": votes,
                    "coordinator": coordinator,
                    "arbitrated": {"summary_len": len(str(syn).encode("utf-8"))},
                    "source": source,
                    "arb_backend": None,
                    "rt_agents": os.getenv("RT_AGENTS"),
                    "latency_ms": None,
                    "status": "ok",
                }
                _write_entry(entry)
        module._orch_log = _wrap_log
        print("[rt] _rt_monkey: installed (_orch_log wrapper)")
        return True

    # --- 2) orchestrate を包む（本命）
    orig_orch = getattr(module, "orchestrate", None)
    if not callable(orig_orch):
        print("[rt] _rt_monkey: orchestrate not found; skip")
        return False

    is_async = inspect.iscoroutinefunction(orig_orch)

    if is_async:
        async def _wrap_orch(*args, **kwargs):
            t0 = time.time()
            resp = await orig_orch(*args, **kwargs)
            try:
                task = _extract_task(args, kwargs, resp)
                arb = _extract_arbitrated(resp)
                syn = (arb.get("synthesized_proposal") or "")
                entry = {
                    "ts": datetime.now(timezone.utc).isoformat(),
                    "corr_id": str(uuid.uuid4()),
                    "task": task,
                    "votes": (resp.get("votes") if isinstance(resp, dict) else None),
                    "coordinator": (resp.get("coordinator") if isinstance(resp, dict) else None),
                    "arbitrated": {"summary_len": len(str(syn).encode("utf-8"))},
                    "source": "orchestrate_patch",
                    "arb_backend": None,
                    "rt_agents": os.getenv("RT_AGENTS"),
                    "latency_ms": int((time.time()-t0)*1000),
                    "status": "ok",
                }
                _write_entry(entry)
            except Exception as e:
                print("[rt] _rt_monkey: post-orchestrate append ERROR:", e, file=sys.stderr)
            return resp
        module.orchestrate = _wrap_orch
        print("[rt] _rt_monkey: installed (async orchestrate wrapper)")
        return True

    def _wrap_orch_sync(*args, **kwargs):
        t0 = time.time()
        resp = orig_orch(*args, **kwargs)
        try:
            task = _extract_task(args, kwargs, resp)
            arb = _extract_arbitrated(resp)
            syn = (arb.get("synthesized_proposal") or "")
            entry = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "corr_id": str(uuid.uuid4()),
                "task": task,
                "votes": (resp.get("votes") if isinstance(resp, dict) else None),
                "coordinator": (resp.get("coordinator") if isinstance(resp, dict) else None),
                "arbitrated": {"summary_len": len(str(syn).encode("utf-8"))},
                "source": "orchestrate_patch",
                "arb_backend": None,
                "rt_agents": os.getenv("RT_AGENTS"),
                "latency_ms": int((time.time()-t0)*1000),
                "status": "ok",
            }
            _write_entry(entry)
        except Exception as e:
            print("[rt] _rt_monkey: post-orchestrate append ERROR:", e, file=sys.stderr)
        return resp
    module.orchestrate = _wrap_orch_sync
    print("[rt] _rt_monkey: installed (sync orchestrate wrapper)")
    return True
