#!/usr/bin/env bash
set -euo pipefail
phase="${PHASE:-unknown}"
comp="${COMPONENT_ID:-guardian}"
ts="$(date +%s)"
printf "%s" "${phase}${comp}${ts}" | sha1sum | awk '{print $1}'
