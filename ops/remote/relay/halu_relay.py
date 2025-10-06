
# ---- de-dup (5min TTL) ----
import time
RECENT_EVENT_TTL = 300  # seconds
_recent = {}
def _now(): return int(time.time())
def _purge_recent():
    t = _now()
    for k, v in list(_recent.items()):
        if t - v > RECENT_EVENT_TTL:
            _recent.pop(k, None)
def _event_key(payload, event):
    # 優先: client_msg_id > event_id > event_ts
    return (
        event.get('client_msg_id')
        or payload.get('event_id')
        or event.get('event_ts')
    )
def is_duplicate(payload, event):
    _purge_recent()
    k = _event_key(payload, event)
    if not k:
        return False
    if k in _recent:
        return True
    _recent[k] = _now()
    return False
import os, sys, json, logging
from datetime import datetime, timezone
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from paho.mqtt import client as mqtt_client

# ---- env ----
SLACK_TOKEN  = os.getenv("SLACK_BOT_TOKEN", "")
SLACK_SECRET = os.getenv("SLACK_SIGNING_SECRET", "")
MQTT_HOST    = os.getenv("MQTT_HOST", "127.0.0.1")
MQTT_PORT    = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER    = os.getenv("MQTT_USER", "halu_relay")
MQTT_PASS    = os.getenv("MQTT_PASS", "")

# ---- logger (明示してstdoutへ) ----
log = logging.getLogger("halu-relay")
if not log.handlers:
    _h = logging.StreamHandler(sys.stdout)
    _h.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))
    log.addHandler(_h)
log.setLevel(logging.INFO)
log.propagate = False

# ---- signature verifier ----
try:
    from slack_sdk.signature import SignatureVerifier
    _verifier = SignatureVerifier(
        signing_secret=SLACK_SECRET,
        timestamp_skew_in_seconds=300,   # ±5分
    ) if SLACK_SECRET else None
except Exception:
    _verifier = None

log.info(f"[relay] boot: secret_len={len(SLACK_SECRET)} verifier={'yes' if _verifier else 'no'}")

# ---- FastAPI ----
app = FastAPI()

# ---- MQTT ----
mqttc = mqtt_client.Client()
try:
    if MQTT_USER or MQTT_PASS:
        mqttc.username_pw_set(MQTT_USER, MQTT_PASS)
    mqttc.connect(MQTT_HOST, MQTT_PORT, 60)
    mqttc.loop_start()
    log.info("[relay] MQTT connected")
except Exception as e:
    log.error(f"[relay] MQTT connect failed: {e}")

# ---- Health ----
@app.get("/health")
async def health():
    log.info("[relay] /health hit")
    return {"ok": True}

# ---- Slack Events ----
@app.post("/slack/events")
async def slack_events(request: Request):
    """
    返却規則:
      - URL検証: 200 + {"challenge": "..."}
      - 署名不正: 403 + {"status":"invalid signature"}
      - JSON不正: 400 + {"status":"invalid json"}
      - その他:   200 + {"status":"ok"}
    """
    log.info("[relay] /slack/events hit")
    try:
        body = await request.body()  # bytes を保持（検証に使う）
        # まず JSON 化を試みる（URL verification を優先）
        try:
            payload = json.loads(body.decode("utf-8"))
        except Exception as e:
            log.warning(f"[relay] invalid json: {e}")
            return JSONResponse({"status": "invalid json"}, status_code=400)

        if payload.get("type") == "url_verification" and "challenge" in payload:
            log.info("[relay] url_verification OK")
            return JSONResponse({"challenge": payload["challenge"]})

        # 署名検証
        if _verifier:
            headers_case = {
                "X-Slack-Signature": request.headers.get("x-slack-signature") or request.headers.get("X-Slack-Signature"),
                "X-Slack-Request-Timestamp": request.headers.get("x-slack-request-timestamp") or request.headers.get("X-Slack-Request-Timestamp"),
            }
            sig = headers_case.get("X-Slack-Signature")
            ts  = headers_case.get("X-Slack-Request-Timestamp")
            ok  = _verifier.is_valid_request(body, headers_case)
            log.info(f"[relay] verify sig={(sig or '')[:18]} ts={ts} ok={ok}")
            if not ok:
                return JSONResponse({"status":"invalid signature"}, status_code=403)
        else:
            log.warning("[relay] signing secret not set or verifier missing; skipping verification")

        # イベント本体ログ
        event = payload.get("event", {}) or {}
        etype = event.get("type")
        log.info(f"[relay] event.type={etype} event={json.dumps(event, ensure_ascii=False)}")

        # app_mention → MQTT 中継（必要に応じて 'message' も扱うならここに条件を追加）
        if etype == "app_mention":
            try:
                mqttc.publish("daegis/relay/in", json.dumps({
                    "origin":  "slack",
                    "type":    "slack_in",
                    "channel": event.get("channel"),
                    "user":    event.get("user"),
                    "text":    event.get("text"),
                    "ts":      event.get("ts") or datetime.now(timezone.utc).isoformat()
                }))
                log.info("[relay] published to MQTT daegis/relay/in")
            except Exception as e:
                log.error(f"[relay] publish failed: {e}")

        return JSONResponse({"status": "ok"})
    except Exception as e:
        # 500 を返すと Slack がリトライを繰り返すため、ログのみ残して 200 を返す
        log.exception(f"[relay] handler error: {e}")
        return JSONResponse({"status": "ok"})

# ---- dev run ----
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
