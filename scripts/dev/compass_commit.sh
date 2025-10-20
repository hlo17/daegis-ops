#!/usr/bin/env bash
set -euo pipefail

# Compass Change Tracking Script
# Usage: scripts/dev/compass_commit.sh "actor" "reason"

ACTOR="${1:-unknown}"
REASON="${2:-no reason given}"
COMPASS_FILE="ops/policy/compass.json"
LOG_FILE="logs/config/compass_changes.jsonl"

# Ensure log directory exists
mkdir -p "logs/config"

# Get SHA256 of compass.json if it exists
if [ -f "$COMPASS_FILE" ]; then
    COMPASS_SHA=$(sha256sum "$COMPASS_FILE" | cut -d" " -f1)
else
    COMPASS_SHA=""
fi

# Generate UTC timestamp
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Append to JSONL log
echo "{\"ts\":\"$TIMESTAMP\",\"phase\":\"IIIb\",\"actor\":\"$ACTOR\",\"reason\":\"$REASON\",\"sha\":\"$COMPASS_SHA\"}" >> "$LOG_FILE"

# Stage compass.json if it exists (no commit)
if [ -f "$COMPASS_FILE" ]; then
    git add "$COMPASS_FILE"
    echo "Compass change logged and staged: $COMPASS_SHA"
else
    echo "Compass change logged (file not found): $LOG_FILE"
fi