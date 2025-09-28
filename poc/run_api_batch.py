import os, time, json, textwrap, datetime
import yaml
from pathlib import Path

# OpenAI SDK (pip install openai)
from openai import OpenAI

client = OpenAI()
HERE = Path(__file__).resolve().parent
PROMPTS = HERE / "prompts.yaml"
OUTDIR = HERE / "outputs" / "api"
OUTDIR.mkdir(parents=True, exist_ok=True)

MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
MAX_CHARS = 40  # 表示用の先頭抜粋

def now_iso():
    return datetime.datetime.now().astimezone().isoformat(timespec="milliseconds")

def first_n(s, n):
    s = " ".join(s.split())
    return (s[:n] + "…") if len(s) > n else s

def call_openai(prompt: str) -> tuple[str, int]:
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    t0 = time.perf_counter()
    # Chat Completions API（安定）
    resp = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2,
    )
    dt_ms = int((time.perf_counter() - t0) * 1000)
    text = resp.choices[0].message.content or ""
    return text, dt_ms

def main(ids: list[str] | None = None):
    with PROMPTS.open("r", encoding="utf-8") as f:
        prompts: dict[str, str] = yaml.safe_load(f)

    if ids:
        targets = [(i, prompts[i]) for i in ids if i in prompts]
    else:
        targets = list(prompts.items())

    rows_md = []
    summary_csv = ["id,model,latency_ms,out_json"]
    for pid, prompt in targets:
        print(f"[run] {pid} …", flush=True)
        ret = call_openai(prompt)
        text, latency_ms = ret[:2]
        usage = ret[2] if len(ret) >= 3 else None
        out = {
            "id": pid,
            "model": MODEL,
            "prompt": prompt,
            "output": text,
            "latency_ms": latency_ms,
            "ts": now_iso(),
            "usage": usage,
            "usage": getattr(getattr(client, "last_response", None), "usage", None)
        }
        out_path = OUTDIR / f"{pid}.json"
        out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")

        rows_md.append(
            f"| {pid} | {first_n(text, MAX_CHARS)} | {MODEL} | {latency_ms} |"
        )
        summary_csv.append(f"{pid},{MODEL},{latency_ms},{out_path.name}")

    date_tag = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    md_path = OUTDIR / f"rows_{date_tag}.md"
    csv_path = OUTDIR / f"summary_{date_tag}.csv"
    md = "\n".join(rows_md) + "\n"
    md_path.write_text(md, encoding="utf-8")
    csv_path.write_text("\n".join(summary_csv) + "\n", encoding="utf-8")

    print("\n[done] rows_md:", md_path)
    print("       summary_csv:", csv_path)
    print("       json dir:", OUTDIR)

if __name__ == "__main__":
    import sys
    ids = sys.argv[1:] if len(sys.argv) > 1 else None
    main(ids)
