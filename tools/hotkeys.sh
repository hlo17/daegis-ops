#!/usr/bin/env bash
set -eu

hk() {
  local cmd="${1:-help}"; shift || true

  # optional extensions
  [ -f tools/hk-extra.sh ] && . tools/hk-extra.sh

  # dynamic dispatch: hk_<cmd> if defined
  if type "hk_${cmd}" >/dev/null 2>&1; then "hk_${cmd}" "$@"; return; fi

  case "$cmd" in
    help)
      cat <<'EOF'
Daegis Hotkeys
  hk help
  hk list-utils
  hk hooks-fix
  hk deliver-auto <src> <user@host> <path> [opts...]
  hk deliver-b64  <src> <user@host> <path> [opts...]
  hk deliver-scp  <src> <user@host> <path> [opts...]
  hk validate <file...>
  hk validate-staged
  # add functions in tools/hk-extra.sh as: hk_<name>() { ... }
EOF
      ;;
    list-utils)
      find . \( -path "./.githooks/*" -o -path "./tools/*" -o -path "./ops/runbooks/*" \) -type f | sort
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
    deliver-auto) tools/deliver-auto.sh "$@" ;;
    deliver-b64)  tools/deliver-b64.sh  "$@" ;;
    deliver-scp)  tools/deliver-scp.sh  "$@" ;;
    validate)     for f in "$@"; do tools/validate.sh "$f"; done ;;
    validate-staged)
      files=$(git diff --cached --name-only --diff-filter=ACMRT || true)
      for f in $files; do tools/validate.sh "$f" || exit 1; done
      ;;
    *) echo "hk: unknown command: $cmd" >&2; return 2;;
  esac
}
