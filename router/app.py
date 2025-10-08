# DAEGIS ROUTER · FASTAPI
# GOAL: /chat は最小差分で改良。Prometheusメトリクス必須。
# RULES:
# - cache: 60s TTL (user+contentキー)
# - timeout: 3.0s（外部IO） TimeoutError→HTTP 504
# - metrics: rt_requests_total / rt_latency_ms / rt_cache_{hits,misses}_total
# - tests: pytest名は <機能>_<期待> (例: cache_hit_is_faster)

# --- paste-guard (内蔵自己診断) --------------------------------------------
# ヘッダ/フッタの哨戒文字が欠けていたら、貼り付け崩れとして即時終了
_PG_HEADER = "# DAEGIS ROUTER · FASTAPI"
_PG_FOOTER = "# [PASTE-GUARD EOF v1] 5c6da0d0"

def _paste_guard():
    import sys, pathlib
    p = pathlib.Path(__file__)
    try:
        src = p.read_text(encoding="utf-8", errors="strict")
    except Exception as e:
        sys.stderr.write(f"[paste-guard] cannot read {p}: {e}\n")
        sys.exit(2)

    errs = []
    if not src.splitlines()[0].startswith(_PG_HEADER):
        errs.append("header marker missing (first line broken)")
    if _PG_FOOTER not in src:
        errs.append("footer marker missing (EOF truncated or extra junk after EOF)")
    if "cat > router/app.py <<'PY'" in src:
        errs.append("heredoc boundary leaked into file (shell pasted incorrectly)")

    if errs:
        sys.stderr.write("[paste-guard] file appears corrupted:\n - " + "\n - ".join(errs) + "\n")
        sys.stderr.write("Hint: 末尾は単独行の「PY」で閉じてください（その後に文字を置かない）。\n")
        sys.exit(2)

_paste_guard()
# ---------------------------------------------------------------------------

import time
import hashlib
import asyncio
from typing import Dict, Tuple

from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI()

class ChatReq(BaseModel):
    user: str
    content: str
    source: str | None = None

# 60秒TTLのプロセス内キャッシュ
_CACHE_TTL = 60.0
_cache: Dict[str, Tuple[float, dict]] = {}

# メトリクス
rt_requests_total   = Counter("rt_requests_total",   "Total requests")
rt_cache_hits_total = Counter("rt_cache_hits_total", "Cache hits")
rt_cache_misses_total = Counter("rt_cache_misses_total", "Cache misses")
rt_latency_ms       = Histogram("rt_latency_ms",     "Request latency (ms)")

def _cache_key(req: ChatReq) -> str:
    return hashlib.md5(f"{req.user}|{req.content}".encode()).hexdigest()

async def _do_handle(req: ChatReq) -> dict:
    # 実処理のダミー（必要に応じて本処理へ置換）
    await asyncio.sleep(0.2)
    return {"ok": True, "message": f"echo:{req.content}"}

@app.post("/chat")
async def chat(req: ChatReq, response: Response):
    rt_requests_total.inc()
    start = time.perf_counter()
    try:
        key = _cache_key(req)
        now = time.time()

        if key in _cache:
            ts, val = _cache[key]
            if now - ts <= _CACHE_TTL:
                rt_cache_hits_total.inc()
                response.headers["X-Cache"] = "HIT"
                return val
            else:
                _cache.pop(key, None)

        rt_cache_misses_total.inc()
        response.headers["X-Cache"] = "MISS"
        val = await asyncio.wait_for(_do_handle(req), timeout=3.0)
        _cache[key] = (now, val)
        return val
    except asyncio.TimeoutError:
        raise HTTPException(status_code=504, detail="upstream timeout (>3s)")
    finally:
        rt_latency_ms.observe((time.perf_counter() - start) * 1000.0)

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

# [PASTE-GUARD EOF v1] 5c6da0d0
