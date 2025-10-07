#!/bin/bash
set -euo pipefail

HALU_BASE="$HOME/halu"
DAEGIS_BASE="$HOME/daegis"
ENV_SRC="$HOME/.config/daegis/.env.local"
TS="$(date '+%Y-%m-%dT%H:%M:%S%z')"

say() { printf '[setup-halu] %s\n' "$*"; }

say "start at $TS"

# 1) 既存 halu があれば退避
if [ -d "$HALU_BASE" ]; then
  mv "$HALU_BASE" "${HALU_BASE}.backup.$(date +%Y%m%d-%H%M%S)"
  say "backup: moved existing halu -> ${HALU_BASE}.backup.*"
fi

# 2) ディレクトリ初期化
mkdir -p "$HALU_BASE"/{app,conf,logs,ops,ark,docs,train/{data,logs}}
say "dirs created under $HALU_BASE"

# 3) 環境ファイル（機微）は ~/.config から継承
if [ -f "$ENV_SRC" ]; then
  mkdir -p "$HALU_BASE/.config/halu"
  cp "$ENV_SRC" "$HALU_BASE/.config/halu/.env.local"
  chmod 600 "$HALU_BASE/.config/halu/.env.local"
  say "env copied: $ENV_SRC -> halu/.config/halu/.env.local"
else
  say "env NOT found: $ENV_SRC (後で作成してください)"
fi

# 4) サンプル設定の継承（存在するものだけ）
# mosquitto サンプル
MOSQ_SAMPLE="$DAEGIS_BASE/ops/hosts/Fs-MacBook-Pro.local/mosquitto/mosquitto.conf.sample"
[ -f "$MOSQ_SAMPLE" ] && cp "$MOSQ_SAMPLE" "$HALU_BASE/conf/mosquitto.conf.sample" \
  && say "copied mosquitto sample"

# compose ファイル
[ -f "$DAEGIS_BASE/ops/docker/docker-compose.yml" ] && \
  cp "$DAEGIS_BASE/ops/docker/docker-compose.yml" "$HALU_BASE/ops/docker-compose.yml" \
  && say "copied docker-compose.yml"

# 5) ログ/ドキュメントは共有したい場合のみシンボリックに
# （必要なければコメントアウト可）
ln -sfn "$DAEGIS_BASE/ark/logbook" "$HALU_BASE/logs"
ln -sfn "$DAEGIS_BASE/ops/ward"    "$HALU_BASE/docs"
say "linked logs -> daegis/ark/logbook, docs -> daegis/ops/ward"

# 6) Wardに記録
WARD="$DAEGIS_BASE/ops/ward/Daegis-Ward.md"
if [ -f "$WARD" ]; then
  {
    echo
    echo "## Halu setup snapshot ($TS)"
    echo "- halu base: $HALU_BASE"
    echo "- env: $ENV_SRC -> halu/.config/halu/.env.local $( [ -f "$ENV_SRC" ] && echo '(copied)' || echo '(missing)' )"
    echo "- copied: docker-compose.yml, mosquitto.conf.sample (if present)"
    echo "- linked: logs, docs"
  } >> "$WARD"
  say "ward updated: $WARD"
fi

# 7) 要約
say "done."
echo "tree (first levels):"
find "$HALU_BASE" -maxdepth 2 -print | sed -n '1,80p'
