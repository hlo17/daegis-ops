import sys, json, re, pathlib

IN = pathlib.Path(sys.argv[1])
OUTDIR = IN.parent
rows = []
csv = ["id,model,latency_ms,out_json"]

def first_n(s, n=40):
    s = re.sub(r"\s+", " ", s or "").strip()
    return (s[:n] + "…") if len(s) > n else s

with IN.open("r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            o = json.loads(line)
        except Exception:
            continue

        # フィールドの揺れに対応
        id_ = o.get("id") or o.get("prompt_id") or o.get("pid")
        prompt = o.get("prompt") or o.get("input") or ""
        if not id_:
            m = re.search(r"\bt\d{2}\b", prompt)
            id_ = m.group(0) if m else ""

        model = o.get("model") or (o.get("meta") or {}).get("model") or ""
        latency = (o.get("latency_ms")
                   or (o.get("meta") or {}).get("latency_ms") or "")
        output = (o.get("output") or o.get("text")
                  or o.get("answer") or o.get("content") or "")

        # t01〜t19 だけに絞り込み（IDが取れなければ通す）
        if id_ and not re.fullmatch(r"t1[0-9]|t0[1-9]", id_):
            continue

        # 行を構築
        show = first_n(output, 40)
        rows.append(f"| {id_ or '-'} | {show} | {model or '-'} | {latency or '-'} |")
        # 元JSONを個別に保存しておくと参照に便利
        name = f"{id_ or 'noid'}_{len(rows):02d}.json"
        (OUTDIR / name).write_text(json.dumps(o, ensure_ascii=False, indent=2),
                                   encoding="utf-8")
        csv.append(f"{id_},{model},{latency},{name}")

# 出力
md_path = OUTDIR / "relay_rows.md"
csv_path = OUTDIR / "relay_summary.csv"
md_path.write_text("\n".join(rows) + ("\n" if rows else ""), encoding="utf-8")
csv_path.write_text("\n".join(csv) + "\n", encoding="utf-8")
print(md_path)
print(csv_path)
