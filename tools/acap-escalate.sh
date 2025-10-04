#!/usr/bin/env bash
# usage: acap-escalate <to:{grok|gemini|chappie}> <title> [note...]
set -euo pipefail
to="${1:?to}"; shift
title="${1:?title}"; shift || true
note="${*:-}"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '[%s] → %s : %s // %s\n' "$ts" "$to" "$title" "$note" | tee -a ops/ledger/acap.log
case "$to" in
  grok)    echo '→ 「Grok、3行診断を返して」テンプレを使って依頼';;
  gemini)  echo '→ 「Gemini、代替案2通り」テンプレを使って依頼';;
  chappie) echo '→ 「Chappie、テンプレ/UI改善」テンプレを使って依頼';;
  *) echo "unknown target: $to" >&2; exit 2;;
esac
