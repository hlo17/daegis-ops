import asyncio, json, time
from fastapi import Header, Response, Request

CACHE_TTL_SEC = 60
REQUEST_TIMEOUT_SEC = 3.0

# 既存メトリクス（任意）
_use_existing = False
try:
    from metrics import rt_requests_total as _rtt, rt_latency_ms as _lat  # ある場合のみ利用
    _use_existing = True
except Exception:
    _rtt = _lat = None

# Prometheus があれば cache ヒット/ミスを Counter で
try:
    from prometheus_client import Counter
    rt_cache_hits_total   = Counter("rt_cache_hits_total", "router cache hits", ["route"])
    rt_cache_misses_total = Counter("rt_cache_misses_total", "router cache misses", ["route"])
except Exception:
    class _N:
        def labels(self,*a,**k): return self
        def inc(self,*a,**k): pass
    rt_cache_hits_total   = _N()
    rt_cache_misses_total = _N()

_CACHE = {}  # key -> (expire_ts, value)

def _cache_key(body):
    return json.dumps(body, sort_keys=True, separators=(",", ":"))

def _cache_get(k):
    t = _CACHE.get(k)
    if not t:
        return None
    exp, val = t
    if time.time() > exp:
        _CACHE.pop(k, None)
        return None
    return val

def _cache_set(k, val):
    _CACHE[k] = (time.time()+CACHE_TTL_SEC, val)

def install_chat_patch(app):
    """既存 /chat POST があれば置き換え、無ければ新規追加"""
    for r in list(app.router.routes):
        try:
            if getattr(r, "path", None) == "/chat" and "POST" in getattr(r, "methods", []):
                app.router.routes.remove(r)
        except Exception:
            pass

    @app.post("/chat")
    async def _chat(req: Request, response: Response, x_corr_id: str | None = Header(default=None, alias="X-Corr-ID")):
        route = "/chat"
        t0 = time.time()
        corr = x_corr_id or "unknown"
        body = await req.json()

        try:
            if _use_existing and _rtt is not None:
                try:
                    _rtt.labels(route=route).inc()
                except Exception:
                    pass

            k = _cache_key(body)
            cached = _cache_get(k)
            if cached is not None:
                try: rt_cache_hits_total.labels(route=route).inc()
                except Exception: pass
                response.headers["X-Cache"] = "HIT"
                response.headers["X-Corr-ID"] = corr
                out = dict(cached)
                out["correlation_id"] = corr
                return out

            try: rt_cache_misses_total.labels(route=route).inc()
            except Exception: pass
            response.headers["X-Cache"] = "MISS"

            async def _core():
                # 既存の本処理を呼び出すのが理想。無い場合はダミーで動作確認。
                delay = float(body.get("delay", 0) or 0)
                if delay > 0:
                    await asyncio.sleep(delay/1000.0 if delay > 10 else delay)
                return {"message": "ok", "ts": time.strftime("%FT%T")}

            try:
                result = await asyncio.wait_for(_core(), timeout=REQUEST_TIMEOUT_SEC)
            except asyncio.TimeoutError:
                return Response(
                    content=json.dumps({"error":"Request timeout after 3s","correlation_id":corr}),
                    media_type="application/json",
                    status_code=504,
                    headers={"X-Cache": "MISS", "X-Corr-ID": corr}
                )

            _cache_set(k, result)
            response.headers["X-Corr-ID"] = corr
            out = dict(result)
            out["correlation_id"] = corr
            return out

        finally:
            if _use_existing and _lat is not None and hasattr(_lat, "observe"):
                try:
                    _lat.labels(route=route).observe((time.time()-t0)*1000.0)
                except Exception:
                    pass
