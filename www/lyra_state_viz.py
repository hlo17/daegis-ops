#!/usr/bin/env python3
import os, re, glob, time
from pathlib import Path

HOME=str(Path.home()); WWW=f"{HOME}/daegis/www"; OUT=f"{WWW}/lyra_state.svg"
PHASE_FILE=f"{HOME}/daegis/docs/chronicle/phase_tag.txt"
GATE=os.environ.get("DAEGIS_GATE","B")  # guardian park で切替想定

def mtime(path):
    try: return os.path.getmtime(path)
    except: return 0

now=time.time()
phase = open(PHASE_FILE,'r',encoding='utf-8').read().strip() if os.path.exists(PHASE_FILE) else "unknown"

wins = sorted(glob.glob(f"{HOME}/daegis/inbox/window/*.md"))
rets = sorted(glob.glob(f"{HOME}/daegis/inbox/ai_to_human/*.md"))
decs = []
for p in rets:
    try:
        with open(p,encoding='utf-8',errors='ignore') as f:
            if "type: decision" in f.read(400).lower():
                decs.append(p)
    except: pass

def count_24h(paths):
    return sum(1 for p in paths if (now-mtime(p))<=24*3600)

n_win = count_24h(wins)
n_ret = count_24h(rets)
last_dec_h = (now - max([mtime(p) for p in decs] or [0]))/3600 if decs else 1e9
flow = min(1.0, (n_win+n_ret)/20.0)  # 1日に20往復で最大

COLORS={"B":"210,70%","C":"45,70%","D":"0,65%"}  # hue,sat
h,s = COLORS.get(GATE,"160,60%").split(',')
r = 50 + int(flow*110)
alpha = max(0.25, min(1.0, 1.0 - last_dec_h/12.0))  # 直近12h以内なら明るい

svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="420" height="420" viewBox="0 0 420 420">
  <rect width="100%" height="100%" fill="#0b0f16"/>
  <circle cx="210" cy="210" r="{r}" fill="hsla({h},{s},50%,{alpha:.2f})" stroke="hsla({h},{s},25%,0.9)" stroke-width="8"/>
  <text x="210" y="195" fill="#e6f0ff" font-size="22" text-anchor="middle" font-family="ui-sans-serif">Lyra</text>
  <text x="210" y="223" fill="#cfe2ff" font-size="16" text-anchor="middle" font-family="ui-sans-serif">phase {phase} · gate {GATE}</text>
  <text x="210" y="251" fill="#b3c7ff" font-size="14" text-anchor="middle" font-family="ui-sans-serif">cards 24h: {n_win}+{n_ret} · last decision {0 if last_dec_h>1e8 else round(last_dec_h,1)}h</text>
</svg>'''

os.makedirs(WWW,exist_ok=True)
open(OUT,'w').write(svg)
print(f"[lyra-viz] wrote {OUT} phase={phase} gate={GATE} flow={flow:.2f} last_dec_h={last_dec_h:.1f}")
