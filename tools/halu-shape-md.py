import hashlib
import json
import os
import pathlib
import re
from datetime import datetime

SRC = [
    os.path.expanduser("~/daegis/records/hand-off.md"),
    # ↓ ObsidianのVaultのパスがわかれば追記（例）
    # os.path.expanduser("~/Obsidian/Vault"),
]
out = pathlib.Path.home() / "daegis/datasets/halu_cases.jsonl"


def mask(s):
    # 超軽量マスク（@, URL, 12桁未満の数列, 4+連続英字をハッシュに）
    s = re.sub(r"https?://\S+", "<URL>", s)
    s = re.sub(r"\S+@\S+", "<EMAIL>", s)
    s = re.sub(r"\b\d{4,11}\b", "<NUM>", s)

    def h(m):
        return "<ID:" + hashlib.sha256(m.group(0).encode()).hexdigest()[:8] + ">"

    s = re.sub(r"\b[A-Za-z]{4,}\b", h, s)
    return s


def iter_md(path):
    p = pathlib.Path(path)
    if p.is_dir():
        for q in p.rglob("*.md"):
            yield from iter_md(q)
    else:
        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            return
        # フェンス形式と見出し形式の両対応
        # ```halu:case ... ``` 形式（あれば最優先）
        for blk in re.findall(r"```halu:case\s+(.+?)```", text, flags=re.S):
            s = re.search(r"状況[:：]\s*(.+)", blk)
            p_ = re.search(r"方針[:：]\s*(.+)", blk)
            n = re.search(r"次[:：]\s*(.+)", blk)
            if s and p_ and n:
                yield s.group(1), p_.group(1), n.group(1), [f"file:{p.name}", "fmt:block"]
        # 見出し三連（状況/方針/次）を近接で拾う
        pat = r"(?:^|\n)#+\s*状況[^\n]*\n(.+?)\n#+\s*方針[^\n]*\n(.+?)\n#+\s*次[^\n]*\n(.+?)(?:\n#+|\Z)"
        for s, p_, n in re.findall(pat, text, flags=re.S):
            yield s.strip(), p_.strip(), n.strip(), [f"file:{p.name}", "fmt:headings"]


rows = 0
with out.open("w", encoding="utf-8") as fw:
    for src in SRC:
        for s, p_, n, tags in iter_md(src):
            s, p_, n = mask(s), mask(p_), mask(n)
            o = {
                "ts": datetime.now().isoformat(timespec="seconds"),
                "s": s,
                "p": p_,
                "n": n,
                "tags": tags + ["v1"],
            }
            fw.write(json.dumps(o, ensure_ascii=False) + "\n")
            rows += 1
print(f"[shape] wrote {rows} rows → {out}")
