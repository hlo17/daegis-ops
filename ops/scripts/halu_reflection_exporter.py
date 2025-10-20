#!/usr/bin/env python3
import os, time, json, pathlib
from prometheus_client import start_http_server, Gauge

LOG_FILE = pathlib.Path(os.path.expanduser("~/daegis/logs/reflection.jsonl"))
g_reflection_total = Gauge("daegis_reflection_total", "Total reflection entries")
g_reflection_recent = Gauge("daegis_reflection_recent_1h", "Reflections in last 1h")

def count_reflections():
    total = 0
    recent = 0
    cutoff = time.time() - 3600
    if LOG_FILE.exists():
        with open(LOG_FILE, "r") as f:
            for line in f:
                try:
                    j = json.loads(line)
                    total += 1
                    ts = time.mktime(time.strptime(j["ts"], "%Y-%m-%dT%H:%M:%SZ"))
                    if ts >= cutoff:
                        recent += 1
                except Exception:
                    continue
    return total, recent

if __name__ == "__main__":
    start_http_server(9310)
    while True:
        total, recent = count_reflections()
        g_reflection_total.set(total)
        g_reflection_recent.set(recent)
        time.sleep(60)
