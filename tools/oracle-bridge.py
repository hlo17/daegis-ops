#!/usr/bin/env python3
import json
import os
import random
import subprocess
import sys
from datetime import UTC, datetime

H = os.getenv("MQTT_HOST", "127.0.0.1")
P = str(os.getenv("MQTT_PORT", "1883"))
U = os.getenv("MQTT_USER", "bot_oracle")
PW = os.getenv("MQTT_PASS", "")
ASK = os.getenv("ASK_TOPIC", "daegis/factory/bot_oracle/ask")
ANS = os.getenv("ANSWER_TOPIC", "daegis/events/bot_oracle/answer")
NOT = os.getenv("NOTIFY_TOPIC", "daegis/notify/oracle")


def mpub(topic: str, msg: str):
    args = ["mosquitto_pub", "-h", H, "-p", P, "-u", U, "-P", PW, "-t", topic, "-m", msg]
    subprocess.run(args, check=False)


def heuristic(prompt: str):
    p = (prompt or "").lower()
    # verdict / eval キーワードで簡易評価モード
    if any(k in p for k in ["eval", "verdict", "判定", "評価"]):
        verdicts = ["✅ 妥当", "⚠️ 要確認", "❌ 再検討"]
        v = random.choice(verdicts)
        reasons_pool = ["妥当", "網羅的", "安全", "根拠不足", "視点欠落"]
        reasons = random.sample(reasons_pool, 3)
        return {"mode": "eval", "verdict": v, "reasons": reasons}

    # それ以外は簡易レコメンド
    if any(k in p for k in ["release", "deploy", "rollout"]):
        rec = [
            "影響範囲と依存（DB/外部API/顧客接点）を列挙",
            "ロールバック条件と指標（メトリクス/エラー率/ログ）を定義",
            "canary→段階展開→全量のゲートを明示",
        ]
        return {"recommendation": rec}

    if any(k in p for k in ["pr", "diff", "pull request"]):
        rec = [
            "目的→挙動変化→互換性（breaking有無）",
            "リスク/代案/テスト観点を整理",
            "運用: 監視項目と失敗時の処置",
        ]
        return {"recommendation": rec}

    return {"recommendation": ["要点3行", "懸念1行", "次アクション1行"]}


print("[oracle-bridge] starting...", flush=True)

# ASK を購読（-v で「topic<space>payload」）
sub = subprocess.Popen(
    ["mosquitto_sub", "-h", H, "-p", P, "-u", U, "-P", PW, "-t", f"{ASK}/#", "-v"],
    stdout=subprocess.PIPE,
    text=True,
)

for line in sub.stdout:
    try:
        topic, payload = line.split(" ", 1)
        payload = payload.strip()

        rid = str(int(datetime.now().timestamp()))
        prompt = payload
        try:
            j = json.loads(payload)
            prompt = j.get("prompt", prompt)
            rid = j.get("id", rid)
        except json.JSONDecodeError:
            pass

        result = heuristic(prompt)
        resp = {
            "id": rid,
            "ts": datetime.now(UTC).isoformat(),
            "agent": "oracle",
            **result,
            "confidence": 0.66,
            "notes": {"mode": result.get("mode", "recommendation-v1")},
        }

        # MQTTへ返答
        mpub(ANS, json.dumps(resp, ensure_ascii=False))
        if result.get("mode") == "eval":
            mpub(NOT, f"[oracle] {result['verdict']}")
        else:
            txt = " / ".join(result.get("recommendation", []))[:180]
            mpub(NOT, f"[oracle] {txt}")

        print(f"[oracle-bridge] answered id={rid}", flush=True)

    except Exception as e:
        mpub(NOT, f"[oracle] error: {type(e).__name__}")
        print(f"[oracle-bridge] error: {e}", file=sys.stderr, flush=True)
