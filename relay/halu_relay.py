import time, glob, os, json, datetime, sys

BASE = os.path.expanduser("~/daegis/relay")
os.makedirs(BASE, exist_ok=True)

def latest_jsonl_stats():
    files = sorted(glob.glob(os.path.join(BASE, "*.jsonl")))
    if not files:
        return {"files": 0, "latest": None, "lines": 0}
    latest = files[-1]
    try:
        with open(latest, "r", encoding="utf-8") as f:
            lines = sum(1 for _ in f)
    except Exception as e:
        print(f"[relay] read error: {e}", flush=True)
        lines = 0
    return {"files": len(files), "latest": os.path.basename(latest), "lines": lines}

def main():
    print("[relay] started at", datetime.datetime.utcnow().isoformat()+"Z", flush=True)
    while True:
        s = latest_jsonl_stats()
        print(f"[relay] heartbeat {datetime.datetime.utcnow().isoformat()}Z  files={s['files']} latest={s['latest']} lines={s['lines']}", flush=True)
        time.sleep(30)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
