\
#!/usr/bin/env bash
set -euo pipefail
mapfile -d '' files < <(git ls-files -z -- '*.md' '*.sh' '*.yaml' '*.yml' '*.bash')
((${#files[@]}==0)) && exit 0

read -r -d '' PROG <<'PL'
s/\x{FEFF}//g;              # BOM
s/\x{00A0}/ /g;             # NBSP -> space
s/\x{200B}//g;              # ZWSP
s/\x{200C}//g;              # ZWNJ
s/[\x{2018}\x{2019}]/'/g;   # ‘ ’ -> '
s/[\x{201C}\x{201D}]/"/g;   # “ ” -> "
s/[\x{2013}\x{2014}\x{2212}]/-/g;  # – — − -> -
PL

for f in "${files[@]}"; do
  perl -i -CS -pe "$PROG" "$f"
done
echo "[fix-typography] normalized. run: git diff -- ."
