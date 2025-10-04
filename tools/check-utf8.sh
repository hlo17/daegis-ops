#!/usr/bin/env bash
set -euo pipefail
files=$(git diff --cached --name-only --diff-filter=ACMRT | grep -E '\.(md|sh|ya?ml|bash)$' || true)
[ -z "$files" ] && exit 0
LC_ALL=C grep -nIU $'\x00' $files 2>/dev/null && { echo "[check-utf8] NULL detected" >&2; exit 1; } || true
LC_ALL=C grep -nIU $'\xEF\xBB\xBF' $files 2>/dev/null && { echo "[check-utf8] BOM detected" >&2; exit 1; } || true
