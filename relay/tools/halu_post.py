#!/usr/bin/env python3
import os, time, hmac, hashlib, urllib.request, urllib.parse, pathlib, sys
ENV=pathlib.Path("/home/f/daegis/relay/.env").read_text(encoding="utf-8").splitlines()
for ln in ENV:
    if "=" in ln and not ln.strip().startswith("#"):
        k,v=ln.split("=",1); os.environ.setdefault(k.strip(), v.strip())
team=os.environ["SLACK_TEAM_ID"]; sign=os.environ["SLACK_SIGNING_SECRET"]
text=" ".join(sys.argv[1:]).strip()
body=urllib.parse.urlencode({"token":"x","team_id":team,"text":text}).encode()
ts=str(int(time.time()))

# --- HALU_POST_RATE_GUARD: simple 60s throttle ---
from pathlib import Path as _P; import time as _t, os as _o
_stamp=_P(_o.path.expanduser("~/.cache/halu_post.last"))
try:
    if _stamp.exists():
        last=float(_stamp.read_text() or "0")
        if _t.time()-last < 60:
            print("429 too-many-requests (local throttle)")
            raise SystemExit(0)
finally:
    _stamp.parent.mkdir(parents=True, exist_ok=True)
    _stamp.write_text(str(_t.time()))
# --- /HALU_POST_RATE_GUARD ---

bases=f"v0:{ts}:{body.decode()}".encode()
sig="v0="+hmac.new(sign.encode(), bases, hashlib.sha256).hexdigest()
req=urllib.request.Request("https://halu-roundtable.daegis-phronesis.com/slack/halu", data=body, method="POST",
    headers={"Content-Type":"application/x-www-form-urlencoded",
             "X-Slack-Request-Timestamp":ts, "X-Slack-Signature":sig})
with urllib.request.urlopen(req, timeout=8) as r:
    print(r.status, r.read().decode())
