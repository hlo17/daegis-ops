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
from typing import Dict, Tuple
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

# --- add: Unified logger for Phase V ---
logger = logging.getLogger("router")
if not logger.handlers:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

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
    pass  # Hot-probe metrics endpoint defined later

@app.get("/metrics")
async def metrics():
    # Try to enable at call-time
    if not _PROM_ACTIVE and _try_enable_prom():
        logger.info("[PhaseV] 🔁 /metrics triggered runtime activation")
        _ensure_metrics([i.strip() for i in os.getenv("DAEGIS_INTENTS","chat_answer").split(",") if i.strip()] + ["other"])
    
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
@app.middleware("http")
async def _daegis_episode_mw(request, call_next):
    # /chat POST のみ対象（末尾スラッシュも吸収）
    path = request.url.path.rstrip("/")
    if path == "/chat" and request.method == "POST":
        t0_ns = time.monotonic_ns()
        corr_id = (
            request.headers.get("X-Corr-ID")
            or request.headers.get("X-Correlation-ID")
            or f"cid-{uuid4().hex[:12]}"
        )
        episode_id = _daegis_episode_id(corr_id)

        response = await call_next(request)
        latency_ms = (time.monotonic_ns() - t0_ns) / 1_000_000.0
        response.headers["X-Episode-ID"] = episode_id

        # --- add: intent breadcrumb (header + ledger) ---
        intent_hint = request.headers.get("X-Intent", "chat_answer")
        response.headers["X-Intent"] = intent_hint
        # --- end add ---

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

        # --- add: decision ledger (enriched) ---
        ledger_path = "logs/decision.jsonl"
        os.makedirs("logs", exist_ok=True)
        
        # Get provenance data
        import subprocess, socket
        try:
            git_sha = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], 
                                            stderr=subprocess.DEVNULL, 
                                            text=True).strip()
        except:
            git_sha = ""
        
        ledger_entry = {
            "episode_id": episode_id,
            "corr_id": corr_id,
            "decision_time": time.time(),
            "compass_version": "",
            "event_time": datetime.utcnow().isoformat() + "Z",
            "observed_time": datetime.utcnow().isoformat() + "Z",
            "intent_hint": intent_hint,
            "provenance": {
                "app_version": git_sha,
                "host": socket.gethostname(),
                "task": "ReviewGate"
            }
        }
        
        # Add ethics field with defaults
        ledger_entry["ethics"] = getattr(request.state, "ethics", {"verdict": "PASS", "rule_id": "none", "hint": ""})
        
        # Generate hash without hash field
        ledger_for_hash = ledger_entry.copy()
        ledger_hash = hashlib.sha256(
            json.dumps(ledger_for_hash, sort_keys=True).encode()
        ).hexdigest()
        ledger_entry["hash"] = ledger_hash
        
        # Wire-up Phase V internal brain
        try:
            phasev_update(intent_hint, int(getattr(response, "status_code", 200)), float(latency_ms), ledger_entry)
        except Exception as _e:
            logger.warning(f"[PhaseV] call skipped: {_e}")
        
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

# --- add: Phase V V0.2 - Stable Metrics Detection and Unified Logger ---
logger.info(f"[PhaseV] bootstrap: metrics active={_PROM_OK}")

# ENV configuration (always available)
INTENTS = [i.strip().lower() for i in os.getenv("DAEGIS_INTENTS", "chat_answer").split(",")] + ["other"]
SLA_DEFAULT = int(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))
PRIOR_SUPPORT = float(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10"))
PRIOR_OBJECTION = float(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5"))

def sla_ms(intent):
    return int(os.getenv(f"DAEGIS_SLA_{intent.upper()}_MS", str(SLA_DEFAULT)))

# Hot-probe system for runtime prometheus_client detection
import importlib.util, sys, sysconfig

_PROM_ACTIVE = False
_METRICS_INIT = False

def _extend_sys_path_for_venv():
    ve = os.getenv("VIRTUAL_ENV")
    try:
        if not ve:
            return False
        sp = os.path.join(
            ve, "lib",
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
        Counter = getattr(mod, "Counter"); Gauge = getattr(mod, "Gauge")
        REGISTRY = getattr(mod, "REGISTRY")
        generate_latest = getattr(mod, "generate_latest")
        CONTENT_TYPE_LATEST = getattr(mod, "CONTENT_TYPE_LATEST")
        globals().update(Counter=Counter, Gauge=Gauge, REGISTRY=REGISTRY,
                         generate_latest=generate_latest, CONTENT_TYPE_LATEST=CONTENT_TYPE_LATEST)
        _PROM_ACTIVE = True
        logger.info(f"[PhaseV] 🔄 hot-probe success (venv_injected={changed}) → metrics active=True")
        return True
    except Exception as e:
        logger.warning(f"[PhaseV] hot-probe load failed: {e}")
        return False

def _ensure_metrics(intents):
    global _METRICS_INIT
    logger.debug(f"[PhaseV] ensure_metrics start, _PROM_ACTIVE={_PROM_ACTIVE}")
    if _METRICS_INIT or not _PROM_ACTIVE:
        return
    # declare counters/gauges (same names as V0 spec)
    globals().update(
        _m_int_total = Counter("daegis_compass_intents_total", "Intent flags", ["intent"]),
        _m_int_succ  = Counter("daegis_compass_intents_success_total", "Success by intent", ["intent"]),
        _m_int_fail  = Counter("daegis_compass_intents_failure_total", "Failure by intent", ["intent"]),
        _m_int_hold  = Counter("daegis_compass_intents_hold_total", "Hold by intent", ["intent"]),
        _m_sup       = Counter("daegis_consensus_support_total", "Support votes", ["intent"]),
        _m_obj       = Counter("daegis_consensus_objection_total", "Objection votes", ["intent"]),
        _m_score     = Gauge("daegis_consensus_score", "Consensus score", ["intent"]),
    )
    PRI_S = int(os.getenv("CONSENSUS_PRIOR_SUPPORT", "10"))
    PRI_O = int(os.getenv("CONSENSUS_PRIOR_OBJECTION", "5"))
    for it in intents:
        _m_int_total.labels(it).inc(0); _m_int_succ.labels(it).inc(0)
        _m_int_fail.labels(it).inc(0);  _m_int_hold.labels(it).inc(0)
        _m_sup.labels(it).inc(PRI_S);   _m_obj.labels(it).inc(PRI_O)
        s = _m_sup.labels(it)._value.get(); o = _m_obj.labels(it)._value.get()
        _m_score.labels(it).set(s/(s+o))
    _METRICS_INIT = True
    logger.info(f"[PhaseV] metrics initialized for intents={intents}")

# No-op metric stubs for when prometheus_client unavailable
class _NoopMetric:
    def labels(self, *_, **__): return self
    def inc(self, *_): pass
    def set(self, *_): pass

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
        _ensure_metrics(INTENTS)
    
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
if "other" not in INTENTS: INTENTS.append("other")
SLA_DEF = int(os.getenv("DAEGIS_SLA_DEFAULT_MS", "3000"))
def _sla_ms(intent: str) -> int:
    try: return int(os.getenv(f"DAEGIS_SLA_{intent.upper()}_MS", str(SLA_DEF)))
    except Exception: return SLA_DEF

class _NoopMetric:
    def labels(self, *_, **__): return self
    def inc(self, *_): pass
    def set(self, *_): pass

if _PROM_OK:
    try:
        intents_total   = Counter("daegis_compass_intents_total","Total intents",["intent"])
        intents_success = Counter("daegis_compass_intents_success_total","Success intents",["intent"])
        intents_failure = Counter("daegis_compass_intents_failure_total","Failure intents",["intent"])
        intents_hold    = Counter("daegis_compass_intents_hold_total","Hold intents",["intent"])
        cons_support    = Counter("daegis_consensus_support_total","Consensus support",["intent"])
        cons_objection  = Counter("daegis_consensus_objection_total","Consensus objection",["intent"])
        cons_score      = Gauge("daegis_consensus_score","Consensus score",["intent"])
        _PRI_S = int(os.getenv("CONSENSUS_PRIOR_SUPPORT","10"))
        _PRI_O = int(os.getenv("CONSENSUS_PRIOR_OBJECTION","5"))
        _support, _objection = {}, {}
        for it in INTENTS:
            intents_total.labels(it).inc(0); intents_success.labels(it).inc(0)
            intents_failure.labels(it).inc(0); intents_hold.labels(it).inc(0)
            _support[it], _objection[it] = _PRI_S, _PRI_O
            cons_score.labels(it).set(_PRI_S/(_PRI_S+_PRI_O))
    except Exception as e:
        logger.warning(f"[PhaseV] Metrics init skipped: {e}")
        intents_total=intents_success=intents_failure=intents_hold=cons_support=cons_objection=cons_score=_NoopMetric()
        _support={it:0 for it in INTENTS}; _objection={it:0 for it in INTENTS}
else:
    logger.info("[PhaseV] Prometheus client not available — metrics dormant")
    intents_total=intents_success=intents_failure=intents_hold=cons_support=cons_objection=cons_score=_NoopMetric()
    _support={it:0 for it in INTENTS}; _objection={it:0 for it in INTENTS}
logger.info(f"[PhaseV] bootstrap: metrics active={_PROM_ACTIVE}, venv={os.getenv('VIRTUAL_ENV') or 'None'}, hot-probe ready")

def phasev_update(intent: str, status_code: int, latency_ms: float, entry: dict|None=None):
    """Append ledger.ethics/provider and update metrics (Oracle internal brain)."""
    try:
        it = (intent or "other").lower()
        it = it if it in INTENTS else "other"
        intents_total.labels(it).inc()
        verdict, rule_id, hint = "PASS","none",""
        if 500 <= int(status_code) < 600:
            intents_failure.labels(it).inc(); cons_objection.labels(it).inc(); _objection[it]+=1
        elif float(latency_ms) > _sla_ms(it):
            intents_hold.labels(it).inc(); cons_objection.labels(it).inc(); _objection[it]+=1
            verdict, rule_id, hint = "HOLD","sla_guard", f"latency_ms={latency_ms:.0f}>SLA={_sla_ms(it)}"
        elif 200 <= int(status_code) < 300:
            intents_success.labels(it).inc(); cons_support.labels(it).inc(); _support[it]+=1
        tot=_support[it]+_objection[it]
        if tot>0: cons_score.labels(it).set(_support[it]/tot)
        if isinstance(entry, dict):
            entry["ethics"]={"verdict":verdict,"rule_id":rule_id,"hint":hint}
            entry["provider"]={"name":"oracle-internal","model":"auto"}
    except Exception as e:
        logger.warning(f"[PhaseV] update skipped: {e}")
# --- end add ---
