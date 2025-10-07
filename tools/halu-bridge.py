#!/usr/bin/env python3
import json
import os
import shlex
import subprocess
from datetime import UTC, datetime

H = os.getenv("MQTT_HOST", "127.0.0.1")
P = os.getenv("MQTT_PORT", "1883")
U = os.getenv("MQTT_USER", "halu")
PW = os.getenv("MQTT_PASS", "")
ASK = os.getenv("ASK_TOPIC", "daegis/factory/halu/ask")
ANS = os.getenv("ANSWER_TOPIC", "daegis/events/halu/answer")
NOT = os.getenv("NOTIFY_TOPIC", "daegis/notify/halu")


def pub(t, m):
    subprocess.run(
        shlex.split(f"mosquitto_pub -h {H} -p {P} -u {U} -P {PW} -t '{t}' -m '{m}'"), check=False
    )


def rec(p):
    p = (p or "").lower()
    if any(k in p for k in ["diff", "pr", "pull request"]):
        return [
            "差分の目的→影響範囲→互換性",
            "レビュー: 動作変更/リスク/ロールバック",
            "検証: 再現→テスト→メトリクス/ログ",
        ]
    return ["要点3行", "リスク/代替1行", "次アクション1行"]


p = subprocess.Popen(
    shlex.split(f"mosquitto_sub -h {H} -p {P} -u {U} -P {PW} -t '{ASK}/#' -v"),
    stdout=subprocess.PIPE,
    text=True,
)
for line in p.stdout:
    topic, payload = line.split(" ", 1)
    rid = str(int(datetime.now().timestamp()))
    q = payload.strip()
    try:
        j = json.loads(q)
        q = j.get("prompt", q)
        rid = j.get("id", rid)
    except json.JSONDecodeError:
        pass
    pol = rec(q)
    resp = {
        "id": rid,
        "ts": datetime.now(UTC).isoformat(),
        "agent": "halu",
        "policy": pol,
        "confidence": 0.62,
        "notes": {"mode": "heuristic-v0"},
    }
    pub(ANS, json.dumps(resp, ensure_ascii=False))
    pub(NOT, "[halu] " + " / ".join(pol)[:160])
