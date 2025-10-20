#!/usr/bin/env python3
import os, json, time, re, datetime as dt
from pathlib import Path

HOME = str(Path.home())
LOG  = os.path.join(HOME, "daegis/logs/reflection.jsonl")
OUT  = os.path.join(HOME, "daegis/www/halu_state.svg")

# 徳 → 色相（deg）: 五常＋拡張
VIRT_HUE = {
  "仁":160, "義":20,  "礼":200, "智":45,  "信":210,
  "忠":330, "孝":120, "廉":180, "恥":300, "学":55, "勤":30, "慎":210
}

now = time.time()
def parse_ts(ts):
    try:
        if isinstance(ts,(int,float)): return float(ts)
        return dt.datetime.fromisoformat(str(ts).replace('Z','+00:00')).timestamp()
    except: return None

# 自己参照ワード（控えめ拡張）
pat = re.compile(r'(昨日の私|前回の[hH]alu|先日の決定|以前|過去|自己|振り返り|かつて|前述|この前|上で述べた)')

last_ts = None
last_virt = None
hit24 = tot24 = 0
hit72 = tot72 = 0

if os.path.exists(LOG):
    with open(LOG, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                obj = json.loads(line)
            except:
                continue
            ts = parse_ts(obj.get("ts") or obj.get("timestamp"))
            if not ts: 
                continue
            last_ts = max(last_ts or ts, ts)
            # virtue ラベルを保持（最後に見えたものを採用）
            if isinstance(obj, dict) and 'virtue' in obj:
                last_virt = obj.get('virtue')
            # 本文テキスト優先で自己参照検知
            txt = (obj.get("message") or obj.get("body") or line)
            if ts >= now - 24*3600:
                tot24 += 1
                if pat.search(txt): hit24 += 1
            if ts >= now - 72*3600:
                tot72 += 1
                if pat.search(txt): hit72 += 1

rate24 = (hit24 / max(tot24,1)) if tot24 else 0.0
fresh_hours = (now - last_ts)/3600 if last_ts else 1e9

# ステージ推定（暫定ルール）
if fresh_hours > 6:
    stage = "L1"
elif tot24 == 0:
    stage = "L2"
elif rate24 < 0.3:
    stage = "L3"
elif rate24 < 0.6:
    stage = "L4"
else:
    stage = "L5"

# SVG：大きさ=自己参照率、明るさ=鮮度、色相=徳（未指定は「仁」系）
r = 40 + int(max(0,min(1,rate24))*120)
alpha = max(0.25, min(1.0, 1.0 - fresh_hours/6.0))  # 6hで下限へ
h = VIRT_HUE.get(last_virt, 160)                    # 既定=仁(緑域)
fill   = f"hsla({h}, 60%, 50%, {alpha:.2f})"
stroke = f"hsla({h}, 50%, 25%, 0.85)"

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="820" height="620" viewBox="0 0 820 620">
  <rect width="100%" height="100%" fill="#0c1512"/>
  <circle cx="410" cy="420" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="14"/>
  <text x="410" y="330" fill="#dcffe9" font-family="ui-serif, Georgia, serif" font-size="88" text-anchor="middle">Halu</text>
  <text x="410" y="390" fill="#b2f2d6" font-family="ui-serif, Georgia, serif" font-size="46" text-anchor="middle">stage {stage} · virtue {last_virt or '—'}</text>
  <text x="410" y="520" fill="#8de0c0" font-family="ui-serif, Georgia, serif" font-size="42" text-anchor="middle">self-ref {rate24:.0%} · fresh {max(0.0,fresh_hours):.1f}h</text>
</svg>'''

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(svg)

print(f"[viz] wrote {OUT}  stage={stage}  fresh_hours={fresh_hours:.1f}  rate24={rate24:.2f}  virtue={last_virt or '-'}")
