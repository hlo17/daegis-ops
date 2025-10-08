#!/usr/bin/env bash
set -euo pipefail
tag="${1:-}"
if [ -z "$tag" ]; then echo "Usage: $0 <tag>"; exit 1; fi
echo "⚠️  SAFE ROLLBACK (guided). No hard reset."
echo "1) Inspect diff vs $tag:"
git diff "$tag"...HEAD --stat || true
echo "2) Create a revert commit (no push yet):"
git revert -n "$tag"..HEAD || true
echo "3) Resolve conflicts, run tests, then:"
echo "   git commit -m \"Rollback to $tag (revert)\" && git push"