\
#!/usr/bin/env bash
set -euo pipefail
pattern='[\x{00A0}\x{200B}\x{200C}\x{FEFF}\x{2018}\x{2019}\x{201C}\x{201D}\x{2013}\x{2014}\x{2212}]'
git ls-files -z -- '*.md' '*.sh' '*.yaml' '*.yml' '*.bash' \
| while IFS= read -r -d '' f; do
  perl -CS -ne "print qq{$ARGV:$.:$_} if /$pattern/" "$f" || true
done
