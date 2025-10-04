#!/usr/bin/env bash
set -euo pipefail
# 対象: ステージ済みのテキスト（*.md,*.sh,*.yml,*.yaml,*.bash）
files=$(git diff --cached --name-only --diff-filter=ACMRT | grep -E '\.(md|sh|ya?ml|bash)$' || true)
[ -z "${files}" ] && exit 0
# BOM/NULL検出
bad=$(LC_ALL=C grep -nIU $'\x00' $files 2>/dev/null || true)
bom=$(LC_ALL=C grep -nIU $'\xEF\xBB\xBF' $files 2>/dev/null || true)
if [ -n "$bad$bom" ]; then
  echo "$bad$bom"
  echo "[check-utf8] BOM/NULL bytes detected. Fix and re-stage." >&2
  exit 1
fi
