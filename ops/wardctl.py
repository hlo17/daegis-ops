#!/usr/bin/env python3
import sys, os, json, glob, yaml, re
from pathlib import Path

OUT = Path(os.getenv("WARD_OUT", "/tmp/ward-out"))
OUT_SD = OUT/"file_sd"
OUT_RULES = OUT/"rules"
OUT.mkdir(parents=True, exist_ok=True)
OUT_SD.mkdir(parents=True, exist_ok=True)
OUT_RULES.mkdir(parents=True, exist_ok=True)

def mk_job_name(svc): return f"ward_{svc}"

def render_blackbox_sd(svc, card):
    mon = card.get("monitor", {})
    if mon.get("probe") != "http": return
    url = card["systemd"]["health"]["url"]
    target = {"targets": [url], "labels": {"job": mk_job_name(svc), "service": svc}}
    (OUT_SD/f"{svc}.json").write_text(json.dumps([target], ensure_ascii=False, indent=2))

def render_prom_rules(svc, card):
    mon = card.get("monitor", {})
    if mon.get("probe") != "http": return
    slo = mon.get("slo", {})
    latency = slo.get("latency_ms_p95", 1500)
    avail = slo.get("availability", 0.995)
    job = mk_job_name(svc)
    grp = {
      "name": f"ward_{svc}",
      "rules": [
        {
          "alert": "WardServiceDown",
          "expr": f'probe_success{{job="{job}"}} == 0',
          "for": "60s",
          "labels": {"severity": mon.get("severity","warning"), "service": svc},
          "annotations": {
            "summary": f"{svc} is down",
            "description": f"{svc} health probe failing via blackbox (job={job})."
          }
        },
        {
          "alert": "WardLatencyHighP95",
          "expr": f'histogram_quantile(0.95, sum by (le) (rate(probe_http_duration_seconds_bucket{{job="{job}"}}[5m]))) * 1000 > {latency}',
          "for": "5m",
          "labels": {"severity": mon.get("severity","warning"), "service": svc},
          "annotations": {
            "summary": f"{svc} latency p95 high",
            "description": f"{svc} p95 latency over {latency}ms (5m window)."
          }
        },
        {
          "record": "ward_availability_ratio",
          "expr": f'avg_over_time(probe_success{{job="{job}"}}[30d])'
        },
        {
          "alert": "WardAvailabilitySLOBreached",
          "expr": f'avg_over_time(probe_success{{job="{job}"}}[30d]) < {avail}',
          "for": "10m",
          "labels": {"severity": "info", "service": svc},
          "annotations": {
            "summary": f"{svc} 30d availability under SLO",
            "description": f"{svc} 30d availability below {avail}."
          }
        }
      ]
    }
    (OUT_RULES/f"{svc}.yml").write_text(yaml.safe_dump({"groups":[grp]}, sort_keys=False))

def main():
    cards = glob.glob(str(Path(__file__).parent/"ward/*.yml"))
    if not cards:
        print("no ward cards found"); sys.exit(1)
    for p in cards:
        card = yaml.safe_load(open(p))
        svc = card["service"]
        render_blackbox_sd(svc, card)
        render_prom_rules(svc, card)
    print(f"[wardctl] rendered -> {OUT}")
if __name__ == "__main__":
    main()
