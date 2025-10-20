#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/daegis"

EXP="${1:?experiment yml}"
MODE="${2:---dry}"

[ "$MODE" = "--dry" ] || { echo "[DENY] Playgroundは--dryのみ"; exit 2; }
[ -f "$EXP" ] || { echo "[ERR] not found: $EXP"; exit 2; }

tmp_json="$(mktemp -t pgjson.XXXXXX)"

# --- YAML -> JSON ---
if command -v yq >/dev/null 2>&1; then
  yq -o=json "$EXP" > "$tmp_json"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$EXP" > "$tmp_json" <<'PY'
import sys, json
p = sys.argv[1]
try:
    import yaml
    with open(p, 'r') as f:
        data = yaml.safe_load(f)
except Exception:
    data = {}
    for line in open(p, 'r'):
        line=line.strip()
        if (not line) or line.startswith('#') or ':' not in line:
            continue
        k, v = line.split(':', 1)
        data[k.strip()] = v.strip().strip('"').strip("'")
print(json.dumps(data, ensure_ascii=False))
PY
else
  kv=$(sed -n 's/^[[:space:]]*\([^:#]\+\):[[:space:]]*\(.*\)$/\1:\2/p' "$EXP" \
      | awk -F': *' 'NF>=2{gsub(/"/,"\\\"",$2);printf("\"%s\":\"%s\",",$1,$2)}')
  echo "{${kv%,}}" > "$tmp_json"
fi

# --- 抜粋 ---
intent=$(jq -r '.intent // empty' "$tmp_json")
level=$(jq -r '.autonomy_level // empty' "$tmp_json")
name=$(jq -r '.name // "<noname>"' "$tmp_json")
goal=$(jq -r '.goal // "<nogoal>"' "$tmp_json")

if [ -z "$intent" ] || [ -z "$level" ]; then
  echo "[ERR] intent/autonomy_level を解析できません: $EXP"
  jq . "$tmp_json" 2>/dev/null || true
  rm -f "$tmp_json"
  exit 3
fi

# --- ルールチェック（allowlist） ---
pref=$(jq -r '.intent_prefix' ops/playground/allowlist.json)
case "$level" in L0|L1) : ;; *) echo "[DENY] autonomy=$level (L0/L1のみ)"; rm -f "$tmp_json"; exit 3;; esac
case "$intent" in ${pref}*) : ;; *) echo "[DENY] intent=$intent (prefix=${pref}*)"; rm -f "$tmp_json"; exit 3;; esac

ts=$(date -u +%FT%TZ)
mkdir -p logs/playground logs/prom logs/worm

log="logs/playground/$(basename "$EXP").log"
echo "[$ts] DRY run: ${name} — ${goal}" | tee -a "$log"

# --- DRY作業（安全な静的解析：壊れリンク数） ---
broken=$(
  grep -Rho ']\(\./[^)]\+\)' docs/chronicle 2>/dev/null \
    | sed 's/.*](//;s/)$//' \
    | while read -r p; do [ -f "docs/chronicle/$p" ] || echo "$p"; done \
    | wc -l | tr -d ' '
)
echo "broken_links=$broken" | tee -a "$log"

# --- WORM 記録 ---
printf '{"ts":"%s","event":"play_dry","name":"%s","intent":"%s","autonomy":"%s","broken_links":%d}\n' \
  "$ts" "$name" "$intent" "$level" "$broken" >> logs/worm/journal.jsonl

# --- Prom 出力（textfile exporterが logs/prom/*.prom を配信） ---
cat > logs/prom/daegis_playground.prom <<PR
daegis_play_last_run_timestamp_seconds $(date +%s)
daegis_play_last_broken_links $broken
PR

echo "OK DRY: $name (broken_links=$broken)"
rm -f "$tmp_json"

# 再度Promを確実に残す（冪等）
mkdir -p logs/prom
: "${broken:=0}"
cat > logs/prom/daegis_playground.prom <<PR
daegis_play_last_run_timestamp_seconds $(date +%s)
daegis_play_last_broken_links ${broken}
PR
