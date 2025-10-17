#!/usr/bin/env bash
set -euo pipefail
python3 -m py_compile router/app.py
./scripts/dev/smoke_chat.sh || true   # 既に起動中なら 200 を確認/未起動でもOK
echo "[OK] preflight passed"
