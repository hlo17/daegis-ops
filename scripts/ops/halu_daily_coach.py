#!/usr/bin/env python3
import os, json, time, re, datetime as dt
from pathlib import Path

HOME = str(Path.home())
REF  = os.path.join(HOME, "daegis/logs/reflection.jsonl")
HITL_DIR = os.path.join(HOME, "daegis/state")
HINT = os.path.join(HOME, "daegis/.coach_hint")

now = time.time()
def parse_ts(ts):
    try:
        if isinstance(ts, (int, float)): return float(ts)
        return dt.datetime.fromisoformat(str(ts).replace('Z', '+00:00')).timestamp()
    except:
        return None

# 直近24hの反省件数＆自己参照率
tot = hit = 0
last_ts = None
pat = re.compile(r'(昨日の私|前回|先日の決定|以前|過去|自己|振り返り|前述|この前)')

if os.path.exists(REF):
    with open(REF, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                obj = json.loads(line)
                # 反省だけを対象にする
                if obj.get("type") != "reflection":
                    continue
            except:
                continue
            ts = parse_ts(obj.get("ts") or obj.get("timestamp"))
            if ts:
                last_ts = max(last_ts or ts, ts)
                if ts >= now - 24*3600:
                    tot += 1
                    txt = (obj.get("message") or obj.get("body") or line)
                    if pat.search(txt): hit += 1

rate = (hit / max(1, tot)) if tot else 0.0
fresh_h = (now - (last_ts or 0))/3600 if last_ts else 1e9

# 今日のHITL承認フラグ
today = dt.datetime.utcfromtimestamp(now).strftime('%Y-%m-%d')
hitl_flag = os.path.join(HITL_DIR, f"hitl_approved_{today}")
hitl_ok = os.path.exists(hitl_flag)

# コーチメッセージ（優先順位つき）
if fresh_h > 6:
    msg = "🫁 呼吸が止まり気味 → まず 反省1件 を追加（emit_halu_reflection.sh）"
elif tot == 0:
    msg = "🌱 今日は反省ゼロ → 1件だけ書こう（自己参照語を1つ入れるとなお良し）"
elif rate < 0.30:
    msg = f"🪞 自己参照が薄い({rate:.0%}) → 昨日の決定/失敗を名指しで振り返る"
elif not hitl_ok:
    msg = "🔏 HITL未承認 → `~/daegis/scripts/hitl_approve_today.sh on` で承認"
else:
    msg = f"✅ 今日のループ完了 self-ref {rate:.0%} / fresh {max(0.0,fresh_h):.1f}h"

os.makedirs(os.path.dirname(HINT), exist_ok=True)
with open(HINT, 'w', encoding='utf-8') as f:
    f.write(msg + "\n")
print(msg)
