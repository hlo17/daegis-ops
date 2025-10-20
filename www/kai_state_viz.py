#!/usr/bin/env python3
import os, json, time
from pathlib import Path

HOME=str(Path.home())
WWW=f"{HOME}/daegis/www"
OUT=f"{WWW}/kai_state.svg"
LOG=f"{HOME}/daegis/logs/factory_ops.jsonl"  # Kaiの作業ログ（なければ0件扱い）

now=time.time()
total=errors=0
last_ts=0

def parse_ts(ts):
    if not ts: return None
    if isinstance(ts,(int,float)): return float(ts)
    import datetime as _dt
    try:
        return _dt.datetime.fromisoformat(str(ts).replace('Z','+00:00')).timestamp()
    except Exception:
        return None

if os.path.exists(LOG):
    with open(LOG,'r',encoding='utf-8') as f:
        for line in f:
            try: obj=json.loads(line)
            except: continue
            ts = parse_ts(obj.get("ts") or obj.get("timestamp"))
            if ts: last_ts = max(last_ts, ts)
            if ts and now-ts < 24*3600:
                total += 1
                if (obj.get("status") or obj.get("level")) in ("error","ERR","ERROR"):
                    errors += 1

flow      = min(1.0, total/20.0)                 # 24h 20件で最大サイズ想定
err_rate  = (errors/max(1,total)) if total else 0
fresh_h   = (now-last_ts)/3600 if last_ts else 1e9

# 半径=処理量, 明度=鮮度（新しいほど明るい）, 色=Kaiらしい青
r     = 50 + int(flow*110)
alpha = max(0.25, min(1.0, 1.0 - fresh_h/6.0))
fill  = f"rgba(100,180,255,{alpha:.2f})"
stroke= "rgba(50,100,200,0.85)"

svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="420" height="420" viewBox="0 0 420 420">
  <rect width="100%" height="100%" fill="#0b1116"/>
  <circle cx="210" cy="210" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="8"/>
  <text x="210" y="188" fill="#cfe6ff" font-size="40" text-anchor="middle" font-family="ui-serif">Kai</text>
  <text x="210" y="230" fill="#c5dcff" font-size="20" text-anchor="middle" font-family="ui-sans-serif">
    ops {total} · err {err_rate:.0%} · fresh {0 if fresh_h>9e8 else fresh_h:.1f}h
  </text>
</svg>'''
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT,'w',encoding='utf-8') as f: f.write(svg)
print(f"[kai-viz] wrote {OUT} ops={total} err={err_rate:.2f} fresh_h={fresh_h:.1f}")
