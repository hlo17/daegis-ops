# Daegis Operations Runbook

- 迷ったらまず [[Sentry]]（ハーネス）で観測。
- 判定: **GO**=relay検知OKかつLedger反映OK / **NO-GO**=relay未達 or Ledger未反映。
- 自動アクション順: 再観測(待ち/窓/リトライ) → 購読フォールバック → DEDUPE_OFF 再検 → 恒久策（小パッチ/Runbook更新）。

## 実行粒度（Terminal Hygiene）
- **ブロック実行**: ヒアドキュメント、ssh内でさらにシェル、複合パイプ、sed/awk/Perl長文、クォート3段以上。
- **行ごとOK**: 単発(systemctl/journalctl/tail)、export/chmod等。
- **編集系の順序**: 生成 → CRLF/BOM/ZWSP掃除 → `bash -n` → 実行。

## Sentry 観測フロー（最新版）
> この節は `[[sentry/sentry.sh]]` から自動反映されます。

<!-- BEGIN:SENTRY -->
```bash
#!/usr/bin/env bash
set -euo pipefail

# --- 必須環境 ---
: "${PI:?set PI}"        # 例: export PI=192.168.0.183
: "${KEY:?set KEY}"      # 例: export KEY=~/.ssh/id_ed25519

# --- パラメータ（必要に応じて上書き可） ---
ID="t$(date +%H%M%S)"
PROMPT="${PROMPT:-受信テスト}"

RELAY_SINCE="${RELAY_SINCE:-10 min ago}"
RELAY_TRIES="${RELAY_TRIES:-4}"
RELAY_DELAYS="${RELAY_DELAYS:-1 2 3 4}"
RELAY_TAIL="${RELAY_TAIL:-60}"

LEDGER_TRIES="${LEDGER_TRIES:-5}"
LEDGER_DELAYS="${LEDGER_DELAYS:-1 2 3 4 5}"

FALLBACK_SUB_TIMEOUT="${FALLBACK_SUB_TIMEOUT:-8}"  # 秒

fatal(){ echo "FATAL: $*" >&2; exit 1; }
warn(){  echo "WARN: $*"  >&2; }
note(){  echo "NOTE: $*"; }

# --- 1) サービス稼働チェック ---
ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" "systemctl is-active halu-relay"  >/dev/null || fatal "relay down"
ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" "systemctl is-active halu-scribe" >/dev/null || fatal "scribe down"

# --- 2) 投入 ---
ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" \
  "mosquitto_pub -h 127.0.0.1 -p 1883 -u caller -P caller123 \
     -t halu/ask -m '{\"id\":\"${ID}\",\"prompt\":\"${PROMPT}\"}'"

# --- 3) relay 観測（ログ→購読フォールバック） ---
seen=0; i=0
for d in ${RELAY_DELAYS}; do
  i=$((i+1))
  ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" \
    "journalctl -u halu-relay --since '${RELAY_SINCE}' --no-pager | grep -F 'published id=${ID} -> halu/answer' -q" \
    && { seen=1; break; } || sleep "$d"
  [ "$i" -ge "$RELAY_TRIES" ] && break || true
done

if [ "$seen" -ne 1 ]; then
  # フォールバック購読（※安全クォート版）
  ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" 'bash -lc '"'"'
    pat=$(printf "%s" "\"id\": \"'"$ID"'\"")
    timeout '"$FALLBACK_SUB_TIMEOUT"'s sh -lc "
      mosquitto_sub -h 127.0.0.1 -p 1883 -u scribe -P scribe123 -t halu/answer -v \
        | grep -m1 -F \"$pat\"
    "
  '"'"'' && seen=1 || true
fi

if [ "$seen" -ne 1 ]; then
  echo '--- relay tail ---'
  ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" "journalctl -u halu-relay -n ${RELAY_TAIL} --no-pager" || true
  fatal "relay未達: ${ID}"
fi

# --- 4) scribe の dedupe 参考ログ（失敗扱いにしない） ---
ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" \
  "journalctl -u halu-scribe --since '${RELAY_SINCE}' --no-pager | grep -F 'skip duplicate id=${ID}' -q" \
  && warn "dedupe skip: ${ID}"

# --- 5) Ledger 反映（待ち付き） ---
ledger_ok=0; i=0
for d in ${LEDGER_DELAYS}; do
  i=$((i+1))
  ssh -o IdentitiesOnly=yes -i "$KEY" "f@$PI" \
    "LEDGER=/home/f/daegis/halu/logs/answers-\$(date +%Y%m%d).jsonl; grep -F '\"id\": \"${ID}\"' \"\$LEDGER\" -q" \
    && { ledger_ok=1; break; } || sleep "$d"
  [ "$i" -ge "$LEDGER_TRIES" ] && break || true
done
[ "$ledger_ok" -eq 1 ] || fatal "Ledger未反映: ${ID}"

note "OK: ID=${ID} PROMPT=${PROMPT}"
```
<!-- END:SENTRY -->

## トラブル時の最短手順
1. [[Sentry]] 実行 → NO-GOなら tail/購読出力を保存
2. scribeのdedupeログとLedger差分を見る
3. 暫定: DEDUPE_OFF=1 / seen-idsクリア
4. 恒久策: TTL/当日スコープ化・pre-dedupe削除 等 → PR
5. 記録: [[notes.md]] に追記

# Final test with correct fix

---
_appended: 2025-09-29T00:58:43+0900_
### コマンド貼付けルール
- `#` で始まる行は **解説用コメント** なので、そのまま貼り付けないこと。
- `(Pi)` や `(Mac)` のような環境ラベルはOK（区別のため残す）。

