#!/usr/bin/env python3
import sys, shlex
pairs={}
for tok in sys.argv[1:]:
    if ":" in tok:
        k,v = tok.split(":",1)
        pairs[k]=v
title=pairs.get("title","untitled")
goal=pairs.get("goal","")
steps=pairs.get("steps","")
print(f"mRNA: title={title} | goal={goal} | steps={steps[:60]}")
