# DAEGIS ROUTER · FASTAPI
# GOAL: /chat は最小差分で改良。Prometheusメトリクス必須。
# RULES:
# - cache: 60s TTL (user+contentキー)
# - timeout: 3.0s（外部IO） TimeoutError→HTTP 504
# - metrics: rt_requests_total / rt_latency_ms / rt_cache_{hits,misses}_total
# - tests: pytest名は <機能>_<期待> (例: cache_hit_is_faster)

# ---- paste-guard (header/footer) -------------------------------------------
_PG_HEADER = "# DAEGIS ROUTER · FASTAPI"
_PG_FOOTER = "# [PASTE-GUARD EOF v1] 5c6da0d0"

def _paste_guard():
    import sys, pathlib
    p = pathlib.Path(__file__)
    s = p.read_text(encoding="utf-8", errors="strict")
    errs = []
    if not s.splitlines()[0].startswith(_PG_HEADER):
        errs.append("header missing (first line broken)")
    if _PG_FOOTER not in s:
        errs.append("footer missing (EOF truncated or extra junk)")
    if "cat > router/app.py <<'PY'" in s:
        errs.append("heredoc marker leaked into file (shell pasted incorrectly)")
    if errs:
        sys.stderr.write("[paste-guard] file appears corrupted:\n - " + "\n - ".join(errs) + "\n")
        sys.exit(2)
# ---------------------------------------------------------------------------

import time, hashlib, asyncio
from typing import Dict, Tuple
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

# --- add: Daegis decision logging (stdlib only) ---
import json, os
from datetime import datetime
from uuid import uuid4

try:
    with open(os.path.join("ops", "policy", "compass.json"), "r") as _f:
        _DAEGIS_COMPASS = json.load(_f)
except Exception:
    _DAEGIS_COMPASS = {"weights": {"quality": 0.4, "latency": 0.3, "cost": 0.2, "safety": 0.1}}

# --- add: decision log toggle ---
LOG_DECISION = os.getenv("LOG_DECISION", "1") == "1"

def _daegis_corr_id(headers):
    # 既存の相関IDヘッダがあれば尊重。なければ生成。
    for k in ("X-Corr-ID", "X-Correlation-ID", "X-Request-ID"):
        v = headers.get(k)
        if v:
            return v
    return f"cid-{uuid4().hex[:12]}"

def _daegis_episode_id(corr_id: str) -> str:
    return f"{datetime.utcnow().strftime('%Y%m%d')}-{corr_id}"
# --- end add ---

app = FastAPI(title="DAEGIS Router")

# ---- very small in-memory cache --------------------------------------------
_TTL = 60.0
_Cache: Dict[str, Tuple[float, dict]] = {}
_CacheHits = 0
_CacheMisses = 0

def _cache_key(user: str, content: str) -> str:
    return hashlib.sha256(f"{user}::{content}".encode()).hexdigest()

def _get_cached(k: str):
    global _CacheHits, _CacheMisses
    now = time.time()
    v = _Cache.get(k)
    if v and now - v[0] <= _TTL:
        _CacheHits += 1
        return v[1]
    _CacheMisses += 1
    return None

def _set_cached(k: str, payload: dict):
    _Cache[k] = (time.time(), payload)

class ChatIn(BaseModel):
    user: str
    content: str

@app.post("/chat")
async def chat(body: ChatIn):
    _paste_guard()
    k = _cache_key(body.user, body.content)
    cached = _get_cached(k)
    if cached:
        return {"cached": True, **cached}

    try:
        async def _work():
            await asyncio.sleep(0.05)
            return {"reply": f"echo: {body.content}"}
        res = await asyncio.wait_for(_work(), timeout=3.0)
    except asyncio.TimeoutError:
        raise HTTPException(status_code=504, detail="upstream timeout")
    payload = {"cached": False, **res}
    _set_cached(k, payload)
    return payload

# [PASTE-GUARD EOF v1] 5c6da0d0

# --- add: prometheus histogram + /metrics + ASGI timing middleware ---
try:
    from prometheus_client import Histogram, generate_latest, CONTENT_TYPE_LATEST
    from fastapi import Response
    from fastapi.responses import PlainTextResponse
    _PROM_OK = True
except Exception:
    from fastapi.responses import PlainTextResponse
    _PROM_OK = False

if _PROM_OK:
    rt_latency_ms = Histogram(
        "rt_latency_ms",
        "Request latency in milliseconds",
        ["route"],
    )

    @app.middleware("http")
    async def _rt_latency_mw(request, call_next):
        import time
        start = time.perf_counter()
        try:
            response = await call_next(request)
            return response
        finally:
            dur_ms = (time.perf_counter() - start) * 1000.0
            route = getattr(request.scope.get("route"), "path", request.url.path)
            rt_latency_ms.labels(route=route).observe(dur_ms)

    @app.get("/metrics")
    async def _metrics():
        return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
else:
    @app.get("/metrics")
    async def _metrics_unavailable():
        return PlainTextResponse("# prometheus_client not installed\n", status_code=500)
# --- end add ---

# --- chat cache/timeout patch ---
from router.chat_cache_timeout import install_chat_patch
install_chat_patch(app)

# --- add: Daegis episode & decision logging middleware ---
@app.middleware("http")
async def _daegis_episode_mw(request, call_next):
    # /chat POST のみ対象（末尾スラッシュも吸収）
    path = request.url.path.rstrip("/")
    if path == "/chat" and request.method == "POST":
        corr_id = (
            request.headers.get("X-Corr-ID")
            or request.headers.get("X-Correlation-ID")
            or f"cid-{uuid4().hex[:12]}"
        )
        episode_id = _daegis_episode_id(corr_id)

        response = await call_next(request)
        response.headers["X-Episode-ID"] = episode_id

        # 意思決定ログを stdout へ
        if LOG_DECISION:
            print(json.dumps({
                "event": "decision",
                "episode": episode_id,
                "corr_id": corr_id,
                "intent": "chat_answer",
                "compass_snapshot": _DAEGIS_COMPASS,
                "ts_decision": time.time(),
            }), flush=True)

        return response

    return await call_next(request)
# --- end add ---

# --- add: Safety fallback mode header ---
from pathlib import Path

@app.middleware("http")
async def _safety_mode_header(request, call_next):
    response = await call_next(request)
    
    if request.url.path.rstrip("/") == "/chat" and request.method == "POST":
        if Path("ops/policy/mode.safe").exists():
            response.headers["X-Mode"] = "SAFE"
    
    return response
# --- end add ---
