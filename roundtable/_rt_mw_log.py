from datetime import datetime, timezone
from pathlib import Path
import json, uuid, os, time

_LOG = Path("/var/log/roundtable") / "orchestrate.jsonl"

class RTMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        is_http = scope.get("type") == "http"
        path    = scope.get("path")
        method  = scope.get("method", "").upper()
        hit = (is_http and str(path).startswith("/orchestrate") and method == "POST")

        t0 = time.time()
        ok = True
        err = None
        try:
            return await self.app(scope, receive, send)
        except Exception as e:
            ok = False
            err = str(e)
            raise
        finally:
            # 例外でもここは必ず実行される
            if hit:
                latency_ms = int((time.time() - t0) * 1000)
                entry = {
                    "ts": datetime.now(timezone.utc).isoformat(),
                    "corr_id": str(uuid.uuid4()),
                    "task": None,
                    "votes": None,
                    "coordinator": None,
                    "arbitrated": {"summary_len": 0},
                    "source": "mw_log",
                    "arb_backend": None,
                    "rt_agents": os.getenv("RT_AGENTS"),
                    "latency_ms": latency_ms,
                    "status": ("ok" if ok else "error"),
                }
                try:
                    _LOG.parent.mkdir(parents=True, exist_ok=True)
                    with _LOG.open("a", encoding="utf-8") as f:
                        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
                    print("[rt] mw_log: JSONL appended", entry["corr_id"], "status=", entry["status"], flush=True)
                except Exception as e2:
                    print("[rt] mw_log: append failed:", e2, "orig_err=", err, flush=True)
