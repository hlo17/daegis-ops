#!/usr/bin/env bash
set -euo pipefail
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then echo "❌ Detached HEAD"; exit 1; fi
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ Uncommitted changes. Commit or stash first."; exit 1
fi
ver="${1:-}"
if [ -z "$ver" ]; then ver="v$(date +%Y%m%d-%H%M)"; fi
echo "➡️  Tagging ${ver} on ${branch}"
git tag -a "$ver" -m "Daegis release $ver"
git push origin "$ver"
echo "✅ Pushed tag $ver"
echo "ℹ️  If pre-commit complains: PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit ..."