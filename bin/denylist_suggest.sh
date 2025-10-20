#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/daegis"
IDX="$ROOT/bridges/obsidian/derived/index.jsonl"
OUT="$ROOT/bridges/obsidian/mirror/2_Areas/50_Daegis/Daegis OS/Denylist_Proposals.md"
mkdir -p "$(dirname "$OUT")"
[ ! -s "$IDX" ] && { echo "index.jsonl not found. Run obsidian_index.sh first." >&2; exit 1; }

ts=$(date -u +%FT%TZ)

# helper: jq フィルタ共通（壊れ行は fromjson? で捨てる）
cat > "$OUT" <<EOF
---
tags: [Daegis_Core_Six, ops]
created: $ts
modified: $ts
role: control
---
# Denylist Proposals

> チェックを付けて保存 → \`denylist_apply.sh\` で反映

## 1) 管理系（README / Garden Tree）
EOF

jq -rR '
  fromjson? | select(.) |
  select(.path|test("^2_Areas/50_Daegis/(README|Garden Tree)";"")) |
  "- [ ] " + .path + " — reason: control-note"
' "$IDX" >> "$OUT"

printf "\n## 2) archives/ 配下\n" >> "$OUT"
jq -rR '
  fromjson? | select(.) |
  select(.path|test("^archives/";"")) |
  "- [ ] " + .path + " — reason: archived"
' "$IDX" >> "$OUT"

printf "\n## 3) 同名タイトルの旧版（ゆるふわ）\n" >> "$OUT"
jq -rR -s '
  def norm_title(t):
    (t
      | gsub("[()（）]\\s*[^)]*";"")                    # ()内メタ
      | gsub("\\b20[0-9]{2}[-/][0-9]{2}[-/][0-9]{2}\\b";"")  # 日付
      | ascii_downcase
      | gsub("\\s+";" ")
      | gsub("[^a-z0-9\\p{Han}\\p{Hiragana}\\p{Katakana}]+$";"") # 末尾記号
    );

  split("\n")
  | map(select(length>0) | fromjson?)
  | group_by(.title | norm_title(.))[]
  | sort_by(.mtime)
  | .[0:-1][]    # 最新以外を候補
  | "- [ ] " + .path + " — reason: older-duplicate (loose)"
' "$IDX" >> "$OUT"

echo "[denylist_suggest] wrote -> $OUT"
