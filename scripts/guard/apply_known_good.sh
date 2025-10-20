#!/usr/bin/env bash
set -euo pipefail

# Known Good Config Dry-Run Script
# Reads ops/policy/known_good.yml and shows what would be applied

KNOWN_GOOD_FILE="ops/policy/known_good.yml"

if [ -f "$KNOWN_GOOD_FILE" ]; then
    # Extract timeout and cache_ttl values safely
    TIMEOUT=$(grep -E '^\s*timeout:' "$KNOWN_GOOD_FILE" | head -1 | sed 's/.*timeout:\s*\([0-9]*\).*/\1/' || echo "unknown")
    CACHE_TTL=$(grep -E '^\s*cache_ttl:' "$KNOWN_GOOD_FILE" | head -1 | sed 's/.*cache_ttl:\s*\([0-9]*\).*/\1/' || echo "unknown")
    
    echo "[DRY-RUN] would apply known_good (timeout=$TIMEOUT, cache_ttl=$CACHE_TTL)"
else
    echo "[DRY-RUN] known_good.yml not found"
fi

exit 0