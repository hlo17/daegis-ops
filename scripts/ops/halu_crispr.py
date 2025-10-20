#!/usr/bin/env python3
import sys, time, json
q = " ".join(sys.argv[1:]).strip()
now=time.strftime("%Y-%m-%dT%H:%M:%SZ", __import__("time").gmtime())
msg = f"CRISPR前処理：何を切る？何を残す？仮説は？｜題意: {q[:80]}"
print(msg)
