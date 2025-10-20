#!/usr/bin/env python3
import os, json, time, pathlib, textwrap, sys, datetime, requests

ROOT = pathlib.Path.home() / "daegis"
LOG  = ROOT / "logs" / "reflection.jsonl"
OUT  = ROOT / "reports" / "reflection_summary.md"
TOK_FILE = ROOT / "config" / "openai_token"

def load_recent_reflections(limit_lines=200):
    if not LOG.exists(): return []
    lines = LOG.read_text().splitlines()[-limit_lines:]
    items = []
    for ln in lines:
        try:
            j = json.loads(ln)
            items.append(j)
        except Exception:
            continue
    return items

def minimal_summary(items):
    ts = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    total = len(items)
    cutoff = time.time() - 3600
    last1h = 0
    for j in items:
        try:
            t = time.strptime(j.get("ts",""), "%Y-%m-%dT%H:%M:%SZ")
            if time.mktime(t) >= cutoff: last1h += 1
        except Exception:
            pass
    return f"""# Halu Daily Reflection Summary
- generated: {ts} (UTC)
- total reflections: {total}
- last 1h: {last1h}

> ※ OpenAI未使用（または失敗）。最小要約を表示しています。
""".rstrip()+"\n"

def call_openai_summary(items, token, model="gpt-4o-mini"):
    # 入力をコンパクト化（直近100件を軽量要約）
    short = []
    for j in items[-100:]:
        short.append({
            "ts": j.get("ts"),
            "level": j.get("level"),
            "metric": j.get("metric"),
            "value": j.get("value"),
            "note": j.get("note","")
        })
    sysmsg = (
        "You summarize Halu's daily reflection log for an operator. "
        "Be precise, short, and action-oriented. Output in Japanese. "
        "Sections: 1) 今日のサマリ(一行) 2) 状態 3) 反射の傾向 4) 推奨アクション(最大1つ). "
        "Avoid fluff. If data is tiny, still produce actionable insight."
    )
    usr = "以下は直近の reflection.jsonl エントリ（抜粋）です。短く要約してください。\n" + json.dumps(short, ensure_ascii=False)

    payload = {
        "model": model,
        "messages": [
            {"role":"system","content": sysmsg},
            {"role":"user","content": usr}
        ],
        "temperature": 0.2,
        "max_tokens": 400
    }
    resp = requests.post(
        "https://api.openai.com/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=30
    )
    resp.raise_for_status()
    data = resp.json()
    content = data["choices"][0]["message"]["content"].strip()
    ts = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    return f"""# Halu Daily Reflection Summary (AI)
- generated: {ts} (UTC)
- source: OpenAI {model}

{content}

> ※ API失敗時は自動で最小要約にフォールバックします。
""".rstrip()+"\n"

def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    (ROOT/"reports").mkdir(parents=True, exist_ok=True)
    items = load_recent_reflections()
    # デフォルトは最小
    out = minimal_summary(items)
    # トークンがあればAI要約を試みる
    if TOK_FILE.exists():
        token = TOK_FILE.read_text().strip()
        if token:
            try:
                out = call_openai_summary(items, token)
            except Exception as e:
                # 失敗時は最小要約に戻す（上書きしない）
                out = minimal_summary(items) + f"\n> Fallback reason: {e}\n"
    OUT.write_text(out)
    print(f"[ok] summary -> {OUT}")

if __name__ == "__main__":
    main()
