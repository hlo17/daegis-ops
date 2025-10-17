from router._guards import ensure_chat_locals, init_metrics_once
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

import time, hashlib, asyncio, logging
import time as _time
from typing import Dict, Tuple, Optional
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from starlette.responses import JSONResponse
from pydantic import BaseModel
import json, os, sys
from json import JSONDecodeError
import time as _asgi_time, json as _asgi_json

# --- Phase XV hotfix: ensure JSONResponse is available for /consensus error path ---
try:
    from fastapi.responses import JSONResponse  # used by _daegis_consensus_snapshot
except Exception:
    from starlette.responses import JSONResponse  # fallback to avoid NameError

# --- add: Unified logger for Phase V ---
logger = logging.getLogger("router")
if not logger.handlers:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

# --- add: Daegis decision logging (stdlib only) ---
import socket
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


# --- [append-only] ASGI tap: log /chat responses >=500 (v2025-10-10) ---
@app.middleware("http")
async def _tap_chat_5xx(request: Request, call_next):
    t0 = _time.time()
    try:
        response = await call_next(request)
    except Exception as e:
        # ASGI層で例外→500相当として記録
        latency_ms = int((_time.time() - t0) * 1000)
        try:
            with open("logs/decision_enriched.jsonl", "a") as f:
                f.write(
                    json.dumps(
                        {
                            "ts": _time.time(),
                            "route": str(getattr(request.url, "path", "")) or "/chat",
                            "status": 500,
                            "error": repr(e),
                            "latency_ms": latency_ms,
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        raise
    # 正常経路：/chat かつ 5xx を捕捉
    try:
        if request.url.path.rstrip("/") == "/chat" and int(getattr(response, "status_code", 0)) >= 500:
            latency_ms = int((_time.time() - t0) * 1000)
            with open("logs/decision_enriched.jsonl", "a") as f:
                f.write(
                    json.dumps(
                        {
                            "ts": _time.time(),
                            "route": "/chat",
                            "status": int(response.status_code),
                            "error": None,
                            "latency_ms": latency_ms,
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
    except Exception:
        pass
    return response


# --- [append-only] global ASGI tap for 5xx classification (v2025-10-10) ---
@app.middleware("http")
async def _daegis_asgi_tap(request: Request, call_next):
    _t0 = _asgi_time.time()
    try:
        resp = await call_next(request)
    except Exception as _e:
        # ensure unhandled → 500 is observed
        try:
            with open("logs/decision_enriched.jsonl", "a") as _f:
                _f.write(
                    _asgi_json.dumps(
                        {
                            "ts": _asgi_time.time(),
                            "route": getattr(request.url, "path", "NA"),
                            "status": 500,
                            "err_kind": "unhandled",
                            "err_msg": str(_e)[:500],
                            "latency_ms": int((_asgi_time.time() - _t0) * 1000),
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        raise
    try:
        if getattr(resp, "status_code", 200) >= 500:
            with open("logs/decision_enriched.jsonl", "a") as _f:
                _f.write(
                    _asgi_json.dumps(
                        {
                            "ts": _asgi_time.time(),
                            "route": getattr(request.url, "path", "NA"),
                            "status": int(getattr(resp, "status_code", 0)),
                            "err_kind": "asgi_5xx",
                            "latency_ms": int((_asgi_time.time() - _t0) * 1000),
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
    except Exception:
        pass
    return resp


# --- [append-only] 400 正規化: リクエスト不備は 5xx に計上しない (v2025-10-10) ---
@app.exception_handler(RequestValidationError)
async def _daegis_handle_req_validation(request: Request, exc: RequestValidationError):
    try:
        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _asgi_json.dumps(
                    {
                        "ts": _asgi_time.time(),
                        "route": getattr(request.url, "path", "NA"),
                        "status": 400,
                        "err_kind": "request_validation",
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "chat_guard",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass
    return JSONResponse({"detail": "bad request"}, status_code=400)


@app.exception_handler(JSONDecodeError)
async def _daegis_handle_json_decode(request: Request, exc: JSONDecodeError):
    try:
        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _asgi_json.dumps(
                    {
                        "ts": _asgi_time.time(),
                        "route": getattr(request.url, "path", "NA"),
                        "status": 400,
                        "err_kind": "json_decode_error",
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "chat_guard",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass
    return JSONResponse({"detail": "bad request"}, status_code=400)


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
async def chat_route(request: Request):
    # 既存ロジック…（この中で早期に 503/500 を返す分岐がある想定）
    # --- [append-only] guard for fast-fail classification (v2025-10-10) ---
    t0 = _time.time()
    try:
        # ↓↓↓ ここから下は既存処理（既存の return/raise は変更しない） ↓↓↓
        # --- [append-only] fast-fail 503 temporary bypass (v2025-10-10) ---
        # 環境変数 CHAT_FASTFAIL_BYPASS=1 の場合、/chat の「即時 503」を抑制し、下流へフォールスルーさせる。
        # 既存の分岐コード側で 503 を raise/return する直前に下記ヘルパを噛ませる想定。
        def _bypass_fastfail_503() -> bool:
            return os.getenv("CHAT_FASTFAIL_BYPASS", "0") == "1"

        # Parse request body first
        body_json = await request.json()
        body = ChatIn(**body_json)

        # 例：以下のような早期 503 分岐の直前に if _bypass_fastfail_503(): pass を差し込む
        # （Copilot が各所に安全にインライン化するためのガイドコメント）
        #   if queue_full:           # ← fast-fail 条件
        #       if _bypass_fastfail_503():
        #           pass  # フォールスルー
        #       else:
        #           raise HTTPException(status_code=503, detail="queue full")
        #   if circuit_open:
        #       if _bypass_fastfail_503():
        #           pass
        #       else:
        #           raise HTTPException(status_code=503, detail="circuit open")
        #   if rate_limited:
        #       if _bypass_fastfail_503():
        #           pass
        #       else:
        #           raise HTTPException(status_code=503, detail="rate limited")

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
    except (RequestValidationError, JSONDecodeError) as e:
        # 明確にリクエスト不備 → 400 へ正規化（e5xx に数えない）
        try:
            with open("logs/decision_enriched.jsonl", "a") as f:
                f.write(
                    json.dumps(
                        {
                            "ts": _time.time(),
                            "route": "/chat",
                            "status": 400,
                            "err_kind": "request_validation",
                            "err_msg": str(e)[:500],
                            "latency_ms": int((_time.time() - t0) * 1000),
                            "tap": "chat_guard",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        return JSONResponse({"detail": "bad request"}, status_code=400)
    except TimeoutError as e:
        # 上流タイムアウトは 503（可用性ドメイン）
        try:
            with open("logs/decision_enriched.jsonl", "a") as f:
                f.write(
                    json.dumps(
                        {
                            "ts": _time.time(),
                            "route": "/chat",
                            "status": 503,
                            "err_kind": "upstream_timeout",
                            "err_msg": str(e)[:500],
                            "latency_ms": int((_time.time() - t0) * 1000),
                            "tap": "chat_guard",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        raise HTTPException(status_code=503, detail="upstream timeout")
    except Exception as e:
        # 不明な 500 は従来どおり（ただし理由をログへ）
        try:
            with open("logs/decision_enriched.jsonl", "a") as f:
                f.write(
                    json.dumps(
                        {
                            "ts": _time.time(),
                            "route": "/chat",
                            "status": 500,
                            "err_kind": "unhandled",
                            "err_msg": str(e)[:500],
                            "latency_ms": int((_time.time() - t0) * 1000),
                            "tap": "chat_guard",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        raise


# [PASTE-GUARD EOF v1] 5c6da0d0
#
# --- [append-only] ASGI 5xx tap + 400 正規化（EOF追記） v2025-10-10 ---
try:
    from fastapi import Request
    from fastapi.responses import JSONResponse  # FastAPI でも Starlette 同等
except Exception:  # 最低限の後方互換
    Request = None
try:
    from fastapi.exceptions import RequestValidationError
except Exception:
    RequestValidationError = None
try:
    from json import JSONDecodeError
except Exception:
    JSONDecodeError = None
import json as _dg_json, time as _dg_time


# グローバル ASGI ミドルウェア（5xx を決定木で分類して decision_enriched.jsonl に記録）
@app.middleware("http")
async def _daegis_asgi_tap(request, call_next):
    _t0 = _dg_time.time()
    try:
        resp = await call_next(request)
    except Exception as _e:
        try:
            with open("logs/decision_enriched.jsonl", "a") as _f:
                _f.write(
                    _dg_json.dumps(
                        {
                            "ts": _dg_time.time(),
                            "route": getattr(getattr(request, "url", None), "path", "NA"),
                            "status": 500,
                            "err_kind": "unhandled",
                            "err_msg": str(_e)[:500],
                            "latency_ms": int((_dg_time.time() - _t0) * 1000),
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        except Exception:
            pass
        raise
    try:
        _sc = int(getattr(resp, "status_code", 0))
        if _sc >= 500:
            with open("logs/decision_enriched.jsonl", "a") as _f:
                _f.write(
                    _dg_json.dumps(
                        {
                            "ts": _dg_time.time(),
                            "route": getattr(getattr(request, "url", None), "path", "NA"),
                            "status": _sc,
                            "err_kind": "asgi_5xx",
                            "latency_ms": int((_dg_time.time() - _t0) * 1000),
                            "tap": "asgi_mw",
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
    except Exception:
        pass
    return resp


# リクエスト不備は 400 に正規化（e5xx に数えない）
def _dg_write_bad_request(req, kind, exc):
    try:
        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _dg_json.dumps(
                    {
                        "ts": _dg_time.time(),
                        "route": getattr(getattr(req, "url", None), "path", "NA"),
                        "status": 400,
                        "err_kind": kind,
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "chat_guard",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass


if RequestValidationError is not None:

    async def _dg_handle_req_validation(request, exc):
        _dg_write_bad_request(request, "request_validation", exc)
        return JSONResponse({"detail": "bad request"}, status_code=400)

    try:
        app.add_exception_handler(RequestValidationError, _dg_handle_req_validation)
    except Exception:
        pass

if JSONDecodeError is not None:

    async def _dg_handle_json_decode(request, exc):
        _dg_write_bad_request(request, "json_decode_error", exc)
        return JSONResponse({"detail": "bad request"}, status_code=400)

    try:
        app.add_exception_handler(JSONDecodeError, _dg_handle_json_decode)
    except Exception:
        pass


# --- [append-only] 400 正規化: KeyError/TypeError など実装依存の早期例外を Bad Request として扱う (v2025-10-10) ---
@app.exception_handler(KeyError)
async def _daegis_handle_key_error(request: Request, exc: KeyError):
    try:
        import time as _t, json as _j

        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _j.dumps(
                    {
                        "ts": _t.time(),
                        "route": getattr(getattr(request, "url", None), "path", "NA"),
                        "status": 400,
                        "err_kind": "request_key_error",
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "chat_guard",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass
    from starlette.responses import JSONResponse as _JR

    return _JR({"detail": "bad request"}, status_code=400)


@app.exception_handler(TypeError)
async def _daegis_handle_type_error(request: Request, exc: TypeError):
    try:
        import time as _t, json as _j

        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _j.dumps(
                    {
                        "ts": _t.time(),
                        "route": getattr(getattr(request, "url", None), "path", "NA"),
                        "status": 400,
                        "err_kind": "request_type_error",
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "chat_guard",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass
    from starlette.responses import JSONResponse as _JR

    return _JR({"detail": "bad request"}, status_code=400)


# --- [append-only] 最後の砦: 全例外キャッチで確実に記録 (v2025-10-10) ---
# 既存ハンドラに届かない 500 を asgi_mw と同形式で記録する保険
async def _dg_handle_any_exception(request, exc):
    try:
        import time as _t, json as _j

        with open("logs/decision_enriched.jsonl", "a") as _f:
            _f.write(
                _j.dumps(
                    {
                        "ts": _t.time(),
                        "route": getattr(getattr(request, "url", None), "path", "NA"),
                        "status": 500,
                        "err_kind": "unhandled_global",
                        "err_msg": str(exc)[:500],
                        "latency_ms": 0,
                        "tap": "asgi_mw",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    except Exception:
        pass
    # 既存の FastAPI 既定（500）を維持
    try:
        from fastapi.responses import JSONResponse as _JR

        return _JR({"detail": "internal error"}, status_code=500)
    except Exception:
        from starlette.responses import JSONResponse as _JR2

        return _JR2({"detail": "internal error"}, status_code=500)


try:
    app.add_exception_handler(Exception, _dg_handle_any_exception)
except Exception:
    pass

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
    pass  # Hot-probe metrics endpoint defined later


@app.get("/metrics")
async def metrics():
    # Try to enable at call-time
    if not _PROM_ACTIVE and _try_enable_prom():
        logger.info("[PhaseV] 🔁 /metrics triggered runtime activation")
        _ensure_metrics_safe(
            [i.strip() for i in os.getenv("DAEGIS_INTENTS", "chat_answer").split(",") if i.strip()] + ["other"]
        )

    if _PROM_ACTIVE:
        try:
            return PlainTextResponse(generate_latest(REGISTRY), media_type=CONTENT_TYPE_LATEST)
        except Exception as e:
            logger.warning(f"[PhaseV] metrics export error: {e}")
            return PlainTextResponse("Prometheus active but export failed", status_code=500)
    # dormant
    return PlainTextResponse("Prometheus dormant")


# --- end add ---

# --- chat cache/timeout patch ---
from router.chat_cache_timeout import install_chat_patch

install_chat_patch(app)


# --- add: Daegis episode & decision logging middleware ---
def _infer_intent_from_path_and_body(path: str, body_json: Optional[dict]) -> str:
    p = (path or "/").lower()
    if p.startswith("/plan"):
        return "plan"
    if p.startswith("/publish"):
        return "publish"
    # /chat はボディの intent を尊重
    if p.startswith("/chat"):
        it = None
        try:
            it = (body_json or {}).get("intent")
        except Exception:
            pass
        if isinstance(it, str) and it:
            return it.lower()
    return "other"


@app.middleware("http")
async def _daegis_episode_mw(request, call_next):
    # /chat POST のみ対象（末尾スラッシュも吸収）
    path = request.url.path.rstrip("/")
    if path == "/chat" and request.method == "POST":
        # guard -> helper call
        _os,_json,_time = ensure_chat_locals()
        os, json, time = _os, _json, _time
    # Guard: ensure module aliases exist in function locals to avoid UnboundLocalError
    try:
        _os
    except NameError:
        import os as _os
    try:
        _json
    except NameError:
        import json as _json
    try:
        _time
    except NameError:
        import time as _time

        os = __import__("os")
        json = __import__("json")
        time = __import__("time")
        try:
            _time
        except NameError:
            import time as _time
        t0_wall = _time.time() 
        try:
            t0_ns = time.monotonic_ns()
        except UnboundLocalError:
            import time as _time
            t0_ns = getattr(_time, "monotonic_ns", lambda: 0)()
        except Exception:
            try:
                import logging
                logging.getLogger("daegis").warning("t0_ns fallback triggered in _daegis_episode_mw")
            except Exception:
                pass
            t0_ns = 0

        corr_id = (
            request.headers.get("X-Corr-ID") or request.headers.get("X-Correlation-ID") or f"cid-{uuid4().hex[:12]}"
        )
        episode_id = _daegis_episode_id(corr_id)

        # --- intent hint を先に推定（append-only） ---
        ledger_entry = {}
        try:
            body_json = await request.json()
        except Exception:
            body_json = None
        ledger_entry["intent_hint"] = _infer_intent_from_path_and_body(str(request.url.path), body_json)

        response = JSONResponse({"ok": True})  # placeholder
        status = 200
        try:
            # === existing request handling ===
            response = await call_next(request)
            status = getattr(response, "status_code", 200)
        except Exception as e:
            status = 500
            try:
                # 上流起因が分かる語を混ぜてエラーメッセージ化（enrich 用）
                err_msg = f"{type(e).__name__}: {str(e)}"
                if "Timeout" in err_msg or "timed out" in err_msg:
                    err_msg = "upstream_timeout: " + err_msg
                if "Connection" in err_msg or "reset by peer" in err_msg:
                    err_msg = "upstream_failure: " + err_msg
                logger.exception(err_msg)
                ledger_entry["error_message"] = err_msg
            except Exception:
                pass
            response = JSONResponse({"error": "internal"}, status_code=500)
        finally:
            # === annotate ledger (append-only) ===
            try:
                lat_ms = (time.monotonic_ns() - t0_ns) / 1_000_000.0
                ledger_entry["latency_ms"] = float(lat_ms)
                ledger_entry["ts"] = float(t0_wall)
            except Exception:
                pass
            try:
                intent_hint = ledger_entry.get("intent_hint") or ledger_entry.get("intent") or "other"
                ledger_entry["intent_hint"] = intent_hint
            except Exception:
                intent_hint = "other"
            try:
                ledger_entry["status"] = int(status)
            except Exception:
                pass

        try:

            latency_ms = (time.monotonic_ns() - t0_ns) / 1_000_000.0

        except UnboundLocalError:

            import time as _time

            latency_ms = (getattr(_time, "monotonic_ns", lambda: 0)() - t0_ns) / 1_000_000.0

        except Exception:

            try:

                import logging

                logging.getLogger("daegis").warning("latency_ms fallback triggered in _daegis_episode_mw")

            except Exception:

                pass

            latency_ms = 0.0

        response.headers["X-Episode-ID"] = episode_id

        # --- add: intent breadcrumb (header + ledger) ---
        intent_hint = request.headers.get("X-Intent", "chat_answer")
        response.headers["X-Intent"] = intent_hint
        # --- end add ---

        # 意思決定ログを stdout へ
        if LOG_DECISION:
            print(
                json.dumps(
                    {
                        "event": "decision",
                        "episode": episode_id,
                        "corr_id": corr_id,
                        "intent": "chat_answer",
                        "compass_snapshot": _DAEGIS_COMPASS,
                        "ts_decision": time.time(),
                    }
                ),
                flush=True,
            )

        # --- add: decision ledger (enriched) ---
        ledger_path = "logs/decision.jsonl"
        os.makedirs("logs", exist_ok=True)

        # Get provenance data
        import subprocess, socket

        try:
            git_sha = subprocess.check_output(
                ["git", "rev-parse", "--short", "HEAD"], stderr=subprocess.DEVNULL, text=True
            ).strip()
        except Exception:
            git_sha = ""

        ledger_entry = {
            "episode_id": episode_id,
            "corr_id": corr_id,
            "decision_time": time.time(),
            "compass_version": "",
            "event_time": datetime.utcnow().isoformat() + "Z",
            "observed_time": datetime.utcnow().isoformat() + "Z",
            "intent_hint": intent_hint,
            "provenance": {"app_version": git_sha, "host": socket.gethostname(), "task": "ReviewGate"},
        }

        # Add ethics field with defaults
        ledger_entry["ethics"] = getattr(request.state, "ethics", {"verdict": "PASS", "rule_id": "none", "hint": ""})

        # Generate hash without hash field
        ledger_for_hash = ledger_entry.copy()
        ledger_hash = hashlib.sha256(json.dumps(ledger_for_hash, sort_keys=True).encode()).hexdigest()
        ledger_entry["hash"] = ledger_hash

        # Wire-up Phase V internal brain for HALU path
        try:
            phasev_update("plan_create", int(getattr(response, "status_code", 200)), float(latency_ms), ledger_entry)
            # Override provider for HALU path
            ledger_entry["provider"] = {"name": "halu-internal", "model": "auto"}
        except Exception as _e:
            logger.warning(f"[PhaseV] call skipped: {_e}")

        # --- L2+ tuner (append-only, primary brain only) ---
        try:
            _ = _phasev_tuner_once("plan_create", float(latency_ms), ledger_entry)
        except Exception as _te:
            logger.warning(f"[PhaseV] tuner skipped: {_te}")
        # (moved) Governor emit is done later (just before ledger write)

        # Wire-up Phase V internal brain for SCRIBE path
        try:
            phasev_update(
                "tool_call", int(getattr(response, "status_code", 200)), float(latency_ms or 0.0), ledger_entry
            )
        except Exception as _e:
            logger.warning(f"[PhaseV] SCRIBE call skipped: {_e}")

        # Set SCRIBE provider if not already set (but don't override HALU)
        if ledger_entry.get("provider", {}).get("name") != "halu-internal":
            ledger_entry["provider"] = {"name": "scribe-internal", "model": "auto"}

        # --- Phase VII V0.3: Local consensus update (BEFORE consensus.jsonl) ---
        _local_score = None
        try:
            _intent = ledger_entry.get("intent_hint") or "other"
            _status = int(getattr(response, "status_code", 200))
            _ethv = (ledger_entry.get("ethics") or {}).get("verdict", "PASS")
            _outcome = "support" if (_status < 500 and _ethv == "PASS") else "objection"
            _local_score = _local_cons_update(_intent, _outcome)
            # expose into ledger
            if _local_score is not None:
                ledger_entry["consensus_score"] = float(_local_score)
        except Exception as _e:
            logger.warning(f"[PhaseVII] local consensus update skipped: {_e}")

        # --- Phase VIII.1: consensus score gauge (safe/noop) ---
        try:
            g = globals()
            if g.get("_g_cons_score") is None:

                class _NoOpMetric:
                    def labels(self, *a, **k):
                        return self

                    def set(self, *a, **k):
                        return self

                _g_cons_score = _NoOpMetric()
                g["_g_cons_score"] = _g_cons_score
            if _PROM_ACTIVE:
                from prometheus_client import Gauge

                _g_cons_score = Gauge("daegis_consensus_score", "Local consensus score by intent", ["intent"])
                g["_g_cons_score"] = _g_cons_score
        except Exception as _e:
            try:
                logger.debug(f"[PhaseVIII] gauge hydration skipped: {_e}")
            except Exception:
                pass

        # Update gauge with current consensus score
        try:
            _g_cons_score.labels(ledger_entry.get("intent_hint", "other")).set(
                float(ledger_entry.get("consensus_score"))
            )
        except Exception:
            pass

        # --- Phase VII: Consensus Graph JSONL emitter & Surface Guard ---
        cg = None
        try:
            # snapshot for consensus graph (seed)
            score_val = (
                globals().get("daegis_consensus_score", {}).get((ledger_entry.get("intent_hint") or "other"), None)
                if isinstance(globals().get("daegis_consensus_score", {}), dict)
                else None
            )

            # Use local score if prometheus score is not available
            final_score = _local_score if (score_val is None and _local_score is not None) else score_val

            cg = {
                "episode_id": ledger_entry.get("episode_id"),
                "intent": ledger_entry.get("intent_hint") or "other",
                "status_code": int(getattr(response, "status_code", 200)),
                "latency_ms": float(locals().get("latency_ms", 0.0) or 0.0),
                "ethics_verdict": (ledger_entry.get("ethics") or {}).get("verdict", "PASS"),
                "provider": (ledger_entry.get("provider") or {}).get("name", "unknown"),
                # read gauge snapshot if available; otherwise use local consensus
                "consensus_score": float(final_score) if final_score is not None else None,
                "decision_time": ledger_entry.get("decision_time"),
            }
            with open("logs/consensus.jsonl", "a", encoding="utf-8") as g:
                g.write(json.dumps(cg) + "\n")
        except Exception as _e:
            logger.warning(f"[PhaseVII] consensus graph emit skipped: {_e}")

        # --- Phase VII: Surface-only Consensus Guard ---
        try:
            if cg is not None:
                _score = cg.get("consensus_score", None)
                if _score is not None and float(_score) < float(os.getenv("CONSENSUS_HOLD_THRESHOLD", "0.70")):
                    # 可視化のみ：レスポンスヘッダとledger注釈を追加（ブロックはしない）
                    response.headers["X-Consensus-Guard"] = f"HOLD({_score:.2f})"
                    eth = ledger_entry.setdefault("ethics", {"verdict": "PASS", "rule_id": "none", "hint": ""})
                    if eth.get("verdict") == "PASS":  # 既存HOLD/FAILがあれば尊重
                        eth.update(
                            {
                                "verdict": "HOLD",
                                "rule_id": "consensus_guard",
                                "hint": f"score={_score:.2f} < TH={os.getenv('CONSENSUS_HOLD_THRESHOLD', '0.70')}",
                            }
                        )
        except Exception as _e:
            logger.warning(f"[PhaseVII] consensus guard skipped: {_e}")

        # --- Phase VII V0.4: Consensus Guard (header + ledger hint) ---
        try:
            # 1) resolve threshold
            th_env = os.getenv("CONSENSUS_HOLD_THRESHOLD")
            th = float(th_env) if th_env else 0.70

            # 2) resolve score (prefer local state, then ledger)
            _cg_score = None
            # First try local consensus state (note: _LOCAL_CONS stores by intent key)
            try:
                if "_LOCAL_CONS" in globals():
                    intent_key = (ledger_entry.get("intent_hint") or "other").lower()
                    # Local state stores actual scores, not in a 'score' sub-dict
                    s_val = _LOCAL_CONS["support"].get(intent_key, _CONS_PRIOR_S)
                    o_val = _LOCAL_CONS["objection"].get(intent_key, _CONS_PRIOR_O)
                    if s_val or o_val:
                        _cg_score = s_val / (s_val + o_val) if (s_val + o_val) > 0 else None
            except Exception:
                pass
            # Fallback to ledger entry
            if _cg_score is None:
                _cg_score = ledger_entry.get("consensus_score")

            # 3) decide & annotate
            trigger = (isinstance(_cg_score, (int, float))) and (_cg_score < th)
            reason = "LOW_SCORE" if trigger else "OK"
            # header (non-blocking) — set into context; middleware will inject safely
            try:
                if trigger:
                    _CTX_CG.set(f"{reason};score={_cg_score:.4f};th={th:.2f}")
            except Exception as _h:
                logger.debug(f"[PhaseVII] guard header ctx skip: {_h}")

            # ledger hint (always write)
            ledger_entry["consensus_guard"] = {
                "trigger": bool(trigger),
                "score": (float(_cg_score) if isinstance(_cg_score, (int, float)) else None),
                "threshold": float(th),
                "reason": reason,
            }
        except Exception as _e:
            logger.warning(f"[PhaseVII] guard eval skipped: {_e}")
        # --- /V0.4 ---

        # --- Phase IX: Governor composite (header + ledger) ---
        try:
            gov = {"reasons": [], "score": None, "thresholds": {}}
            # consensus guard
            cg = ledger_entry.get("consensus_guard") or {}
            if cg.get("trigger"):
                gov["reasons"].append("LOW_SCORE")
            if cg.get("score") is not None:
                gov["score"] = float(cg.get("score"))
            th = cg.get("threshold")
            if th is not None:
                gov["thresholds"]["consensus"] = float(th)
            # SLA
            intent_hint = (ledger_entry.get("intent_hint") or "other").upper()
            sla_ms = float(os.getenv(f"DAEGIS_SLA_{intent_hint}_MS", os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000")))
            lat = float(ledger_entry.get("latency_ms") or 0.0)
            if lat > sla_ms:
                gov["reasons"].append("SLA_HOLD")
                gov["thresholds"]["sla_ms"] = sla_ms
            # HTTP status
            st = int(ledger_entry.get("status", 200))
            if st >= 500:
                gov["reasons"].append("HTTP_5XX")
            # header (non-blocking)
            if gov["reasons"]:
                try:
                    response.headers["X-Governor"] = ";".join(gov["reasons"])
                except Exception:
                    pass
            ledger_entry["governor"] = gov
        except Exception as _e:
            logger.debug(f"[PhaseIX] governor skipped: {_e}")

        # --- Phase IX: finalize + emit governor just before persist (append-only) ---
        try:
            # ensure status & latency exist on the entry for governor logic
            if "status" not in ledger_entry:
                try:
                    ledger_entry["status"] = int(getattr(response, "status_code", 200))
                except Exception:
                    ledger_entry["status"] = 200
            if "latency_ms" not in ledger_entry:
                try:
                    ledger_entry["latency_ms"] = float(latency_ms)
                except Exception:
                    pass
            _emit_governor_safe(response, ledger_entry)
        except Exception as _ge:
            try:
                logger.debug(f"[PhaseIX] governor emit skipped: {_ge}")
            except Exception:
                pass

        # --- Phase XIV: priority planner (shadow, append-only) ---
        try:
            if ledger_entry.get("priority_hint_v2") is None:
                _cg = ledger_entry.get("consensus_guard") or {}
                _score = _cg.get("score")
                _score = float(_score) if isinstance(_score, (int, float)) else 0.7
                _hold = 1.0 if (ledger_entry.get("ethics", {}).get("verdict") == "HOLD") else 0.0
                _it = ledger_entry.get("intent_hint") or "other"
                _bias = 0.0 if _it == "other" else 0.1
                w_cons = float(os.getenv("DAEGIS_PRI_W_CONS", "0.5"))
                w_hold = float(os.getenv("DAEGIS_PRI_W_HOLD", "0.3"))
                w_bias = float(os.getenv("DAEGIS_PRI_W_BIAS", "0.2"))
                _pr = (1.0 - _score) * w_cons + _hold * w_hold + _bias * w_bias
                ledger_entry["priority_hint_v2"] = int(max(0, min(100, round(_pr * 100))))
        except Exception as _e:
            try:
                logger.debug(f"[PhaseXIV] priority planner skipped: {_e}")
            except Exception:
                pass

        # --- Phase XIV.s: ensure priority always present (hard fallback) ---
        try:
            _v = ledger_entry.get("priority_hint_v2", None)
            if not isinstance(_v, (int, float)):
                ledger_entry["priority_hint_v2"] = 0
            else:
                ledger_entry["priority_hint_v2"] = int(_v)
        except Exception:
            try:
                ledger_entry["priority_hint_v2"] = 0
            except Exception:
                pass

        # --- Phase L5.1: Shadow-Apply (forceable; robust logging; append-only) ---
        try:
            import os, json, pathlib, time

            _pg = ledger_entry.get("policy_gate") or {}
            _ready = bool(_pg.get("ready"))
            _force = str(os.getenv("L5_FORCE_SHADOW", "0")).lower() in ("1", "true", "yes")
            if _force or _ready:
                pathlib.Path("logs").mkdir(exist_ok=True)
                # L5.1 zero-suppress + baseline fallback
                _baseline = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "1000") or 1000)
                _sla_before = float(((ledger_entry.get("tuning") or {}).get("sla_suggested_ms") or 0)) or _baseline
                _sla_after = round(_sla_before * 0.9, 2)
                sim = {
                    "event": "policy_shadow_apply",
                    "ts": time.time(),
                    "intent": ledger_entry.get("intent_hint", "other"),
                    "sla_before": _sla_before,
                    "sla_after": _sla_after,
                    "forced": bool(_force),
                    "gate_stats": (_pg.get("stats") or {}),
                    "gate_thresholds": (_pg.get("thresholds") or {}),
                }
                # L5.1: zero-suppress (append-only)
                _sla_after = float(sim.get("sla_after") or 0.0)
                if _sla_after <= 0.0:
                    raise RuntimeError("L5.1: zero/invalid after -> skip append")
                with open("logs/policy_apply_shadow.jsonl", "a", encoding="utf-8") as f:
                    json.dump(sim, f, ensure_ascii=False)
                    f.write("\n")
                try:
                    _CTX_L5.set(((_CTX_L5.get() or "") + ";SHADOW_APPLY").lstrip(";"))
                except Exception:
                    pass
                try:
                    hdr = ("READY" if _ready else "NOT_READY") + ";SHADOW_APPLY"
                    resp.headers.setdefault("X-Policy-Gate", hdr)
                except Exception:
                    pass
        except Exception as _e:
            try:
                logger.debug(f"[L5.1 shim] skipped: {_e}")
            except Exception:
                pass

        # --- Phase L5.2: Controlled Apply (skip zeros; non-consecutive; append-only) ---
        try:
            import statistics, time, pathlib, json, os

            READY_N = int(os.getenv("L5_READY_STREAK", "3"))
            APPLY_PATH = "scripts/dev/env_local.sh"  # kept for back-compat (env default)
            LOG_PATH = "logs/policy_apply_controlled.jsonl"  # audit log (must be logs/...)
            ENV_PATH = os.getenv("L5_ENV_FILE", APPLY_PATH)  # configurable env sink
            lines = []
            path = pathlib.Path("logs/policy_apply_shadow.jsonl")
            if path.exists():
                with path.open("r", encoding="utf-8") as f:
                    for _ln in f:
                        _ln = _ln.strip()
                        if not _ln:
                            continue
                        try:
                            lines.append(json.loads(_ln))
                        except Exception:
                            pass
            # pick last READY_N non-zero 'sla_after' from tail (skip zeros, non-consecutive)
            kvals = []
            for item in reversed(lines):
                if not (isinstance(item, dict) and item.get("event") == "policy_shadow_apply"):
                    continue
                try:
                    aft = float(item.get("sla_after", 0) or 0)
                except Exception:
                    aft = 0.0
                if aft > 0:
                    kvals.append(aft)
                    if len(kvals) >= READY_N:
                        break
            if len(kvals) >= READY_N:
                vals = list(reversed(kvals))
                avg_after = round(statistics.mean(vals), 2)
                # 1) audit log
                pathlib.Path("logs").mkdir(exist_ok=True)
                with open(LOG_PATH, "a", encoding="utf-8") as f:
                    f.write(
                        json.dumps(
                            {
                                "event": "policy_controlled_apply",
                                "ts": time.time(),
                                "ready_streak": len(vals),
                                "avg_sla_ms": avg_after,
                                "source": str(ENV_PATH),
                            },
                            separators=(",", ":"),
                        )
                        + "\n"
                    )
                # 2) env export (append-only)
                key = (ledger_entry.get("intent_hint", "other") or "other").upper().replace("-", "_")
                pathlib.Path(os.path.dirname(ENV_PATH) or ".").mkdir(parents=True, exist_ok=True)
                with open(ENV_PATH, "a", encoding="utf-8") as f:
                    f.write(f"export DAEGIS_SLA_{key}_MS={int(round(avg_after))}\n")
                # 3) header/context hint
                try:
                    _CTX_L5.set(((_CTX_L5.get() or "") + ";CONTROLLED_APPLY").lstrip(";"))
                    resp.headers.setdefault("X-Policy-Gate", "READY;SHADOW_APPLY;CONTROLLED_APPLY")
                except Exception:
                    pass
            else:
                try:
                    logger.debug(f"[L5.2] not enough qualifying shadows (>0): have={len(kvals)} need={READY_N}")
                except Exception:
                    pass
        except Exception as _e:
            try:
                logger.debug(f"[L5.2] controlled apply skipped: {_e}")
            except Exception:
                pass

        with open(ledger_path, "a") as f:
            f.write(json.dumps(ledger_entry) + "\n")
        # --- end add ---

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

# --- Phase L5.0/L5.1 via middleware (append-only; no behavior change) ---
try:
    from fastapi import Request
    import json, pathlib, os, time

    def _tail_jsonl(path: str, max_bytes: int = 20000, max_lines: int = 200):
        p = pathlib.Path(path)
        if not p.exists():
            return []
        b = p.read_bytes()[-max_bytes:]
        lines = [ln for ln in b.decode("utf-8", "ignore").splitlines() if ln.strip()][-max_lines:]
        out = []
        for ln in lines:
            try:
                out.append(json.loads(ln))
            except Exception:
                pass
        return out

    @app.middleware("http")
    async def _l5_gate_mw(request: Request, call_next):
        resp = await call_next(request)
        try:
            # 1) Gate eval from logs (policy_decision.jsonl & decision.jsonl)
            th = float(os.getenv("L5_WIN_RATE_TH", "0.70"))
            min_samples = int(os.getenv("L5_MIN_SAMPLES", "50"))
            max_hold_rate = float(os.getenv("L5_MAX_HOLD_RATE", "0.30"))
            pol = _tail_jsonl("logs/policy_decision.jsonl", 50000, 300)
            dec = _tail_jsonl("logs/decision.jsonl", 50000, 150)
            wins = sum(1 for o in pol if bool(o.get("win")))
            total = len(pol)
            seen = len(dec)
            holds = sum(1 for o in dec if ((o.get("ethics") or {}).get("verdict") == "HOLD"))
            win_rate = (wins / total) if total else 0.0
            hold_rate = (holds / seen) if seen else 0.0
            ready = (total >= min_samples) and (win_rate >= th) and (hold_rate <= max_hold_rate)
            reasons = []
            if total < min_samples:
                reasons.append(f"samples<{min_samples}")
            if win_rate < th:
                reasons.append("win_rate_low")
            if hold_rate > max_hold_rate:
                reasons.append("hold_rate_high")
            hdr = "READY" if ready else ("NOT_READY;" + ";".join(reasons) if reasons else "NOT_READY")
            try:
                resp.headers.setdefault("X-Policy-Gate", hdr)
            except Exception:
                pass

            # 2) Shadow-Apply (READY or forced) → append-only log
            force = str(os.getenv("L5_FORCE_SHADOW", "0")).lower() in ("1", "true", "yes")
            if ready or force:
                last = dec[-1] if dec else {}
                tuning = last.get("tuning") or {}
                intent = last.get("intent_hint", "other")
                before = float(tuning.get("sla_suggested_ms", 0))
                after = round(before * 0.9, 2)
                sim = {
                    "event": "policy_shadow_apply",
                    "ts": time.time(),
                    "intent": intent,
                    "sla_before": before,
                    "sla_after": after,
                    "gate_stats": {
                        "win_rate": round(win_rate, 4),
                        "wins": wins,
                        "total": total,
                        "hold_rate": round(hold_rate, 4),
                        "holds": holds,
                        "seen": seen,
                    },
                    "gate_thresholds": {"win_rate_th": th, "min_samples": min_samples, "max_hold_rate": max_hold_rate},
                }
                pathlib.Path("logs").mkdir(exist_ok=True)
                with open("logs/policy_apply_shadow.jsonl", "a", encoding="utf-8") as f:
                    f.write(json.dumps(sim, separators=(",", ":")) + "\n")
        except Exception as _e:
            try:
                logger.debug(f"[L5 mw] skipped: {_e}")
            except Exception:
                pass
        return resp
except Exception as _e:
    try:
        logger.debug(f"[L5 mw] install failed: {_e}")
    except Exception:
        pass

# --- add: Phase V V0.2 - Stable Metrics Detection and Unified Logger ---
logger.info(f"[PhaseV] bootstrap: metrics active={_PROM_OK}")

# ENV configuration (always available)
INTENTS = sorted(set([i.strip().lower() for i in os.getenv("DAEGIS_INTENTS", "chat_answer").split(",")] + ["other"]))
SLA_DEFAULT = int(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))
PRIOR_SUPPORT = float(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10"))
PRIOR_OBJECTION = float(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5"))

# --- Phase IX.1: Guard header injector (middleware; append-only) ---
import contextvars

_CTX_CG = contextvars.ContextVar("daegis_cg_hdr", default=None)
_CTX_L5 = contextvars.ContextVar("daegis_l5_hdr", default=None)


# ensure a middleware injects the header on the final response object
@app.middleware("http")
async def _inject_guard_header(request, call_next):
    resp = await call_next(request)
    try:
        val = _CTX_CG.get()
    except Exception:
        val = None
    if val:
        try:
            resp.headers.setdefault("X-Consensus-Guard", val)
        except Exception:
            pass
    # --- L5.1 middleware assist (append-only; baseline fallback; zero-filter) ---
    # Ensure X-Policy-Gate and shadow log; never emit 0→0 records
    try:
        import os, json, pathlib, time, contextvars as _cv

        # Ensure context var exists
        if "_CTX_L5" not in globals() or globals().get("_CTX_L5") is None:
            globals()["_CTX_L5"] = _cv.ContextVar("daegis_l5_hdr", default="")
        have_hdr = any(h.lower() == "x-policy-gate" for h in resp.headers.keys())
        force = str(os.getenv("L5_FORCE_SHADOW", "0")).lower() in ("1", "true", "yes")
        ready = False
        sla_before = 0.0
        p = pathlib.Path("logs/decision.jsonl")
        o = {}
        if p.exists():
            try:
                last = [ln for ln in p.read_text(encoding="utf-8", errors="ignore").splitlines() if ln.strip()][-1]
                o = json.loads(last)
                ready = bool(
                    ((o.get("policy_gate") or {}).get("ready")) or ((o.get("governor") or {}).get("score", 0) > 0)
                )
                sla_before = float(((o.get("tuning") or {}).get("sla_suggested_ms") or 0))
            except Exception:
                pass
        if force or (not have_hdr and ready):
            pathlib.Path("logs").mkdir(exist_ok=True)
            baseline = float(os.getenv("DAEGIS_SLA_DEFAULT_MS", "1000"))
            _before = sla_before or baseline
            _after = round(float(_before) * 0.9, 2)
            if _after > 0:  # zero-filter: do not emit 0→0
                rec = {
                    "event": "policy_shadow_apply",
                    "ts": time.time(),
                    "intent": o.get("intent_hint") or o.get("intent") or "other",
                    "sla_before": _before,
                    "sla_after": _after,
                    "forced": bool(force),
                    "assist": "mw_tail",
                }
                with open("logs/policy_apply_shadow.jsonl", "a", encoding="utf-8") as f:
                    json.dump(rec, f, ensure_ascii=False)
                    f.write("\n")
            hdr = ("READY" if ready else "NOT_READY") + ";SHADOW_APPLY"
            try:
                resp.headers.setdefault("X-Policy-Gate", hdr)
            except Exception:
                pass
            try:
                cur = _CTX_L5.get() or ""
                _CTX_L5.set((cur + (";" if cur else "")) + hdr)
            except Exception:
                pass
    except Exception as _e:
        try:
            logger.debug(f"[L5.1 mw-assist] skipped: {_e}")
        except Exception:
            pass
    # L5 header (dry-run hint)
    try:
        _l5 = _CTX_L5.get()
        if _l5:
            try:
                resp.headers.setdefault("X-Policy-Gate", _l5)
            except Exception:
                pass
    except Exception:
        pass

    # --- L5 header FAILSAFE (append-only) ---
    # If header is still missing here, derive from latest decision/shadow log and attach.
    try:
        if not any(h.lower() == "x-policy-gate" for h in resp.headers.keys()):
            import pathlib, json, time, os

            hdr = None
            # 1) try latest decision with policy_gate.ready
            d = pathlib.Path("logs/decision.jsonl")
            if d.exists():
                try:
                    last = [ln for ln in d.read_text(encoding="utf-8", errors="ignore").splitlines() if ln.strip()][-1]
                    o = json.loads(last)
                    pg = o.get("policy_gate") or {}
                    if isinstance(pg, dict) and "ready" in pg:
                        hdr = ("READY" if pg.get("ready") else "NOT_READY") + ";SHADOW_APPLY"
                except Exception:
                    pass
            # 2) else fallback: if there is any recent shadow apply (>0 after), mark READY;SHADOW_APPLY
            if hdr is None:
                s = pathlib.Path("logs/policy_apply_shadow.jsonl")
                if s.exists():
                    try:
                        for ln in reversed(s.read_text(encoding="utf-8", errors="ignore").splitlines()[-10:]):
                            j = json.loads(ln)
                            aft = float(j.get("sla_after", 0) or 0)
                            if aft > 0:
                                hdr = "READY;SHADOW_APPLY"
                                break
                    except Exception:
                        pass
            # 3) final default
            if hdr is None:
                hdr = "NOT_READY;SHADOW_APPLY"
            try:
                resp.headers["X-Policy-Gate"] = hdr
            except Exception:
                pass
            try:
                cur = _CTX_L5.get() or ""
                _CTX_L5.set((cur + (";" if cur else "")) + hdr)
            except Exception:
                pass
    except Exception:
        pass
    return resp


# --- Phase IX: Governor emitter (append-only) ---
def _emit_governor_safe(response, ledger_entry):
    try:
        gov = {"reasons": [], "score": None, "thresholds": {}}
        cg = (ledger_entry or {}).get("consensus_guard") or {}
        if cg.get("trigger"):
            gov["reasons"].append("LOW_SCORE")
        if cg.get("score") is not None:
            gov["score"] = float(cg["score"])
        if cg.get("threshold") is not None:
            gov["thresholds"]["consensus"] = float(cg["threshold"])
        # SLA判定（ENV優先→なければデフォルト）
        intent_hint = ((ledger_entry or {}).get("intent_hint") or "other").upper()
        _sla_env = os.getenv(f"DAEGIS_SLA_{intent_hint}_MS", os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))
        try:
            sla_ms = float(_sla_env) if _sla_env is not None else 3000.0
        except Exception:
            sla_ms = 3000.0
        lat = float((ledger_entry or {}).get("latency_ms") or 0.0)
        if lat > sla_ms:
            gov["reasons"].append("SLA_HOLD")
            gov["thresholds"]["sla_ms"] = sla_ms
        st = int((ledger_entry or {}).get("status", 200))
        if st >= 500:
            gov["reasons"].append("HTTP_5XX")
        # ヘッダは理由があるときのみ、ledger には常に格納
        if gov["reasons"]:
            try:
                response.headers["X-Governor"] = ";".join(gov["reasons"])
            except Exception:
                pass
        if isinstance(ledger_entry, dict):
            ledger_entry["governor"] = gov
    except Exception as _e:
        try:
            logger.debug(f"[PhaseIX] governor skipped: {_e}")
        except Exception:
            pass


# --- Phase VII V0.3: local consensus core (append-only) ---
_LOCAL_CONS = {"support": {}, "objection": {}}
_CONS_PRIOR_S = int(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10") or "10")
_CONS_PRIOR_O = int(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5") or "5")


def _local_cons_update(intent: str, outcome: str) -> float:
    # outcome: "support" or "objection"
    S = _LOCAL_CONS["support"].setdefault(intent, _CONS_PRIOR_S)
    obj = _LOCAL_CONS["objection"].setdefault(intent, _CONS_PRIOR_O)
    if outcome == "support":
        S += 1
        _LOCAL_CONS["support"][intent] = S
    elif outcome == "objection":
        obj += 1
        _LOCAL_CONS["objection"][intent] = obj
    total = S + obj
    return (S / total) if total else None


def _local_cons_snapshot(intent: str):
    S = _LOCAL_CONS["support"].get(intent, _CONS_PRIOR_S)
    obj = _LOCAL_CONS["objection"].get(intent, _CONS_PRIOR_O)
    tot = S + obj
    return {"support": S, "objection": obj, "score": (S / tot) if tot else None}


# --- /local consensus core ---


def sla_ms(intent):
    return int(os.getenv(f"DAEGIS_SLA_{intent.upper()}_MS", str(SLA_DEFAULT)))


# Hot-probe system for runtime prometheus_client detection
import importlib.util

_PROM_ACTIVE = False
_METRICS_INIT = False

# --- metrics init: duplicate guard (append-only) ---
METRICS_INIT_DONE = globals().get("METRICS_INIT_DONE", False)


def _safe_metrics_init():
    global METRICS_INIT_DONE
    if METRICS_INIT_DONE:
        return False  # already initialized
    try:
        # 既存のメトリクス登録処理をここで呼ぶ（例：_init_metrics()）
        # _init_metrics()
        METRICS_INIT_DONE = True
        return True
    except Exception as e:
        # Duplicate timeseries 等はログだけに留めて運転継続
        logger.warning(f"[PhaseV] metrics init skipped: {e}")
        return False


def _extend_sys_path_for_venv():
    ve = os.getenv("VIRTUAL_ENV")
    try:
        if not ve:
            return False
        sp = os.path.join(
            ve,
            "lib",
            f"python{sys.version_info.major}.{sys.version_info.minor}",
            "site-packages",
        )
        if os.path.isdir(sp) and sp not in sys.path:
            sys.path.append(sp)
            logger.info(f"[PhaseV] sys.path extended -> {sp}")
            return True
    except Exception as e:
        logger.warning(f"[PhaseV] venv path inject failed: {e}")
    return False


def _prom_available():
    return importlib.util.find_spec("prometheus_client") is not None


def _try_enable_prom():
    global _PROM_ACTIVE
    if _PROM_ACTIVE:
        return True
    changed = _extend_sys_path_for_venv()
    importlib.invalidate_caches()
    try:
        mod = importlib.import_module("prometheus_client")
    except Exception:
        logger.debug("[PhaseV] hot-probe: prometheus_client not found (post-invalidate)")
        return False
    try:
        Counter = getattr(mod, "Counter")
        Gauge = getattr(mod, "Gauge")
        REGISTRY = getattr(mod, "REGISTRY")
        generate_latest = getattr(mod, "generate_latest")
        CONTENT_TYPE_LATEST = getattr(mod, "CONTENT_TYPE_LATEST")
        globals().update(
            Counter=Counter,
            Gauge=Gauge,
            REGISTRY=REGISTRY,
            generate_latest=generate_latest,
            CONTENT_TYPE_LATEST=CONTENT_TYPE_LATEST,
        )
        _PROM_ACTIVE = True
        logger.info(f"[PhaseV] 🔄 hot-probe success (venv_injected={changed}) → metrics active=True")
        return True
    except Exception as e:
        logger.warning(f"[PhaseV] hot-probe load failed: {e}")
        return False


def _ensure_metrics_once(intents):
    global _METRICS_INIT
    logger.debug(f"[PhaseV] ensure_metrics start, _PROM_ACTIVE={_PROM_ACTIVE}")
    if _METRICS_INIT or not _PROM_ACTIVE:
        # dormant: keep no-ops; DO NOT mark ready to preserve hot-probe flip
        return False
    # declare counters/gauges (same names as V0 spec)
    globals().update(
        _m_int_total=Counter("daegis_compass_intents_total", "Intent flags", ["intent"]),
        _m_int_succ=Counter("daegis_compass_intents_success_total", "Success by intent", ["intent"]),
        _m_int_fail=Counter("daegis_compass_intents_failure_total", "Failure by intent", ["intent"]),
        _m_int_hold=Counter("daegis_compass_intents_hold_total", "Hold by intent", ["intent"]),
        _m_sup=Counter("daegis_consensus_support_total", "Support votes", ["intent"]),
        _m_obj=Counter("daegis_consensus_objection_total", "Objection votes", ["intent"]),
        _m_score=Gauge("daegis_consensus_score", "Consensus score", ["intent"]),
    )
    PRI_S = int(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10"))
    PRI_O = int(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5"))
    for it in intents:
        _m_int_total.labels(it).inc(0)
        _m_int_succ.labels(it).inc(0)
        _m_int_fail.labels(it).inc(0)
        _m_int_hold.labels(it).inc(0)
        _m_sup.labels(it).inc(PRI_S)
        _m_obj.labels(it).inc(PRI_O)
        s = _m_sup.labels(it)._value.get()
        o = _m_obj.labels(it)._value.get()
        _m_score.labels(it).set(s / (s + o))
    _METRICS_INIT = True
    logger.info(f"[PhaseV] metrics initialized for intents={intents}")


# No-op metric stubs for when prometheus_client unavailable
class _NoopMetric:
    def labels(self, *_, **__):
        return self

    def inc(self, *_):
        pass

    def set(self, *_):
        pass


# Initialize metrics (prometheus_client-safe)
compass_total = compass_success = compass_failure = compass_hold = _NoopMetric()
consensus_support = consensus_objection = consensus_score = _NoopMetric()

if _PROM_OK:
    try:
        from prometheus_client import Counter, Gauge

        # Metrics declarations
        compass_total = Counter("daegis_compass_intents_total", "Intent flags", ["intent"])
        compass_success = Counter("daegis_compass_intents_success_total", "Success by intent", ["intent"])
        compass_failure = Counter("daegis_compass_intents_failure_total", "Failure by intent", ["intent"])
        compass_hold = Counter("daegis_compass_intents_hold_total", "Hold by intent", ["intent"])
        consensus_support = Counter("daegis_consensus_support_total", "Support votes", ["intent"])
        consensus_objection = Counter("daegis_consensus_objection_total", "Objection votes", ["intent"])
        consensus_score = Gauge("daegis_consensus_score", "Consensus score", ["intent"])

        # Initialize priors and zero metrics
        _priors_applied = set()
        for intent in INTENTS:
            # Zero-emit all metrics for this intent
            compass_total.labels(intent=intent)
            compass_success.labels(intent=intent)
            compass_failure.labels(intent=intent)
            compass_hold.labels(intent=intent)

            # Apply priors once per intent
            if intent not in _priors_applied:
                consensus_support.labels(intent=intent).inc(PRIOR_SUPPORT)
                consensus_objection.labels(intent=intent).inc(PRIOR_OBJECTION)
                consensus_score.labels(intent=intent).set(PRIOR_SUPPORT / (PRIOR_SUPPORT + PRIOR_OBJECTION))
                _priors_applied.add(intent)

        # one-time metrics init guard (function attribute; no globals)
        if getattr(bootstrap, '_metrics_inited', False):
            bootstrap._metrics_inited = True
            init_metrics_once()
        logger.info(f"[PhaseV] Metrics initialized, intents={INTENTS}")
    except Exception as e:
        logger.warning(f"[PhaseV] Metrics init warning: {e}")
        # Note: Do not modify global _PROM_OK here - respect top-level detection
else:
    logger.info(f"[PhaseV] Metrics dormant, intents={INTENTS}")


@app.middleware("http")
async def _phase_v_intent_feedback(request, call_next):
    if request.url.path.rstrip("/") != "/chat" or request.method != "POST":
        return await call_next(request)

    t0 = time.monotonic_ns()
    response = await call_next(request)
    latency_ms = float(time.monotonic_ns() - t0) / 1_000_000

    # Extract intent safely
    intent = (response.headers.get("X-Intent") or getattr(request.state, "intent_hint", "other") or "other").lower()
    if intent not in INTENTS[:-1]:  # exclude "other" from check
        intent = "other"

    # Outcome classification (exclusive precedence)
    verdict, rule_id, hint = "PASS", "none", ""

    # Hot-probe and lazy metrics initialization
    if not _PROM_ACTIVE:
        _try_enable_prom()
    if _PROM_ACTIVE:
        _ensure_metrics_safe(INTENTS)

    # Metrics updates (guarded with _PROM_ACTIVE)
    if _PROM_ACTIVE:
        if 500 <= response.status_code < 600:
            _m_int_fail.labels(intent).inc()
            _m_obj.labels(intent).inc()
            verdict, rule_id = "PASS", "failure_5xx"
        elif latency_ms > sla_ms(intent):
            _m_int_hold.labels(intent).inc()
            _m_obj.labels(intent).inc()
            verdict, rule_id, hint = "HOLD", "sla_guard", f"latency {latency_ms:.1f}ms > SLA {sla_ms(intent)}ms"
        elif 200 <= response.status_code < 300:
            _m_int_succ.labels(intent).inc()
            _m_sup.labels(intent).inc()

        # Update consensus score and total
        try:
            s = _m_sup.labels(intent)._value.get()
            o = _m_obj.labels(intent)._value.get()
            if s + o > 0:
                _m_score.labels(intent).set(s / (s + o))
        except Exception:
            pass

        _m_int_total.labels(intent).inc()
    else:
        # Dormant mode - only classify for ethics
        if 500 <= response.status_code < 600:
            verdict, rule_id = "PASS", "failure_5xx"
        elif latency_ms > sla_ms(intent):
            verdict, rule_id, hint = "HOLD", "sla_guard", f"latency {latency_ms:.1f}ms > SLA {sla_ms(intent)}ms"

    # Store ethics in request state for ledger integration (always active)
    request.state.ethics = {"verdict": verdict, "rule_id": rule_id, "hint": hint}

    return response


# --- end add ---

# --- add: Phase V V0.1 Safe Bootstrap ---
import os, time, logging

logger = logging.getLogger(__name__)
try:
    from prometheus_client import Counter, Gauge

    _PROM_OK = True
except Exception:
    _PROM_OK = False

INTENTS = [i.strip().lower() for i in os.getenv("DAEGIS_INTENTS", "chat_answer").split(",") if i.strip()]
if "other" not in INTENTS:
    INTENTS.append("other")
SLA_DEF = int(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))


def _sla_ms(intent: str) -> int:
    try:
        return int(os.getenv(f"DAEGIS_SLA_{intent.upper()}_MS", str(SLA_DEF)))
    except Exception:
        return SLA_DEF


class _NoopMetric:
    def labels(self, *_, **__):
        return self

    def inc(self, *_):
        pass

    def set(self, *_):
        pass


if _PROM_OK:
    try:
        intents_total = Counter("daegis_compass_intents_total", "Total intents", ["intent"])
        intents_success = Counter("daegis_compass_intents_success_total", "Success intents", ["intent"])
        intents_failure = Counter("daegis_compass_intents_failure_total", "Failure intents", ["intent"])
        intents_hold = Counter("daegis_compass_intents_hold_total", "Hold intents", ["intent"])
        cons_support = Counter("daegis_consensus_support_total", "Consensus support", ["intent"])
        cons_objection = Counter("daegis_consensus_objection_total", "Consensus objection", ["intent"])
        cons_score = Gauge("daegis_consensus_score", "Consensus score", ["intent"])
        _PRI_S = int(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10"))
        _PRI_O = int(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5"))
        _support, _objection = {}, {}
        for it in INTENTS:
            intents_total.labels(it).inc(0)
            intents_success.labels(it).inc(0)
            intents_failure.labels(it).inc(0)
            intents_hold.labels(it).inc(0)
            _support[it], _objection[it] = _PRI_S, _PRI_O
            cons_score.labels(it).set(_PRI_S / (_PRI_S + _PRI_O))
    except Exception as e:
        logger.warning(f"[PhaseV] Metrics init skipped: {e}")
        intents_total = intents_success = intents_failure = intents_hold = cons_support = cons_objection = (
            cons_score
        ) = _NoopMetric()
        _support = {it: 0 for it in INTENTS}
        _objection = {it: 0 for it in INTENTS}
else:
    logger.info("[PhaseV] Prometheus client not available — metrics dormant")
    intents_total = intents_success = intents_failure = intents_hold = cons_support = cons_objection = cons_score = (
        _NoopMetric()
    )
    _support = {it: 0 for it in INTENTS}
    _objection = {it: 0 for it in INTENTS}
logger.info(
    f"[PhaseV] bootstrap: metrics active={_PROM_ACTIVE}, venv={os.getenv('VIRTUAL_ENV') or 'None'}, hot-probe ready"
)


def phasev_update(intent: str, status_code: int, latency_ms: float, entry: dict | None = None):
    """Append ledger.ethics/provider and update metrics (Oracle internal brain)."""
    try:
        it = (intent or "other").lower()
        it = it if it in INTENTS else "other"
        intents_total.labels(it).inc()
        verdict, rule_id, hint = "PASS", "none", ""
        if 500 <= int(status_code) < 600:
            intents_failure.labels(it).inc()
            cons_objection.labels(it).inc()
            _objection[it] += 1
        elif float(latency_ms) > _sla_ms(it):
            intents_hold.labels(it).inc()
            cons_objection.labels(it).inc()
            _objection[it] += 1
            verdict, rule_id, hint = "HOLD", "sla_guard", f"latency_ms={latency_ms:.0f}>SLA={_sla_ms(it)}"
        elif 200 <= int(status_code) < 300:
            intents_success.labels(it).inc()
            cons_support.labels(it).inc()
            _support[it] += 1
        tot = _support[it] + _objection[it]
        if tot > 0:
            cons_score.labels(it).set(_support[it] / tot)
        if isinstance(entry, dict):
            entry["ethics"] = {"verdict": verdict, "rule_id": rule_id, "hint": hint}
            entry["provider"] = {"name": "oracle-internal", "model": "auto"}
    except Exception as e:
        logger.warning(f"[PhaseV] update skipped: {e}")


# --- end add ---


# --- add: Phase VI.1 - Distributed Ledger /hash endpoint ---
def _daegis_ledger_sha_and_ts(path="logs/decision.jsonl"):
    """Calculate SHA256 of ledger and extract latest decision_time (read-only)"""
    sha = hashlib.sha256()
    ts = "-"
    try:
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(1 << 20), b""):
                sha.update(chunk)
        # tail-1
        with open(path, "rb") as f:
            try:
                last = f.readlines()[-1].decode("utf-8", "ignore")
                obj = json.loads(last)
                ts = obj.get("decision_time") or obj.get("event_time") or "-"
            except Exception:
                ts = "-"
        return sha.hexdigest(), ts
    except Exception:
        return "MISSING", "-"


@app.get("/hash")
async def daegis_hash():
    """Phase VI.1: Return ledger SHA, decision_time, and node metadata for distributed consistency checks"""
    ledger_sha, ts = _daegis_ledger_sha_and_ts()
    try:
        node_id = socket.gethostname()
    except Exception:
        node_id = "unknown"
    # app_version placeholder - can be enhanced with existing provenance logic
    return {"ledger_sha": ledger_sha, "decision_time": ts, "node_id": node_id, "app_version": ""}


# --- Phase XVb: consensus snapshot safe-floats (quiet warnings) ---
def _safe_float(x):
    try:
        return float(x)
    except Exception:
        return None


# --- Phase VIII · /consensus snapshot (append-only) ---
@app.get("/consensus")
async def _daegis_consensus_snapshot():
    try:
        st = dict(globals().get("_LOCAL_CONS", {}) or {})
        # Stabilize shape & types
        out = {
            "intent": str(st.get("intent", "other")),
            "support": _safe_float(st.get("support", 0.0)) or 0.0,
            "objection": _safe_float(st.get("objection", 0.0)) or 0.0,
            "score": _safe_float(st.get("score", 0.0)) or 0.0,
            "updated_at": st.get("updated_at", None),
            "node_id": socket.gethostname(),
        }
        return JSONResponse(out)
    except Exception as _e:
        try:
            logger.warning(f"[PhaseVIII] /consensus snapshot error: {_e}")
        except Exception:
            pass
        return JSONResponse({"error": "snapshot_unavailable", "detail": str(_e)}, status_code=200)


# --- end add ---


# --- Phase V Safe-Metrics Hotfix (append-only) ---
def _ensure_metrics_safe(intents):
    """Safe wrapper around _ensure_metrics that catches CollectorRegistry duplications"""
    global _METRICS_INIT
    try:
        _ensure_metrics_once(intents)
    except ValueError as e:
        if "Duplicated timeseries" in str(e):
            logger.warning(f"[PhaseV] metrics init suppressed: {e}")
            _METRICS_INIT = True  # Prevent retries
            _hydrate_metric_noops()
            _hydrate_consensus_noops()
        else:
            logger.warning(f"[PhaseV] metrics init degraded: {e}")
            _hydrate_metric_noops()
            _hydrate_consensus_noops()
    except Exception as e:
        logger.warning(f"[PhaseV] metrics init degraded: {e}")
        _hydrate_metric_noops()
        _hydrate_consensus_noops()


# --- /hotfix ---


# --- Phase V No-Op Metrics Hydration (append-only) ---
class _NoOpMetric:
    """Tiny no-op metric class to prevent NameError when metrics init is suppressed"""

    def labels(self, *args, **kwargs):
        return self

    def inc(self, *args, **kwargs):
        return self

    def observe(self, *args, **kwargs):
        return self

    def set(self, *args, **kwargs):
        return self


def _hydrate_metric_noops():
    """Ensure metric globals exist as no-ops if missing/None"""
    global _m_int_total, _m_int_succ, _m_int_fail, _m_int_hold
    _noop = _NoOpMetric()
    hydrated = False

    if "_m_int_total" not in globals() or globals().get("_m_int_total") is None:
        globals()["_m_int_total"] = _noop
        hydrated = True
    if "_m_int_succ" not in globals() or globals().get("_m_int_succ") is None:
        globals()["_m_int_succ"] = _noop
        hydrated = True
    if "_m_int_fail" not in globals() or globals().get("_m_int_fail") is None:
        globals()["_m_int_fail"] = _noop
        hydrated = True
    if "_m_int_hold" not in globals() or globals().get("_m_int_hold") is None:
        globals()["_m_int_hold"] = _noop
        hydrated = True

    if hydrated:
        logger.info("[PhaseV] metrics no-op handles active")


# Module tail hydration (runs on import)
_hydrate_metric_noops()


# --- Phase V · metrics noop hydration (support/objection) ---
def _hydrate_consensus_noops():
    """Guarantee consensus metric globals exist even when prometheus is dormant."""
    try:
        g = globals()
        _noop = g.get("_noop", None)
        if _noop is None:

            class _NoOpMetric:
                def labels(self, *a, **k):
                    return self

                def inc(self, *a, **k):
                    return self

                def set(self, *a, **k):
                    return self

                def observe(self, *a, **k):
                    return self

            _noop = _NoOpMetric()
            g["_noop"] = _noop
        for name in ("_m_sup", "_m_obj", "_g_cons_score"):
            if g.get(name) is None:
                g[name] = _noop
    except Exception as _e:
        try:
            logger.debug(f"[PhaseV] noop consensus hydration skipped: {_e}")
        except Exception:
            pass


_hydrate_consensus_noops()
# --- /noop-hydration ---

# --- Phase XIII: metrics init-once (no duplicate, hot-flip safe) ---
_METRICS_READY = globals().get("_METRICS_READY", False)


def _ensure_metrics_once(intents):
    """
    Initialize Prom metrics exactly once. If dormant (_PROM_ACTIVE=False), do not mark ready
    so that later hot-probe can flip to active. Avoid duplicate registration.
    """
    g = globals()
    if g.get("_METRICS_READY", False):
        return True
    if not g.get("_PROM_ACTIVE", False):
        # dormant: keep no-ops; DO NOT mark ready to preserve hot-probe flip
        _hydrate_metric_noops()
        _hydrate_consensus_noops()
        return False
    try:
        from prometheus_client import REGISTRY, Counter, Gauge

        existing = {m.name for m in REGISTRY.collect()}
        # if any of our families already exist, treat as ready (reuse, no duplicate define)
        needed = {
            "daegis_compass_intents_total",
            "daegis_compass_intents_success_total",
            "daegis_compass_intents_failure_total",
            "daegis_compass_intents_hold_total",
            "daegis_consensus_score",
        }
        if needed & existing:
            g["_METRICS_READY"] = True
            return True
        # first-time define (names match previous conventions)
        g["_m_int_total"] = Counter("daegis_compass_intents_total", "Intent flags", ["intent"])
        g["_m_int_succ"] = Counter("daegis_compass_intents_success_total", "Success", ["intent"])
        g["_m_int_fail"] = Counter("daegis_compass_intents_failure_total", "Failure", ["intent"])
        g["_m_int_hold"] = Counter("daegis_compass_intents_hold_total", "Hold", ["intent"])
        g["_g_cons_score"] = Gauge("daegis_consensus_score", "Consensus score", ["intent"])
        for it in intents:
            _m_int_total.labels(it).inc(0)
            _m_int_succ.labels(it).inc(0)
            _m_int_fail.labels(it).inc(0)
            _m_int_hold.labels(it).inc(0)
            _g_cons_score.labels(it).set(0.0)
        g["_METRICS_READY"] = True
        return True
    except Exception as e:
        logger.warning(f"[PhaseXIII] metrics init degraded: {e}")
        _hydrate_metric_noops()
        _hydrate_consensus_noops()
        return False


# best-effort call on import; safe no-op in dormant
try:
    _ensure_metrics_once(INTENTS)
except Exception as _e:
    logger.debug(f"[PhaseXIII] ensure_once skipped: {_e}")

# --- Phase V · L2+ tuner helpers (append-only) ---
_SLA_EWMA = {}  # intent -> ms (float)


def _clamp(v, lo, hi):
    return lo if v < lo else hi if v > hi else v


# --- Phase VII · Tuner Exporter (append-only) ---
try:
    from prometheus_client import Gauge

    _m_tuner_sla_suggested = Gauge("daegis_tuner_sla_suggested_ms", "Tuner suggested SLA per intent", ["intent"])
except Exception:
    _m_tuner_sla_suggested = None


def _update_tuner_gauge(intent: str, value: float):
    if _m_tuner_sla_suggested:
        try:
            _m_tuner_sla_suggested.labels(intent).set(value)
        except Exception:
            pass


# --- Phase VIII · Consensus Exporter (append-only) ---
try:
    from prometheus_client import Gauge

    _g_cons_support = Gauge("daegis_consensus_support_total", "Total supports per intent (local)", ["intent"])
    _g_cons_objection = Gauge("daegis_consensus_objection_total", "Total objections per intent (local)", ["intent"])
    _g_cons_score = Gauge("daegis_consensus_score", "Consensus score (local)", ["intent"])
except Exception:
    _g_cons_support = _g_cons_objection = _g_cons_score = None


def _export_consensus_to_gauges():
    """Push _LOCAL_CONS snapshot to Prometheus Gauges (no-op if dormant)."""
    try:
        state = globals().get("_LOCAL_CONS", {})
        if not state:
            return
        sup = float(state.get("support", 0.0))
        obj = float(state.get("objection", 0.0))
        sc = float(state.get("score", 0.0))
        intent = str(state.get("intent", "other"))
        if _g_cons_support:
            _g_cons_support.labels(intent).set(sup)
        if _g_cons_objection:
            _g_cons_objection.labels(intent).set(obj)
        if _g_cons_score:
            _g_cons_score.labels(intent).set(sc)
    except Exception as _e:
        try:
            logger.debug(f"[PhaseVIII] exporter skipped: {_e}")
        except Exception:
            pass


def _phasev_tuner_once(primary_intent: str, latency_ms: float, entry: dict) -> int:
    """
    Compute/update EWMA per intent and write suggested SLA to ledger_entry.tuning.
    alpha=0.3, suggest = clamp(EWMA,500,8000) * 1.2 (k).
    Prom gauge set if available (no-op shim otherwise).
    """
    if not primary_intent:
        primary_intent = "other"
    try:
        a = 0.3
        k = 1.2
        base = latency_ms if latency_ms > 0 else _SLA_EWMA.get(primary_intent, 1000.0)
        prev = float(_SLA_EWMA.get(primary_intent, base))
        cur = (1.0 - a) * prev + a * base
        _SLA_EWMA[primary_intent] = cur
        suggested = int(_clamp(cur, 500.0, 8000.0) * k)
        # ledger append
        entry.setdefault("tuning", {})["sla_suggested_ms"] = suggested
        # tuner gauge update
        _update_tuner_gauge(primary_intent, suggested)
        return suggested
    except Exception as e:
        # do not fail request
        logger.debug(f"[PhaseV] tuner error: {e}")
        return 0


# Hook: export consensus after each request's consensus update (append-only)
try:
    _ = _export_consensus_to_gauges
except NameError:

    def _export_consensus_to_gauges():
        pass


# --- L5 hotfix: ensure time is imported (append-only) ---
try:
    import time  # needed by L5.1/L5.2 blocks
except Exception:
    pass
