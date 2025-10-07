import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

import paho.mqtt.client as mqtt
from prometheus_client import CONTENT_TYPE_LATEST, CollectorRegistry, Gauge, generate_latest

HOST = os.getenv("MQTT_HOST", "127.0.0.1")
PORT = int(os.getenv("MQTT_PORT", "1883"))
USER = os.getenv("MQTT_USER", "")
PASS = os.getenv("MQTT_PASS", "")
TOPIC = os.getenv("MQTT_TOPIC", "daegis/halu/metrics/status")
HTTP_PORT = int(os.getenv("HTTP_PORT", "9107"))

reg = CollectorRegistry()
HB_TS = Gauge("halu_last_heartbeat_ts", "Unix ts of last heartbeat", registry=reg)
HB_AGE = Gauge("halu_last_heartbeat_age_seconds", "Age of last heartbeat", registry=reg)
SUB_OK = Gauge("halu_heartbeat_subscribed", "1 if exporter subscribed OK", registry=reg)


def on_connect(client, userdata, flags, rc, properties=None):
    ok = rc == 0
    try:
        client.subscribe(TOPIC)
        SUB_OK.set(1 if ok else 0)
        print(f"[hb-exporter] connected rc={rc}; subscribed to {TOPIC}", flush=True)
    except Exception as e:
        SUB_OK.set(0)
        print(f"[hb-exporter] subscribe failed: {e}", file=sys.stderr, flush=True)


def on_message(_c, _u, msg):
    HB_TS.set(time.time())


def age_loop():
    while True:
        ts = HB_TS._value.get()
        if ts > 0:
            HB_AGE.set(max(0, time.time() - ts))
        time.sleep(1)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/metrics":
            self.send_response(404)
            self.end_headers()
            return
        out = generate_latest(reg)
        self.send_response(200)
        self.send_header("Content-Type", CONTENT_TYPE_LATEST)
        self.send_header("Content-Length", str(len(out)))
        self.end_headers()
        self.wfile.write(out)


def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    if USER:
        client.username_pw_set(USER, PASS)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect_async(HOST, PORT, keepalive=60)
    client.loop_start()
    threading.Thread(target=age_loop, daemon=True).start()
    print(f"[hb-exporter] serving /metrics on :{HTTP_PORT}", flush=True)
    HTTPServer(("0.0.0.0", HTTP_PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
