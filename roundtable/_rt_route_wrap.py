import inspect, json, os, time, uuid
from datetime import datetime, timezone
from pathlib import Path

_LOG_FILE = Path("/var/log/roundtable") / "orchestrate.jsonl"

def _summary_len_from_result(res):
    try:
        if isinstance(res, dict):
            s = res.get("arbitrated", {})
            if isinstance(s, dict):
                return int(s.get("summary_len") or 0)
        if isinstance(res, (str, bytes)):
            return len(res)
    except Exception:
        pass
    return 0

def install(app):
    # unwrap if wrapped by ASGI middleware (has .app)
    core = getattr(app, "app", app)
    try:
        routes = [r for r in getattr(getattr(core, "router", None), "routes", [])
                  if getattr(r, "path", "") == "/orchestrate"]
        wrapped_any = False

        for r in routes:
            orig = getattr(r, "endpoint", None)
            if not orig or getattr(orig, "_rt_wrapped", False):
                continue

            async def wrapper(*args, __orig=orig, **kwargs):
                  t0 = time.time()
                  ok = True
                  err = None
                print("[rt] route_wrap: ENTER", flush=True)
                t0 = time.time()
                
                  try:
                      res = __orig(*args, **kwargs)
                  except Exception as e:
                      ok = False
                      err = str(e)
                      res = {"coordinator": None}
                if inspect.isawaitable(res):
                    res = await res
                latency_ms = int((time.time() - t0) * 1000)

                # task はレスポンス優先、無ければ "unknown"
                final_task = None
                if isinstance(res, dict):
                    v = res.get("task")
                    if isinstance(v, str) and v:
                        final_task = v
                if not final_task:
                    final_task = "unknown"

                entry = {
                    "ts": datetime.now(timezone.utc).isoformat(),
                    "corr_id": str(uuid.uuid4()),
                    "task": final_task,
                    "votes": None,
                    "coordinator": (res.get("coordinator") if isinstance(res, dict) else None),
                    "arbitrated": {"summary_len": _summary_len_from_result(res)},
                    "source": "route_wrap",
                    "arb_backend": None,
                    "rt_agents": os.getenv("RT_AGENTS"),
                    "latency_ms": latency_ms,
                    "status": ("ok" if ok else "error"),
                }
                try:
                    _LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
                    with _LOG_FILE.open("a", encoding="utf-8") as f:
                        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
                    print("[rt] route_wrap: JSONL appended", entry["corr_id"], entry["task"], flush=True)
                except Exception as e:
                    print("[rt] route_wrap: append failed:", e, "orig_err=", err, flush=True)

                print("[rt] route_wrap: EXIT", flush=True)
                return res

            setattr(wrapper, "_rt_wrapped", True)
            r.endpoint = wrapper
            wrapped_any = True

        print(f"[rt] route_wrap: installed on {len(routes)} route(s), wrapped={wrapped_any}")
        return wrapped_any
    except Exception as e:
        print("[rt] route_wrap: install error:", e)
        return False
