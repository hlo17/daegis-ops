#!/usr/bin/env bash
set -eu
# 使い方: tools/deliver-heredoc.sh /remote/path <<'PAYLOAD' ... PAYLOAD
# 例: tools/deliver-heredoc.sh /tmp/foo.sh <<'PAYLOAD'
#       #!/usr/bin/env bash
#       echo hi
#     PAYLOAD
dst="$1"; shift
cat > "$dst"
chmod +x "$dst" 2>/dev/null || true
echo "[deliver] wrote $dst"
