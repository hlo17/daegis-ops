from fastapi import FastAPI, Body
from roundtable_orchestrator import vote_all, select_coordinator
from compressor_arbitrator import compress_proposal, arbitrate
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import asyncio

# 内部モジュール（G1相当の最小実装 or 既存を import）
try:
    from app.roundtable_orchestrator import vote_all, select_coordinator
except Exception:
    # G1 未配置でも動く簡易モック
    async def vote_all(task_text: str, timeout_s: float = 30.0) -> List[Dict[str, Any]]:
        return [
            {"ai_name":"Grok4","scores":{"speed":8,"quality":9,"creativity":7,"confidence":9},"why":"mock"},
            {"ai_name":"ChatGPT","scores":{"speed":9,"quality":8,"creativity":10,"confidence":8},"why":"mock"}
        ]
    def select_coordinator(votes, historical_metrics, alpha: float = 0.6) -> Optional[str]:
        return votes[0]["ai_name"] if votes else None

app = FastAPI(title="Daegis Roundtable MVP")

class OrchestrateIn(BaseModel):
    task: str
    mode: Optional[str] = "mock"  # "mock" でモック投票

@app.get("/health")
async def health():
    return {"ok": True}

@app.post("/orchestrate")
async def orchestrate(_payload: dict):
    return {
        "arb_probe":"from_APP_PY",
        "note":"temporary fixed handler"
    }


# --- roundtable: ensure register at tail (idempotent) ---
try:
    from orchestrate_patch import register as _rt_reg_tail
    _rt_reg_tail(app)
    print("[rt] tail register fallback: ok")
except Exception as e:
    print("[rt] tail register fallback: failed ->", e)
try:
    import orchestrate_patch
    orchestrate_patch.register(app)
    print("[rt] app.py: orchestrate_patch.register() injected")
except Exception as e:
    print("[rt] app.py: orchestrate_patch register failed:", e)

# ===== Roundtable patch injection (robust) =====
try:
    import sys, os, traceback
    sys.path.insert(0, os.path.dirname(__file__))  # ensure local module path
    import orchestrate_patch
    if hasattr(orchestrate_patch, "register"):
        orchestrate_patch.register(app)
        print("[rt] app.py: orchestrate_patch.register() injected")
    else:
        print("[rt] app.py: orchestrate_patch has no register()")
except Exception as e:
    print("[rt] app.py: orchestrate_patch register failed:", e)
    traceback.print_exc()
# ===============================================
print("[rt] app.py: ENV SNAPSHOT: RT_DEBUG_ROUTES=", os.getenv("RT_DEBUG_ROUTES"))

# ===== Roundtable monkey patch (idempotent) =====
try:
    import sys, os, traceback
    sys.path.insert(0, os.path.dirname(__file__))
    import orchestrate_patch
    import _rt_monkey
    if _rt_monkey.install(orchestrate_patch):
        print("[rt] app.py: _rt_monkey installed (_orch_log wrapper active)")
    else:
        print("[rt] app.py: _rt_monkey skipped (no _orch_log)")
    # ここで register を呼ぶ
    if hasattr(orchestrate_patch, "register"):
        orchestrate_patch.register(app)
        print("[rt] app.py: orchestrate_patch.register() injected")
    else:
        print("[rt] app.py: orchestrate_patch has no register()")
except Exception as e:
    print("[rt] app.py: orchestrate_patch register failed:", e)
    traceback.print_exc()
# ===============================================

# ---- after orchestrate_patch.register(): wrap /orchestrate POST ----
try:
    import _rt_route_wrap
    if _rt_route_wrap.install(app):
        print("[rt] app.py: route_wrap installed (/orchestrate wrapped)")
    else:
        print("[rt] app.py: route_wrap skipped")
except Exception as e:
    print("[rt] app.py: route_wrap failed:", e)
# -------------------------------------------------------------------

# ---- ensure route wrap runs at startup (after all routes are registered) ----
try:
    from fastapi import FastAPI
    # app は既に上で作られている前提
    import _rt_route_wrap

    async def _wrap_on_startup():
        try:
            wrapped = _rt_route_wrap.install(app)
            print(f"[rt] app.py: route_wrap startup -> wrapped={wrapped}")
        except Exception as e:
            print("[rt] app.py: route_wrap startup failed:", e)

    # FastAPIのstartupイベントで実行（idempotent）
    app.add_event_handler("startup", _wrap_on_startup)
    print("[rt] app.py: route_wrap startup handler registered")
except Exception as e:
    print("[rt] app.py: failed to register startup route_wrap:", e)
# -----------------------------------------------------------------------------

# ---- install outermost ASGI logger middleware (must be last) ----
try:
    from _rt_mw_log import RTMiddleware
    app = RTMiddleware(app)
    print("[rt] app.py: RTMiddleware installed (outermost)")
except Exception as e:
    print("[rt] app.py: RTMiddleware install failed:", e)
# ----------------------------------------------------------------
