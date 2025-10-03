from datetime import datetime, timezone
from pathlib import Path
import json, uuid

_LOG = Path("/var/log/roundtable") / "orchestrate.jsonl"

class RTap:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope.get("type") == "http" and scope.get("path") == "/orchestrate":
            entry = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "corr_id": str(uuid.uuid4()),
                "task": None,
                "votes": None,
                "coordinator": None,
                "arbitrated": {"summary_len": 0},
                "source": "asgi_tap",
                "arb_backend": None,
                "rt_agents": None,
                "latency_ms": None,
                "status": "tap",
            }
            try:
                _LOG.parent.mkdir(parents=True, exist_ok=True)
                with _LOG.open("a", encoding="utf-8") as f:
                    f.write(json.dumps(entry, ensure_ascii=False) + "\n")
            except Exception:
                pass
        return await self.app(scope, receive, send)
