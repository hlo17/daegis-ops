#!/usr/bin/env python3
import os, hmac, hashlib, time, json, subprocess, datetime as dt
from pathlib import Path
from flask import Flask, request, abort, jsonify
from dotenv import load_dotenv
import subprocess as sp

HOME = str(Path.home())
LOG_DIR = os.path.join(HOME, "daegis/logs")
REF_JL  = os.path.join(LOG_DIR, "reflection.jsonl")
VIZ     = os.path.join(HOME, "daegis/www/halu_state_viz.py")
HITL    = os.path.join(HOME, "daegis/scripts/hitl_approve_today.sh")
JITSU   = os.path.join(HOME, "daegis/scripts/ops/emit_jitsugokyo_reflection.sh")

load_dotenv(os.path.join(HOME,"daegis/relay/.env"))
SIGN = os.getenv("SLACK_SIGNING_SECRET","")
TEAM = os.getenv("SLACK_TEAM_ID","")
DEBUG = os.getenv("DEBUG","false").lower()=="true"

os.makedirs(LOG_DIR, exist_ok=True)
app = Flask(__name__)

def ok(text):  # Slackへの即時返答(3秒以内)
    return jsonify({"response_type":"ephemeral","text": text})

def verify(req):
    if not SIGN: return False
    ts = req.headers.get("X-Slack-Request-Timestamp","0")
    if abs(time.time()-int(ts)) > 60*5: return False
    body = req.get_data(as_text=True)
    bases = f"v0:{ts}:{body}".encode()
    sig = "v0=" + hmac.new(SIGN.encode(), bases, hashlib.sha256).hexdigest()
    return hmac.compare_digest(sig, req.headers.get("X-Slack-Signature",""))

def fire(cmd):
    # 非同期起動（重い処理は返答後に回す）
    sp.Popen(cmd, shell=True, stdout=sp.DEVNULL, stderr=sp.DEVNULL)

@app.post("/slack/halu")
def inbox():
    if not verify(request): abort(403)
    if TEAM and request.form.get("team_id") != TEAM: abort(403)

    text = (request.form.get("text") or "").strip()
    # /halu help — コマンド一覧
    if text.strip() in ("help","?"):
        return ok("""使えるコマンド：
• reflect / approve / virtue / status
• say / propose / why
• kpi task:<id> chain:<name> tokens:<n> tool_min:<m> rating:<r> lead_s:<s> rework:<n>
• crispr <自由文>
• mrna title:<t> goal:<g> steps:<s>""")
    # --- /halu kpi / crispr / mrna --------------------------------
    # /halu kpi task:foo chain:std tokens:8000 tool_min:2 rating:4 lead_s:120 rework:0
    if text.startswith("kpi"):
        rest = text.split(None,1)[1] if " " in text else ""
        args = [tok.replace(":", "=") for tok in rest.split()]
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/kpi_log.py", *args],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "保存に失敗").strip()
        return ok("💰 KPI logged " + out[:160])

    # /halu crispr <自由文>
    if text.startswith("crispr"):
        q = text.split(None,1)[1] if " " in text else ""
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/halu_crispr.py", q],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "生成に失敗").strip()
        return ok("✂️ " + out[:180])

    # /halu mrna title:.. goal:.. steps:..
    if text.startswith("mrna"):
        rest = text.split(None,1)[1] if " " in text else ""
        toks = rest.split()
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/halu_mrna.py", *toks],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "生成に失敗").strip()
        return ok("🧬 " + out[:180])
    # ---------------------------------------------------------------
    # --- L3.5 guided expression: say / propose / why -----------------
    # /halu say  — 今日の気づき（短文）
    if text.startswith("say"):
        import subprocess, os
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/halu_reflect_lang.py","--mode","say"],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "生成に失敗").strip()
        fire(f"/usr/bin/env python3 /home/f/daegis/www/halu_state_viz.py")
        return ok("🗣 " + out[:180])

    # /halu propose — 小さな提案（HITL必須・実行なし）
    if text.startswith("propose"):
        import subprocess
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/halu_reflect_lang.py","--mode","propose"],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "生成に失敗").strip()
        return ok("📝 (提案・HITL必須) " + out[:180])

    # /halu why — 参照根拠を開示
    if text.startswith("why"):
        import subprocess
        try:
            out = sp.check_output(
                ["/usr/bin/env","python3",f"/home/f/daegis/scripts/ops/halu_reflect_lang.py","--mode","why"],
                text=True
            ).strip()
        except sp.CalledProcessError as e:
            out = (e.stdout or "生成に失敗").strip()
        return ok("🔎 " + out[:180])
    # ---------------------------------------------------------------
    user = request.form.get("user_name","?")
    if not text:
        return ok("使い方: `/halu reflect <一行>` | `/halu approve` | `/halu virtue` | `/halu status`")

    # /halu reflect 〜
    if text.startswith("reflect"):
        msg = text[len("reflect"):].strip() or "昨日の私の判断を振り返り、改善点を1つだけ記す。"
        iso = dt.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
        line = {"ts": iso, "type":"reflection", "message": msg, "source":"slack"}
        with open(REF_JL, "a", encoding="utf-8") as f:
            f.write(json.dumps(line, ensure_ascii=False) + "\\n")
        fire(f"/usr/bin/env python3 {VIZ}")
        return ok(f"🪞 反省を追加: `{msg[:40]}` … by {user}")

    # /halu approve
    if text.startswith("approve"):
        fire(f"{HITL} on && /usr/bin/env python3 {VIZ}")
        return ok("🔏 今日のHITLを承認しました")

    # /halu virtue
    if text.startswith("virtue"):
        fire(f"{JITSU} && /usr/bin/env python3 {VIZ}")
        return ok("📜 実語教の徳を1件記録しました")

    # /halu status
    if text.startswith("status"):
        # vizを走らせてから最小の数値を返す
        try:
            out = sp.check_output(
                f"/usr/bin/env python3 {VIZ} >/dev/null 2>&1; "
                "grep -Eo 'rate24=[0-9.]+' /tmp/halu_viz.log 2>/dev/null || true",
                shell=True, text=True, timeout=2)
        except Exception:
            out = ""
        return ok(f"📊 状態OK（可視化更新済）{out.strip()}")

    return ok("未知のコマンド。reflect / approve / virtue / status を使ってください。")

@app.get("/health")
def health():
    return "ok", 200
