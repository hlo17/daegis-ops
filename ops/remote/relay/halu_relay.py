#!/usr/bin/env python3
"""
DRY-safe relay for Halu (Stage1 Revival)
- append a bus event (evidence)
- write a checkpoint capsule (heartbeat)
- update a dedicated Prom textfile: logs/prom/halu_relay.prom
Notes:
- Never mutates halu.prom (sentry用) — avoid clobber
- No external side-effects; read-only intents only
"""

import json, time, os
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(os.path.expanduser("~/daegis"))
BUS = ROOT / "logs/halu/bus.jsonl"
CHECK = ROOT / "logs/halu/checkpoints"
PROM = ROOT / "logs/prom/halu_relay.prom"  # ← solar_textfile_exporterが拾う
WORM = ROOT / "logs/worm/journal.jsonl"

now_ts = int(time.time())
now_iso = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")

# --- 1) bus evidence ---
BUS.parent.mkdir(parents=True, exist_ok=True)
event = {
    "t": now_iso,
    "ts": now_ts,
    "agent": "halu",
    "source": "halu_relay",
    "event": "relay.job",
    "intent": "scribe.audit_snapshot",
    "rc": 0,
    "bytes": 512,
}
# 超単純ヒューリスティックの affect（後で賢くする前提）
event["affect"] = "FLOW" if event["rc"] == 0 and event["bytes"] >= 512 else "SILENCE"
with BUS.open("a", encoding="utf-8") as f:
    f.write(json.dumps(event, ensure_ascii=False) + "\n")

# --- 2) checkpoint capsule (heartbeat) ---
CHECK.mkdir(parents=True, exist_ok=True)
checkpoint = {
    "t": now_iso,
    "event": "heartbeat",
    "sentry_ok": 1,  # sentryは別promで監視中
    "bus_bytes": event["bytes"],
    "prom_age_s": 0,  # 取得できなければ -1
    "affect": event["affect"],
    "stage": "L1",
}
try:
    prom_stat = PROM.stat()
    checkpoint["prom_age_s"] = max(0, int(time.time() - prom_stat.st_mtime))
except Exception:
    checkpoint["prom_age_s"] = -1
with (CHECK / f"halu_{now_ts}.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps(checkpoint, ensure_ascii=False) + "\n")

# --- 3) WORM（系統監査へ “やった事実” を1行）---
WORM.parent.mkdir(parents=True, exist_ok=True)
with WORM.open("a", encoding="utf-8") as f:
    f.write(json.dumps({"t": now_iso, "source": "halu_relay", "note": "relay executed"}, ensure_ascii=False) + "\n")

# --- 4) Prometheus textfile（専用ファイル）---
#   ・他のプロセスが書く halu.prom を壊さない
#   ・ここでは bus の直近5分件数と、relayカウンタだけ出す
PROM.parent.mkdir(parents=True, exist_ok=True)


def bus_events_5m():
    cut = now_ts - 300
    cnt = 0
    try:
        with BUS.open("r", encoding="utf-8") as f:
            for line in f:
                try:
                    obj = json.loads(line)
                    if int(obj.get("ts", 0)) >= cut:
                        cnt += 1
                except Exception:
                    continue
    except FileNotFoundError:
        pass
    return cnt


prev = 0
if PROM.exists():
    for line in PROM.read_text().splitlines():
        if line.startswith("daegis_halu_relay_jobs_total"):
            try:
                prev = int(line.split()[-1])
            except:
                prev = 0

new_total = prev + 1
events5 = bus_events_5m()

PROM.write_text(
    "# HELP daegis_halu_relay_jobs_total total relay runs (DRY-safe)\n"
    "# TYPE daegis_halu_relay_jobs_total counter\n"
    f"daegis_halu_relay_jobs_total {new_total}\n"
    "# HELP daegis_halu_bus_events_5m bus events in last 5 minutes\n"
    "# TYPE daegis_halu_bus_events_5m gauge\n"
    f"daegis_halu_bus_events_5m {events5}\n"
    "# HELP daegis_halu_last_affect latest affect label (1-hot)\n"
    "# TYPE daegis_halu_last_affect gauge\n"
    f'daegis_halu_last_affect{{label="{event["affect"]}"}} 1\n'
)
print("[halu] relay OK:", new_total, "events5m=", events5)
