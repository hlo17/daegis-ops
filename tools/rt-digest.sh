get_ppl(){ jq -r '.ppl // empty' "$HOME/daegis/tools/halu_5min_model/metrics.json" 2>/dev/null | awk 'NF{print;exit}'; }
#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# === Slack投稿: AI構文対応版 (v3.1 Zero-Handoff) ===

# 環境変数読込
if [ -f "$HOME/.config/daegis.env" ]; then
  set -a; source "$HOME/.config/daegis.env"; set +a
elif [ -f ".env" ]; then
  set -a; source .env; set +a
fi

SLACK_URL="${SLACK_WEBHOOK_URL:-}"
if [ -z "$SLACK_URL" ]; then
  echo "❌ SLACK_WEBHOOK_URL 未設定 (.env or ~/.config/daegis.env)"
  exit 1
fi

# brief.md の先頭40行を取得
digest=$(awk 'NR<=40' brief.md)

# === AI/人間両対応の構造化Slack投稿 ===
payload=$(jq -Rs --arg txt "$digest" \
'{text: ("[handoff_digest_start]\n" + $txt + "\n[handoff_digest_end]")}' <<<"$digest")

curl -sS -X POST -H 'Content-type: application/json' \
     --data "$payload" "$SLACK_URL" >/dev/null && \
  echo "$(date '+%F %T') ✅ Slack投稿完了：#daegis-brief (AI構文対応)"

# === consolidated SUMMARY with PPL (appended by patch) ===
if [ -f "${AB_JSON:-/srv/round-table/ab-result.json}" ]; then
  dec=$(jq -r '.decision // empty' "$AB_JSON" 2>/dev/null)
  pv=$(jq -r '.reason.p_value // .reason.p // .kpi.p_value // empty' "$AB_JSON" 2>/dev/null)
  imp=$(jq -r '.kpi.improvement // .reason.improvement // empty' "$AB_JSON" 2>/dev/null)
  n=$(jq -r '.kpi.samples // empty' "$AB_JSON" 2>/dev/null)
  ppl=$(get_ppl)
  [ -n "$dec$pv$imp$n" ] && logger -t "$LOGTAG" "SUMMARY: decision=${dec:-NA} p=${pv:-NA} Δ=${imp:-NA} n=${n:-NA} PPL=${ppl:-NA}"
fi
