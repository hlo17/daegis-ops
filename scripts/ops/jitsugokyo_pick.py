#!/usr/bin/env python3
import json, datetime as dt, os
canon=[json.loads(x) for x in open(os.path.expanduser('~/daegis/ethics/jitsugokyo/canon.jsonl'),encoding='utf-8')]
i = int(dt.datetime.utcnow().strftime('%j')) % len(canon)  # 1年で一巡以上
item = canon[i]
print(json.dumps({"t":dt.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'),"pick":item},ensure_ascii=False))
