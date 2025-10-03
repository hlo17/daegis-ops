#!/usr/bin/env python3
import os, sys, json, glob, pathlib, yaml

BASE = pathlib.Path.home() / "daegis" / "ops" / "ward"
OUT  = pathlib.Path(os.environ.get("WARD_OUT", "/tmp/ward-out"))
(OUT / "rules").mkdir(parents=True, exist_ok=True)
(OUT / "file_sd").mkdir(parents=True, exist_ok=True)

def load_yaml(p):
    with open(p, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def main():
    cards = sorted(glob.glob(str(BASE / "*.yml")))
    for c in cards:
        data = load_yaml(c) or {}
        name = data.get("service") or pathlib.Path(c).stem
        # rules
        for r in (data.get("rules") or []):
            (OUT / "rules" / f"{name}.yml").write_text(
                yaml.safe_dump(r, sort_keys=False, allow_unicode=True), encoding="utf-8"
            )
        # file_sd (blackbox targets)
        for fd in (data.get("file_sd") or []):
            (OUT / "file_sd" / f"{name}.json").write_text(
                json.dumps(fd, ensure_ascii=False, indent=2), encoding="utf-8"
            )
    print(f"[wardctl] rendered -> {OUT}")

if __name__ == "__main__":
    try:
        import yaml  # type: ignore
    except Exception:
        print("[wardctl] missing pyyaml; trying to install to venv/site...", file=sys.stderr)
    main()
