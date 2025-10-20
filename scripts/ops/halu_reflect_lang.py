#!/usr/bin/env python3
import os, re, json, time, argparse, hashlib
from pathlib import Path

HOME = str(Path.home())
REF   = f"{HOME}/daegis/logs/reflection.jsonl"
VIRT  = f"{HOME}/daegis/logs/virtue.jsonl"
ADV_DIR = f"{HOME}/daegis/logs/advice"
STATE   = f"{HOME}/daegis/state"; os.makedirs(STATE, exist_ok=True)
os.makedirs(ADV_DIR, exist_ok=True)

now = time.time()
cutoff = now - 24*3600

def load_jsonl(path):
    if not os.path.exists(path): return []
    out=[]
    with open(path,'r',encoding='utf-8') as f:
        for ln in f:
            try: obj=json.loads(ln)
            except: continue
            ts = obj.get("ts") or obj.get("timestamp")
            try:
                t = time.mktime(time.strptime(str(ts).replace('Z',''), "%Y-%m-%dT%H:%M:%S"))
            except:
                t = None
            if t and t>=cutoff:
                obj["_t"]=t
                out.append(obj)
    return out

def sanitize(s:str)->str:
    s=re.sub(r'[\w\.-]+@[\w\.-]+','<email>',s)
    s=re.sub(r'\bhttps?://\S+','<url>',s)
    s=re.sub(r'\b\d{2,}[-\s]?\d+\b','<num>',s)
    return s

def keyphrases(txt:str):
    keys=[]
    for pat in [r'失敗|誤り|課題', r'改善|見直し|修正', r'次(は|に)|明日|翌日|試す']:
        if re.search(pat, txt): keys.append(pat)
    words=re.findall(r'[A-Za-z0-9_#@/+.-]{3,}', txt)
    return list(dict.fromkeys(words))[:6], keys

def last_virtue():
    xs=load_jsonl(VIRT)
    if not xs: return None
    xs=sorted(xs,key=lambda x:x["_t"])
    return xs[-1].get("virtue") or xs[-1].get("value")

def rate_limit(key:str, seconds:int)->bool:
    p=Path(f"{STATE}/ratelimit_{hashlib.sha1(key.encode()).hexdigest()}")
    try: t=float(p.read_text())
    except: t=0.0
    if now - t < seconds: return False
    p.write_text(str(now)); return True

def daily_cap(name:str, limit:int)->bool:
    day=time.strftime("%Y-%m-%d", time.gmtime())
    p=Path(f"{STATE}/cap_{name}_{day}")
    n=int(p.read_text()) if p.exists() else 0
    if n>=limit: return False
    p.write_text(str(n+1)); return True

def emit(mode:str):
    refs=sorted(load_jsonl(REF), key=lambda x:x["_t"])
    if not refs:
        print("（直近24hの反省ログがありません）"); return 0
    tail=refs[-5:]
    crumbs=[]
    for r in tail:
        msg=sanitize(r.get("message") or r.get("body") or "")
        words,keys=keyphrases(msg)
        crumbs.append({"ts":r.get("ts"),"msg":msg,"words":words,"keys":keys})
    virtue=last_virtue() or "礼"
    ts = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    if mode=="say":
        if not rate_limit("say", 60):
            print("（レート制限中：1分あけて再実行）"); return 2
        focus=", ".join(list({w for c in crumbs for w in c["words"]})[:3]) or "小さな改良"
        msg=f"今日の気づき：昨日の自分に重ねて、{focus} を丁寧に扱う。徳：{virtue}"
        rec={"ts":ts,"mode":"say","virtue":virtue,"focus":focus,"source":crumbs}
        with open(f"{ADV_DIR}/say.jsonl","a",encoding="utf-8") as f: f.write(json.dumps(rec,ensure_ascii=False)+"\n")
        print(msg); return 0

    if mode=="propose":
        if not daily_cap("propose", 3):
            print("（本日の提案上限に到達）"); return 2
        focus=(crumbs[-1]["words"][:1] or ["一項目"])[0]
        plan=f"明日は『{focus}』の手順を1回だけ試す。失敗なら即ロールバック。"
        msg=f"小さな提案：{plan}（徳：{virtue}）"
        rec={"ts":ts,"mode":"propose","virtue":virtue,"plan":plan,"source":crumbs}
        with open(f"{ADV_DIR}/propose.jsonl","a",encoding="utf-8") as f: f.write(json.dumps(rec,ensure_ascii=False)+"\n")
        print(msg); return 0

    if mode=="why":
        ids=[c["ts"] for c in crumbs]
        msg=f"根拠：reflection {ids}／徳：{virtue}"
        rec={"ts":ts,"mode":"why","virtue":virtue,"refs":ids}
        with open(f"{ADV_DIR}/why.jsonl","a",encoding="utf-8") as f: f.write(json.dumps(rec,ensure_ascii=False)+"\n")
        print(msg); return 0

    print("usage: --mode say|propose|why"); return 1

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--mode",required=True,choices=["say","propose","why"])
    raise SystemExit(emit(ap.parse_args().mode))
