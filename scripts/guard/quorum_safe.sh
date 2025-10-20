#!/usr/bin/env bash
set -euo pipefail
test -s ops/quorum/HUMAN.ok   || { echo "HUMAN.ok missing"; exit 1; }
test -s ops/quorum/SECOND.ok  || { echo "SECOND.ok missing"; exit 1; }
echo "QUORUM: READY"
