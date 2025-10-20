#!/usr/bin/env bash
set -euo pipefail
grep -RInE 'API_KEY|TOKEN|SECRET|OPENAI|ANTHROPIC|GOOGLEAI|PERPLEXITY|GROK' \
  config/ ops/ scripts/ .env* 2>/dev/null || true
