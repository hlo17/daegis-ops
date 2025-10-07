import json
import os
import time
import uuid

import paho.mqtt.client as mqtt
from prometheus_client import Counter, Gauge, Histogram, start_http_server

MQTT_HOST = os.getenv("MQTT_HOST", "127.0.0.1")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER", "f")
MQTT_PASS = os.getenv("MQTT_PASS", "TestPw-123")
TOPIC_IN = os.getenv("HALU_TOPIC_IN", "daegis/obs/train/inbox")
TOPIC_OUT = os.getenv("HALU_TOPIC_OUT", "daegis/obs/train/outbox")
LOG_PATH = os.getenv("HALU_LOG", "/var/log/halu/flows.jsonl")
METRICS_PORT = int(os.getenv("METRICS_PORT", "9300"))

FLOW_LAT = Histogram(
    "halu_flow_latency_ms",
    "Flow latency (ms)",
    ["flow", "provider", "route", "model", "status"],
    buckets=(50, 100, 200, 400, 800, 1500, 3000, 6000, 12000),
)
FLOW_OK = Counter(
    "halu_flow_success_total", "Flow successes", ["flow", "provider", "route", "model"]
)
FLOW_ERR = Counter(
    "halu_flow_error_total", "Flow errors", ["flow", "provider", "route", "model", "error"]
)
FLOW_COST = Counter("halu_flow_cost_usd", "Flow cost (USD)", ["provider", "model"])
TOKENS = Counter("halu_flow_tokens_total", "Tokens", ["direction", "provider", "model"])
INFLIGHT = Gauge("halu_request_inflight", "In-flight reqs", ["flow"])

FLOW = "obs_echo"
PROVIDER = "mqtt"
ROUTE = "local"
MODEL = "echo-v0"

os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
start_http_server(METRICS_PORT)


def jlog(rec):
    with open(LOG_PATH, "a") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")


def now_iso():
    t = time.time()
    return time.strftime("%Y-%m-%dT%H:%M:%S.", time.gmtime()) + f"{int((t % 1) * 1000):03d}Z"


def on_connect(client, userdata, flags, rc, properties=None):
    client.subscribe(TOPIC_IN, qos=1)


def on_message(client, userdata, msg):
    start = time.time()
    INFLIGHT.labels(flow=FLOW).inc()
    status = "ok"
    err = ""
    tin = len(msg.payload)
    tout = 0
    cost = 0.0
    rid = str(uuid.uuid4())
    try:
        out = json.dumps({"echo": msg.payload.decode("utf-8", "ignore"), "ts": now_iso()})
        client.publish(TOPIC_OUT, out, qos=0, retain=False)
        tout = len(out.encode("utf-8"))
        FLOW_OK.labels(FLOW, PROVIDER, ROUTE, MODEL).inc()
    except Exception as e:
        status = "error"
        err = type(e).__name__
        FLOW_ERR.labels(FLOW, PROVIDER, ROUTE, MODEL, err).inc()
    finally:
        dur_ms = int((time.time() - start) * 1000)
        FLOW_LAT.labels(FLOW, PROVIDER, ROUTE, MODEL, status).observe(dur_ms)
        if tin > 0:
            TOKENS.labels("in", PROVIDER, MODEL).inc(tin)
        if tout > 0:
            TOKENS.labels("out", PROVIDER, MODEL).inc(tout)
        INFLIGHT.labels(flow=FLOW).dec()
        rec = {
            "ts": now_iso(),
            "flow": FLOW,
            "route": ROUTE,
            "provider": PROVIDER,
            "model": MODEL,
            "latency_ms": dur_ms,
            "tokens_in": tin,
            "tokens_out": tout,
            "cost_usd": cost,
            "status": status,
            "error_type": err,
            "user": "obs",
            "request_id": rid,
        }
        jlog(rec)


def main():
    client = mqtt.Client(
        client_id=f"halu-obs-{int(time.time())}", clean_session=True, protocol=mqtt.MQTTv311
    )
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(MQTT_HOST, MQTT_PORT, keepalive=30)
    client.loop_forever()


if __name__ == "__main__":
    main()
