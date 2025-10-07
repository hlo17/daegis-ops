import json
import os
import signal
import sys
import time

import paho.mqtt.client as mqtt

BROKER_HOST = os.getenv("MQTT_HOST", "127.0.0.1")
BROKER_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER")
MQTT_PASS = os.getenv("MQTT_PASS")

TOPIC_IN = os.getenv("HALU_TOPIC_IN", "daegis/halu/train/inbox")
TOPIC_OUT = os.getenv("HALU_TOPIC_OUT", "daegis/halu/train/outbox")
TOPIC_MET = os.getenv("HALU_TOPIC_METRICS", "daegis/halu/metrics")
MODE = os.getenv("HALU_MODE", "relay")

client = mqtt.Client(client_id="halu-relay", clean_session=False)
client.keepalive = 60
client.reconnect_delay_set(min_delay=1, max_delay=30)
client.will_set("daegis/relay/status", payload="offline", qos=1, retain=True)
if MQTT_USER:
    client.username_pw_set(MQTT_USER, MQTT_PASS)


def on_connect(c, u, flags, rc):
    print(f"[halu] connected rc={rc} host={BROKER_HOST}:{BROKER_PORT}")
    c.subscribe(TOPIC_IN, qos=1)
    c.publish(
        f"{TOPIC_MET}/status",
        json.dumps({"event": "started", "mode": MODE, "ts": time.time()}),
        qos=0,
    )


def on_message(c, u, msg):
    payload = msg.payload.decode("utf-8", errors="replace")
    print(f"[halu] IN  {msg.topic} {payload}")
    out = {"echo": payload, "ts": time.time()}
    c.publish(TOPIC_OUT, json.dumps(out), qos=1)


def on_disconnect(c, u, rc):
    print(f"[halu] disconnected rc={rc}")


def shutdown(*_):
    try:
        client.publish(
            f"{TOPIC_MET}/status", json.dumps({"event": "stopped", "ts": time.time()}), qos=0
        )
    finally:
        client.disconnect()
        sys.exit(0)


signal.signal(signal.SIGTERM, shutdown)
signal.signal(signal.SIGINT, shutdown)

client.on_connect = on_connect
client.on_message = on_message
client.on_disconnect = on_disconnect

client.connect(BROKER_HOST, BROKER_PORT, keepalive=30)
client.loop_forever()
