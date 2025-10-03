from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
import json, os

def _to_json_dict(body: bytes) -> dict:
    try:
        if not body:
            return {}
        return json.loads(body.decode("utf-8"))
    except Exception:
        return {}

def _normalize(d: dict) -> dict:
    d.setdefault("status", "ok")
    d.setdefault("rt_agents", os.getenv("RT_AGENTS", "Grok4,ChatGPT"))
    d.setdefault("votes", [])
    if isinstance(d.get("arbitrated"), dict):
        d["arbitrated"].setdefault(
            "synthesized_proposal",
            d.get("note") or d.get("message")
        )
    return d

class OrchestrateNormalizeMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        resp: Response = await call_next(request)
        # /orchestrate へのPOSTをゆるく検出（末尾スラッシュやクエリも許容）
        if request.method == "POST" and str(request.url.path).rstrip("/").endswith("/orchestrate"):
            try:
                # 応答ボディを吸い上げ（StreamingResponseにも対応）
                chunks = [chunk async for chunk in resp.body_iterator]
                raw = b"".join(chunks)
                data = _to_json_dict(raw)
                if data:   # JSONとして読めたら補完
                    return JSONResponse(_normalize(data))
                else:
                    # JSONでなければ、そのまま返す（可用性優先）
                    return resp
            except Exception:
                # 失敗しても元レスポンスを返す
                return resp
        return resp

def register(app):
    # 既存動作は一切変えず、最後に整形だけ足す
    app.add_middleware(OrchestrateNormalizeMiddleware)
    return app
