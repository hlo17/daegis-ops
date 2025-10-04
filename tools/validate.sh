#!/usr/bin/env bash
# usage: validate <file> [...]
set -euo pipefail
has(){ command -v "$1" >/dev/null 2>&1; }

validate_one() {
  f="$1"
  case "$f" in
    *.sh|*.bash)
      bash -n "$f"
      has shellcheck && shellcheck -x -S style "$f" || true
      ;;
    *.yml|*.yaml)
      # 構文だけは必ずチェック
      python3 - <<'PY' "$f"
import sys,yaml
with open(sys.argv[1],'r',encoding='utf-8') as fh: yaml.safe_load(fh)
PY
      has yamllint && yamllint -d "{rules:{line-length:{max:160},truthy:{level:warning}}}" "$f" || true
      ;;
    *.md) : ;;   # ここは必要なら markdownlint など後日
    *.py)  python3 -m py_compile "$f" ;;
    *) : ;;
  esac
  echo "[validate] OK: $f"
}

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <file> [...]" >&2; exit 2
fi
for f in "$@"; do validate_one "$f"; done
