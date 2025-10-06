#!/usr/bin/env python3
import argparse
import json
import os
import time
import uuid
import statistics
import paho.mqtt.client as mqtt


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--host", default=os.getenv("MQTT_HOST", "mosquitto"))
    p.add_argument("--port", type=int, default=int(os.getenv("MQTT_PORT", "1883")))
    p.add_argument("--ask", default=os.getenv("ASK", "daegis/ask/halu"))
    p.add_argument("--reply", default=os.getenv("REPLY", "daegis/reply/halu"))
    p.add_argument("--n", type=int, default=50)
    p.add_argument("--timeout", type=float, default=5.0)
    p.add_argument("--p95_ms", type=float, default=3000.0)
    p.add_argument("--fail_rate", type=float, default=0.02)
    return p.parse_args()


def main():
    a = parse_args()
    client = mqtt.Client(protocol=mqtt.MQTTv5)
    results = []
    awaited = {"cid": None, "expect": None, "t0": None}
    got = {"ok": False, "t": 0.0}

    def on_message(c, u, msg):
        try:
            d = json.loads(msg.payload.decode("utf-8"))
        except Exception:
            return
        if awaited["cid"] and d.get("cid") == awaited["cid"]:
            got["ok"] = True
            got["t"] = time.perf_counter()
        elif awaited["expect"] and d.get("answer", "").startswith(awaited["expect"]):
            got["ok"] = True
            got["t"] = time.perf_counter()

    client.on_message = on_message
    client.connect(a.host, a.port, keepalive=30)
    client.subscribe(a.reply)
    client.loop_start()

    fail = 0
    for _ in range(a.n):
        cid = uuid.uuid4().hex[:8]
        prompt = f"probe:{cid}"
        expect_prefix = f"ack: {prompt}"
        awaited.update({"cid": cid, "expect": expect_prefix, "t0": time.perf_counter()})
        got["ok"] = False

        client.publish(a.ask, json.dumps({"prompt": prompt, "cid": cid}), qos=0)
        deadline = time.perf_counter() + a.timeout
        while time.perf_counter() < deadline and not got["ok"]:
            time.sleep(0.01)

        if got["ok"]:
            results.append((got["t"] - awaited["t0"]) * 1000.0)
        else:
            fail += 1

    client.loop_stop()
    total = a.n
    ok = total - fail
    fail_rate = fail / total if total else 0.0
    p95 = statistics.quantiles(results, n=100)[94] if results else float("inf")

    summary = {
        "total": total,
        "ok": ok,
        "fail": fail,
        "fail_rate": round(fail_rate, 4),
        "p95_ms": None if p95 == float("inf") else round(p95, 2),
    }
    print(json.dumps(summary, ensure_ascii=False))
    if fail_rate > a.fail_rate or (p95 != float("inf") and p95 > a.p95_ms):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
