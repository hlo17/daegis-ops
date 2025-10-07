import os
import pathlib
import random

hard = pathlib.Path.home() / "daegis/records/hard-cases.txt"
corpus = os.environ.get("HALU_MIX_CORPUS", "")
mix_ratio = float(os.environ.get("HALU_HARD_RATIO", "0.2"))
if hard.exists() and corpus:
    with open(corpus, encoding="utf-8", errors="ignore") as f:
        base = [l.rstrip("\n") for l in f if l.strip()]
    with open(hard, encoding="utf-8", errors="ignore") as f:
        hardl = [l.rstrip("\n") for l in f if l.strip()]
    k = max(1, int(len(base) * mix_ratio))
    add = random.sample(hardl, min(k, len(hardl)))
    allc = base + add
    random.shuffle(allc)
    with open(corpus, "w", encoding="utf-8") as f:
        f.write("\n".join(allc))
