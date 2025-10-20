#!/usr/bin/env python3
import json, hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COMPASS = ROOT / "ops/policy/compass.json"
OUTDIR = ROOT / "ops/exporters/out"
OUTDIR.mkdir(parents=True, exist_ok=True)
OUTFILE = OUTDIR / "compass.prom"


def load_intents():
    if not COMPASS.exists():
        return []
    try:
        data = json.loads(COMPASS.read_text(encoding="utf-8"))
        return [str(i) for i in data.get("intents", [])]
    except Exception:
        return []


def main():
    intents = sorted(set(load_intents()))
    lines = [
        "# HELP daegis_compass_intents_total Flag per intent (1=present)",
        "# TYPE daegis_compass_intents_total counter",
    ]
    for name in intents:
        lines.append(f'daegis_compass_intents_total{{intent="{name}"}} 1')

    # reserve metrics for Phase V
    lines.append("# TYPE daegis_compass_intents_success_total counter")
    lines.append("# TYPE daegis_compass_intents_failure_total counter")

    sha = hashlib.sha256(COMPASS.read_bytes()).hexdigest() if COMPASS.exists() else "none"
    lines.append(f"# compass_sha {sha}")

    OUTFILE.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
