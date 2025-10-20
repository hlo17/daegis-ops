from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
import json, os


def _to_json_dict(raw: bytes) -> dict:
    try:
        if not raw:
            return {}
        return json.loads(raw.decode("utf-8"))
    except Exception:
        return {}


def _coalesce(val, default):
    return default if val in (None, "", [], {}) else val


def _normalize(d: dict) -> dict:
    # 既定値の埋め込み（null / 空を既定値に）
    d["status"] = _coalesce(d.get("status"), "ok")
    d["rt_agents"] = _coalesce(d.get("rt_agents") or d.get("agents"), os.getenv("RT_AGENTS", "Grok4,ChatGPT"))
    d["votes"] = d.get("votes") or []

    # arbitrated を必ず dict にして synthesized_proposal を必ず用意
    if not isinstance(d.get("arbitrated"), dict):
        d["arbitrated"] = {}
    synth = d["arbitrated"].get("synthesized_proposal")
    d["arbitrated"]["synthesized_proposal"] = _coalesce(
        synth,
        d.get("note") or d.get("message") or d.get("task") or "synth: (none)",  # それも無ければ空文字
    )
    return d


class OrchestrateNormalizeMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        resp: Response = await call_next(request)
        # /orchestrate POST の応答だけゆるく整形
        if request.method == "POST" and str(request.url.path).rstrip("/").endswith("/orchestrate"):
            try:
                chunks = [chunk async for chunk in resp.body_iterator]
                raw = b"".join(chunks)
                data = _to_json_dict(raw)
                if data:
                    return JSONResponse(_normalize(data))
            except Exception:
                pass  # 失敗しても元レスポンス優先
            return resp
        return resp


def register(app):
    app.add_middleware(OrchestrateNormalizeMiddleware)
    return app
