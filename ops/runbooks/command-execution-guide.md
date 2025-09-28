# Daegis Command Execution Guide

## A. 実行粒度
- **ブロック**：ヒアドキュメント／SSH内シェル／複合パイプ・サブシェル／クォート3段↑／長い置換
- **行ごと**：単発確認、export/chmod/bash -n/systemctl/journalctl

## B. クォート／JSON／SSH
- 原則: 外側 "…"、内側 `"` は `\"`
- `'` を使うなら `'...'`"$VAR"`'...'`
- JSONは `printf '%s' "$payload"` パイプ or ヒアドキュメント

## C. クリーニング例（macOS）
```bash
sed -i '' $'s/\r$//' file.sh
LC_ALL=C perl -0777 -pe 's/\x{200B}|\x{FEFF}//g' -i file.sh
bash -n file.sh
```

## D. ダブルクォート奇数検知（対象を指定して使う）
```bash
awk '{ n=gsub(/"/,""); if (n%2==1) print NR": "$0 }' ~/daegis/ops/sentry/sentry.sh
```
