# hk rt-smoke: /orchestrate を軽く叩く
hk_rt_smoke() {
  local url="${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}"
  if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    curl -fsS -X POST "$url" -H 'content-type: application/json' -d '{"task":"daily test"}' | jq .
  else
    echo "[rt-smoke] curl/jq が必要です" >&2
    return 1
  fi
}
hk_acap_grok()    { tools/acap-escalate.sh grok   "${1:-issue}" "${*:2}"; }
hk_acap_gemini()  { tools/acap-escalate.sh gemini "${1:-issue}" "${*:2}"; }
hk_acap_chappie() { tools/acap-escalate.sh chappie "${1:-issue}" "${*:2}"; }
