#!/usr/bin/env bash
set -euo pipefail
topic="${1:?topic}"; to="${2:?to}"; card="${3:?cardpath}"
id=$(openssl rand -hex 6)
ts=$(date -u +%FT%TZ)
body="カード: ${card} を処理してください。
参照: docs/agents/assistant_profile.md, docs/agents/AGENTS.md, docs/chronicle/plans.md"
jq -cn --arg id "$id" --arg from "human:AEGIS" --arg to "$to" \
  --arg topic "$topic" --arg body "$body" --arg ts "$ts" \
  '{id:$id,from:$from,to:$to,topic:$topic,body:$body,tags:["window"],status:"open",ts:$ts}' \
  >> logs/introspect.jsonl
echo "$id"
