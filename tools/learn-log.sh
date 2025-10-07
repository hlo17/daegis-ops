#!/usr/bin/env bash
set -euo pipefail
DATA="$HOME/daegis/data"
mkdir -p "$DATA"
ts="$(date -u +%FT%TZ)"

# 使い方:
# learn-log.sh \
#   --task_id T --prompt_summary "..." \
#   --chosen chatgpt --why "..." \
#   --agents 'chatgpt:0.72,gemini:0.66' \
#   --cost_usd 0.018 --tokens 3250 \
#   --latency_ms 8400 --human_feedback 4 --outcome success \
#   --notes "key=value,key2=value2"

# 超シンプルな引数パーサ
while [ $# -gt 0 ]; do
  case "$1" in
    --task_id)          task_id="$2"; shift 2;;
    --prompt_summary)   prompt_summary="$2"; shift 2;;
    --chosen)           chosen="$2"; shift 2;;
    --why)              why="$2"; shift 2;;
    --agents)           agents="$2"; shift 2;;   # "a:0.7,b:0.6"
    --cost_usd)         cost_usd="$2"; shift 2;;
    --tokens)           tokens="$2"; shift 2;;
    --latency_ms)       latency_ms="$2"; shift 2;;
    --human_feedback)   human_feedback="$2"; shift 2;;
    --outcome)          outcome="$2"; shift 2;;
    --notes)            notes="$2"; shift 2;;
    *) echo "unknown arg $1" >&2; exit 2;;
  esac
done

agents_json="$(printf '%s' "${agents:-}" | awk -F, '
BEGIN{print "["}
{
  n=split($0,a,",");
  for(i=1;i<=n;i++){
    split(a[i],p,":");
    name=p[1]; score=p[2]; if(score=="") score="null";
    printf("%s{\"agent\":\"%s\",\"score\":%s}", (i==1?"":","), name, score);
  }
}
END{print "]"}')"

notes_json="$(printf '%s' "${notes:-}" | awk -F, '
BEGIN{print "["}
{
  n=split($0,a,",");
  for(i=1;i<=n;i++){
    printf("%s\"%s\"", (i==1?"":","), a[i]);
  }
}
END{print "]"}')"

jq -cn \
  --arg ts "$ts" \
  --arg task_id "${task_id:-}" \
  --arg prompt_summary "${prompt_summary:-}" \
  --arg chosen "${chosen:-}" \
  --arg why "${why:-}" \
  --argjson agents "$agents_json" \
  --argjson cost "{\"tokens\": ${tokens:-0}, \"usd\": ${cost_usd:-0}}" \
  --arg latency_ms "${latency_ms:-0}" \
  --arg human_feedback "${human_feedback:-0}" \
  --arg outcome "${outcome:-unknown}" \
  --argjson notes "$notes_json" \
  '{ts:$ts, task_id:$task_id, prompt_summary:$prompt_summary,
    candidates:$agents, chosen:$chosen, why:$why,
    cost:($cost), latency_ms:($latency_ms|tonumber),
    human_feedback:($human_feedback|tonumber),
    outcome:$outcome, notes:$notes}' \
  >> "$DATA/learn_events.jsonl"

echo "[learn-log] appended -> $DATA/learn_events.jsonl"
