#!/usr/bin/env bash
set -euo pipefail
base="${1:-http://127.0.0.1:8080}"
# MISS
echo "---- MISS ----"
curl -s -D - -o /dev/null -X POST "$base/chat" -H 'Content-Type: application/json' \
  -d '{"q":"hello"}' | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id|x-mode)' || true
# HIT
echo "---- HIT ----"
curl -s -D - -o /dev/null -X POST "$base/chat" -H 'Content-Type: application/json' \
  -d '{"q":"hello"}' | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id|x-mode)' || true
# 504
echo "---- 504 ----"
curl -s -D - -o /dev/null -X POST "$base/chat" -H 'Content-Type: application/json' \
  -d '{"q":"slow","delay":4}' | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id|x-mode)' || true