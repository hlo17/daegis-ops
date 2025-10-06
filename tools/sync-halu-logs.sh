#!/usr/bin/env bash
set -euo pipefail
rsync -av ~/halu/train/logs/ round-table:~/halu/train/logs/
