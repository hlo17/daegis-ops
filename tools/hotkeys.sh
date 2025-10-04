#!/usr/bin/env bash
set -eu

# 小道具: 有れば実行（なければ丁寧に失敗）
__maybe(){ command -v "$1" >/dev/null 2>&1; }

hk() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    help)
      cat <<'H'
Daegis Hotkeys
  hk help                   # このヘルプ
  hk list-utils             # 主要ファイル一覧（.githooks / tools / runbooks）
  hk hooks-fix              # .githooks 修復（shebang/LF/pipefail/perms）
  hk deliver-auto  <src> <user@host> <path> [opts...]  # サイズ&失敗で自動切替
  hk deliver-b64   <src> <user@host> <path> [opts...]  # base64 経路
  hk deliver-scp   <src> <user@host> <path> [opts...]  # scp 経路
  hk ward                   # ward-quick があれば実行
  hk rt-smoke               # Roundtable /orchestrate を軽く叩く
  hk sentry                 # ops/sentry/sentry.sh があれば実行
H
      ;;

    list-utils)
      find . \( -path './.githooks/*' -o -path './tools/*' -o -path './ops/runbooks/*' \) -type f | sort
      ;;

    hooks-fix)
      bash -lc '
        fix(){ sed -i "1{/^\\\\$/d}" "$1";
               awk "NR==1{print \"#!/usr/bin/env bash\";next}{print}" "$1">"$1.tmp" && mv "$1.tmp" "$1";
               sed -i "s/\r$//" "$1";
               perl -0777 -pe "s/set -euo pipefail\n/set -eu\nset -o pipefail 2>\\/dev\\/null || true\n/g" -i "$1";
               chmod +x "$1"; }
        fix .githooks/pre-commit; fix .githooks/pre-push;
        git config core.hooksPath .githooks; echo "[hooks] fixed."'
      ;;

    # ---- Deliver wrappers（スクリプトがある場合だけ実行） ----
    deliver-auto)
      if [ -x tools/deliver-auto.sh ]; then tools/deliver-auto.sh "$@";
      else echo "[deliver-auto] tools/deliver-auto.sh がありません" >&2; return 1; fi
      ;;

    deliver-b64)
      if [ -x tools/deliver-b64.sh ]; then tools/deliver-b64.sh "$@";
      else echo "[deliver-b64] tools/deliver-b64.sh がありません" >&2; return 1; fi
      ;;

    deliver-scp)
      if [ -x tools/deliver-scp.sh ]; then tools/deliver-scp.sh "$@";
      else echo "[deliver-scp] tools/deliver-scp.sh がありません" >&2; return 1; fi
      ;;

    # ---- Ops helpers ----
    ward)
      if __maybe ward-quick; then ward-quick;
      else echo "[ward] ward-quick が見つかりません" >&2; return 1; fi
      ;;

    rt-smoke)
      local url="${RT_ORCHESTRATE_URL:-http://127.0.0.1:8010/orchestrate}"
      if __maybe curl && __maybe jq; then
        curl -fsS -X POST "$url" -H 'content-type: application/json' -d '{"task":"smoke"}' \
          | jq '{status,agents:(.rt_agents//.agents),votes:(.votes//[])|length,synth:(.arbitrated.synthesized_proposal)}'
      else
        echo "[rt-smoke] curl/jq が必要です" >&2; return 1
      fi
      ;;

    sentry)
      if [ -x ops/sentry/sentry.sh ]; then bash ops/sentry/sentry.sh;
      else echo "[sentry] ops/sentry/sentry.sh が見つかりません" >&2; return 1; fi
      ;;

    *)
      echo "hk: unknown command: $cmd" >&2; return 2;;
  esac
}
