#!/usr/bin/env bash
set -euo pipefail
f="${1:?file}"
case "$f" in
  *.sh|*.bash)
    bash -n "$f"
    command -v shellcheck >/dev/null 2>&1 && shellcheck -x "$f" || true
    ;;
  *.py)
    python3 -m py_compile "$f"
    ;;
  *.yml|*.yaml)
    python3 - <<'PY' "$f"
import sys,yaml
with open(sys.argv[1],'r',encoding='utf-8') as fh: yaml.safe_load(fh)
PY
    command -v yamllint >/dev/null 2>&1 && yamllint -d relaxed "$f" || true
    ;;
  *) :;;
esac
echo "[validate] OK: $f"
