from fastapi import FastAPI
from fastapi.responses import Response
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    CollectorRegistry,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)

app = FastAPI()
reg = CollectorRegistry()

ROUTER_UP = Gauge("router_up", "1 if router is healthy", registry=reg)
REQS = Counter("rt_requests_total", "Requests", ["route", "source", "status"], registry=reg)
LAT = Histogram("rt_latency_ms", "Latency ms", registry=reg)
TOK_IN = Counter("rt_tokens_in_total", "Tokens in", ["model"], registry=reg)
TOK_OUT = Counter("rt_tokens_out_total", "Tokens out", ["model"], registry=reg)
COST = Counter("rt_cost_usd_total", "Cost USD", ["model"], registry=reg)
CACHE = Counter(
    "rt_cache_total", "Cache result", ["result"], registry=reg
)  # hit|miss|expired|write
DAYCAP = Gauge("rt_cost_day_exceeded", "1 if over day cap", registry=reg)


@app.get("/metrics")
def metrics():
    ROUTER_UP.set(1.0)
    return Response(content=generate_latest(reg), media_type=CONTENT_TYPE_LATEST)


@app.get("/chat")
def chat():
    REQS.labels(route="/chat", source="ping", status="200").inc()
    return {"ok": True, "msg": "Pong!"}
