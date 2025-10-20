#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"
agent="${1:?agent-dir-or-name}"
path="$agent"
[ -d "$path" ] || path="ops/remote/$agent"
[ -d "$path" ] || { echo "[ERR] not found: $agent"; exit 2; }
hash=$( (find "$path" -type f -maxdepth 3 -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}') )
ts=$(date -u +%FT%TZ)
echo "{\"ts\":\"$ts\",\"agent\":\"$agent\",\"hash_rely\":\"sha256:$hash\"}" >> ops/ledger/agent_identity.jsonl
echo "[hash_rely] $agent sha256:$hash"

# dual-write to agent_dna.jsonl (migration period)
echo "{\"ts\":\"$ts\",\"agent\":\"$agent\",\"kind\":\"hash_rely\",\"value\":\"sha256:$hash\"}" >> ops/ledger/agent_dna.jsonl
