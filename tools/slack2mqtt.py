#!/usr/bin/env python3
import json
import os
import shlex
import subprocess
import threading
import time
import uuid

import requests
from fastapi import FastAPI, Form
from fastapi.responses import PlainTextResponse

MQTT_HOST = os.getenv("MQTT_HOST", "127.0.0.1")
MQTT_PORT = os.getenv("MQTT_PORT", "1883")
USER = os.getenv("MQTT_USER", "f")
PASS = os.getenv("MQTT_PASS", "nknm")

TOPIC_HALU_ASK = "daegis/factory/halu/ask"
TOPIC_HALU_ANSWER = "daegis/events/halu/answer"
TOPIC_ORA_ASK = "daegis/factory/bot_oracle/ask"
TOPIC_ORA_ANSWER = "daegis/events/bot_oracle/answer"


def mpub(topic, msg):
    cmd = f"mosquitto_pub -h {MQTT_HOST} -p {MQTT_PORT} -u {USER} -P {PASS} -t '{topic}' -m '{msg}'"
    subprocess.run(shlex.split(cmd), check=False)


def collect_once(topic, rid, timeout=10):
    cmd = f"timeout {timeout}s mosquitto_sub -h {MQTT_HOST} -p {MQTT_PORT} -u {USER} -P {PASS} -t '{topic}' -F '%p'"
    try:
        out = subprocess.check_output(cmd, shell=True, text=True)
        for line in out.splitlines():
            try:
                j = json.loads(line)
                if j.get("id") == rid:
                    return j
            except Exception:
                pass
    except subprocess.CalledProcessError:
        pass
    return None


app = FastAPI()


def handle(text: str, kind: str, response_url: str):
    rid = f"{int(time.time())}-{uuid.uuid4().hex[:6]}"
    if kind == "halu":
        mpub(TOPIC_HALU_ASK, json.dumps({"id": rid, "prompt": text}, ensure_ascii=False))

        def worker():
            j = collect_once(TOPIC_HALU_ANSWER, rid, timeout=10)
            msg = " / ".join(j.get("policy", [])) if j else "（タイムアウト）"
            requests.post(
                response_url, json={"response_type": "in_channel", "text": f"[halu] {msg}"}
            )

        threading.Thread(target=worker, daemon=True).start()
    else:
        mpub(TOPIC_ORA_ASK, json.dumps({"id": rid, "prompt": text}, ensure_ascii=False))

        def worker():
            j = collect_once(TOPIC_ORA_ANSWER, rid, timeout=10)
            if not j:
                msg = "（タイムアウト）"
            elif j.get("mode") == "eval":
                msg = f"{j.get('verdict', '')} " + "、".join(j.get("reasons", []))
            else:
                msg = " / ".join(j.get("recommendation", []))
            requests.post(
                response_url, json={"response_type": "in_channel", "text": f"[oracle] {msg}"}
            )

        threading.Thread(target=worker, daemon=True).start()


@app.post("/slash/halu")
async def slash_halu(text: str = Form(""), response_url: str = Form("")):
    handle(text.strip(), "halu", response_url)
    return PlainTextResponse("Haluに転送しました。（数秒後に結果を投稿します）")


@app.post("/slash/oracle")
async def slash_oracle(text: str = Form(""), response_url: str = Form("")):
    handle(text.strip(), "oracle", response_url)
    return PlainTextResponse("Oracleに転送しました。（数秒後に結果を投稿します）")


@app.post("/dev/null")
async def devnull():
    return PlainTextResponse("ok")
