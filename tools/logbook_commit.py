#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import datetime
import pathlib
import uuid

ROOT = pathlib.Path(__file__).resolve().parents[1]
LOGDIR = ROOT / "logbook"


def read_env_dotenv(dotenv_path):
    env = {}
    if dotenv_path.exists():
        for line in dotenv_path.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    return env


def load_decision(src):
    if src and src != "-":
        return json.loads(pathlib.Path(src).read_text())
    data = sys.stdin.read().strip()
    return json.loads(data) if data else {}


def shortid():
    return uuid.uuid4().hex[:8]


def main():
    env = os.environ.copy()
    env.update(read_env_dotenv(ROOT / ".env"))

    d = load_decision(sys.argv[1] if len(sys.argv) > 1 else "-")

    d.setdefault("actor", env.get("ACTOR", "halu.dev"))
    d.setdefault("origin", env.get("ORIGIN", "local"))
    d.setdefault("schema_version", env.get("SCHEMA_VERSION", "0.9"))
    d.setdefault("consistency_check", {"status": "pass"})
    d.setdefault("evidence", [])

    ts_utc = datetime.datetime.utcnow().replace(microsecond=0)
    d.setdefault("ts", ts_utc.strftime("%Y-%m-%dT%H:%M:%SZ"))

    if "decision_id" in d:
        dec_id = str(d["decision_id"])
        if not dec_id.startswith("logbook::"):
            dec_id = "logbook::" + dec_id
            d["decision_id"] = dec_id
    else:
        d["decision_id"] = "logbook::dec_" + ts_utc.strftime("%Y%m%d") + "_" + shortid()

    yyyy = ts_utc.strftime("%Y")
    mm = ts_utc.strftime("%m")
    dd = ts_utc.strftime("%d")
    outdir = LOGDIR / yyyy / mm / dd
    outdir.mkdir(parents=True, exist_ok=True)
    fname = f"{d['decision_id'].split('::', 1)[1]}.md"
    outpath = outdir / fname

    fm = {
        "id": d["decision_id"],
        "ts": d["ts"],
        "actor": d["actor"],
        "origin": d["origin"],
        "schema_version": d["schema_version"],
        "status": d.get("status", "approved"),
        "tags": d.get("tags", []),
    }
    front = "---\n" + "\n".join(f"{k}: {json.dumps(v, ensure_ascii=False)}" for k, v in fm.items()) + "\n---\n"
    body = f"# {d.get('title') or d.get('answer') or 'Decision'}\n\n"
    body += "保存元: 自動書記官 / commit bot\n\n"
    body += "```json\n" + json.dumps(d, ensure_ascii=False, indent=2) + "\n```\n"
    outpath.write_text(front + body)

    # git 管理下ならコミット（pushは設定があれば）
    try:
        subprocess.run(["git", "add", str(outpath)], cwd=ROOT, check=True)
        msg = f"logbook: add {d['decision_id']} ({yyyy}-{mm}-{dd})"
        subprocess.run(["git", "commit", "-m", msg], cwd=ROOT, check=True)
        subprocess.run(["git", "push"], cwd=ROOT, check=False)
    except Exception:
        pass

    print(str(outpath))


if __name__ == "__main__":
    main()
