import json
import os
import time
from datetime import UTC, datetime

import paho.mqtt.client as mqtt

MQTT_HOST = os.getenv("MQTT_HOST", "127.0.0.1")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER", "f")
MQTT_PASS = os.getenv("MQTT_PASS", "Temp-1234")
INBOX = os.getenv("HALU_INBOX", "daegis/halu/train/inbox")
OUTBOX = os.getenv("HALU_OUTBOX", "daegis/halu/train/outbox")
CLIENT_ID = os.getenv("HALU_CLIENT_ID", "halu-runner-pi")


def on_connect(client, userdata, flags, rc, props=None):
    client.subscribe(INBOX, qos=1)


def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8", errors="ignore")
    body = {
        "echo": payload,
        "ts": datetime.now(UTC).isoformat(),
    }
    client.publish(OUTBOX, json.dumps(body), qos=1)


def main():
    c = mqtt.Client(client_id=CLIENT_ID, protocol=mqtt.MQTTv5)
    c.username_pw_set(MQTT_USER, MQTT_PASS)
    c.on_connect = on_connect
    c.on_message = on_message
    c.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
    c.loop_start()
    try:
        while True:
            time.sleep(1)
    finally:
        c.loop_stop()


if __name__ == "__main__":
    main()
