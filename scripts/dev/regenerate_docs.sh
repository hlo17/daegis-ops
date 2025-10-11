#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-$PWD}"
echo "[regen] rebuilding docs bundles…"
# ここに本再生成の呼び出しを追加していく
jq . docs/chronicle/system_map.json > /dev/null || echo "[warn] system_map.json missing/invalid"
jq . docs/rollup/current.json > /dev/null || echo "[warn] rollup/current.json missing/invalid"
echo "[done] (Phase VIで本実装へ差し替え)"
