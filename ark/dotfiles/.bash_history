
  # 8) スペース正規化・圧縮／空行整理
  s/[\x{00A0}\x{3000}]/ /g; s/ {2,}/ /g; s/\n{3,}/\n\n/g;
' > "司法試験_H30_採点実感_clean.txt"
cd ~/Downloads/Law/司法試験/司法試験\ H30
pdftotext -eol unix -enc UTF-8 -nopgbrk "司法試験 H30 採点実感.pdf" - | perl -CSD -0777 -pe '
  # 0) 不可視文字の掃除
  s/\x{FEFF}//g; s/[\x{200B}-\x{200D}]//g;

  # 1) 改行は LF に
  s/\r\n|\r/\n/g;

  # 2) （決め手）前行末の「第○」を次行と結合（間の空行0〜2も許容）
  #    例: …） 第１ ⏎ [空行0〜2] ⏎ 総論 → …） 第１ 総論
  s{
    (第[0-9０-９一二三四五六七八九十百千]+)[、.．]?     # 「第○」
    [ \t\u00A0\u3000]* \n                               # 改行
    (?: [ \t\u00A0\u3000]* \n ){0,2}                   # 空行 0〜2
    [ \t\u00A0\u3000]*                                  # 次行先頭空白
  }{$1 }gmx;

  # 3) 行末の箇条点（・/･/•/·）を削除
  s/[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})[ \t\u00A0\u3000]*\n/\n/g;

  # 4) 箇条点だけの独立行を削除
  s/^[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})+[ \t\u00A0\u3000]*\n//gm;

  # 5) 行頭の項番だけ行 → 次行本文と結合（空行0〜2許容）
  s{
    ^[ \t\u00A0\u3000]*
    (  第[0-9０-９一二三四五六七八九十百千]+
     | [0-9０-９]+
     | [（(]?[0-9０-９]+[)）]
     | [ア-ン]
     | [\x{2460}-\x{2473}]
     | [IVXＩＶＸ]+
    )
    [、.．]? [ \t\u00A0\u3000]* \n
    (?: [ \t\u00A0\u3000]* \n ){0,2}
    [ \t\u00A0\u3000]* (?=\S)
  }{$1 }gmxm;

  # 6) 段落内の単発改行 → 半角スペース（空行は保持）
  s/\n(?![ \t\u00A0\u3000]*\n)/ /g;

  # 7) 日本語どうしの不要スペース削除
  s/([ぁ-んァ-ヶ一-龠])[ \t\u00A0\u3000]+([ぁ-んァ-ヶ一-龠])/$1$2/g;

  # 8) スペース正規化・圧縮／空行整理
  s/[\x{00A0}\x{3000}]/ /g; s/ {2,}/ /g; s/\n{3,}/\n\n/g;
' > "司法試験_H30_採点実感_clean.txt"
pdftotext -eol unix -enc UTF-8 -nopgbrk   "$HOME/Downloads/Law/司法試験 H30/司法試験 H30 採点実感.pdf" - | perl -CSD -0777 -pe '
    s/\x{FEFF}//g; s/[\x{200B}-\x{200D}]//g;
    s/\r\n|\r|\x{2028}|\x{2029}/\n/g;

    s{
      (第[0-9０-９一二三四五六七八九十百千]+)[、.．]?
      [ \t\u00A0\u3000]* \n
      (?: [ \t\u00A0\u3000]* \n ){0,2}
      [ \t\u00A0\u3000]*
    }{$1 }gmx;

    s/[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})[ \t\u00A0\u3000]*\n/\n/g;
    s/^[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})+[ \t\u00A0\u3000]*\n//gm;

    s{
      ^[ \t\u00A0\u3000]*
      (  第[0-9０-９一二三四五六七八九十百千]+
       | [0-9０-９]+
       | [（(]?[0-9０-９]+[)）]
       | [ア-ン]
       | [\x{2460}-\x{2473}]
       | [IVXＩＶＸ]+
      )
      [、.．]? [ \t\u00A0\u3000]* \n
      (?: [ \t\u00A0\u3000]* \n ){0,2}
      [ \t\u00A0\u3000]* (?=\S)
    }{$1 }gmxm;

    s/\n(?![ \t\u00A0\u3000]*\n)/ /g;
    s/([ぁ-んァ-ヶ一-龠])[ \t\u00A0\u3000]+([ぁ-んァ-ヶ一-龠])/$1$2/g;
    s/[\x{00A0}\x{3000}]/ /g;
    s/ {2,}/ /g;
    s/\n{3,}/\n\n/g;
' > "$HOME/Downloads/Law/司法試験 H30/司法試験_H30_採点実感_clean.txt"
cd "$HOME/Downloads/Law/司法試験/司法試験 H30"
ls -1
pdftotext -eol unix -enc UTF-8 -nopgbrk   "./司法試験 H30 採点実感.pdf" - | perl -CSD -0777 -pe '
  s/\x{FEFF}//g; s/[\x{200B}-\x{200D}]//g;
  s/\r\n|\r|\x{2028}|\x{2029}/\n/g;

  s{
    (第[0-9０-９一二三四五六七八九十百千]+)[、.．]?
    [ \t\u00A0\u3000]* \n
    (?: [ \t\u00A0\u3000]* \n ){0,2}
    [ \t\u00A0\u3000]*
  }{$1 }gmx;

  s/[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})[ \t\u00A0\u3000]*\n/\n/g;
  s/^[ \t\u00A0\u3000]*(?:[・･]|\x{2022}|\x{00B7})+[ \t\u00A0\u3000]*\n//gm;

  s{
    ^[ \t\u00A0\u3000]*
    (  第[0-9０-９一二三四五六七八九十百千]+
     | [0-9０-９]+
     | [（(]?[0-9０-９]+[)）]
     | [ア-ン]
     | [\x{2460}-\x{2473}]
     | [IVXＩＶＸ]+
    )
    [、.．]? [ \t\u00A0\u3000]* \n
    (?: [ \t\u00A0\u3000]* \n ){0,2}
    [ \t\u00A0\u3000]* (?=\S)
  }{$1 }gmxm;

  s/\n(?![ \t\u00A0\u3000]*\n)/ /g;
  s/([ぁ-んァ-ヶ一-龠])[ \t\u00A0\u3000]+([ぁ-んァ-ヶ一-龠])/$1$2/g;
  s/[\x{00A0}\x{3000}]/ /g;
  s/ {2,}/ /g;
  s/\n{3,}/\n\n/g;
' > "./司法試験_H30_採点実感_clean.txt"
pdftotext -eol unix -enc UTF-8 -nopgbrk "./司法試験 H30 採点実感.pdf" - | perl -CSD -0777 -pe '
    # --- 1. 前処理：不可視文字の除去と改行コードの統一 ---
    s/\x{FEFF}//g; 
    s/[\x{200B}-\x{200D}]//g;
    s/\r\n|\r|\x{2028}|\x{2029}/\n/g;

    # --- 2. 構造的な行（見出し・リスト・箇条書き）と次行を連結 ---
    # これが整形ロジックの心臓部。mフラグで各行頭(^)にマッチさせる。
    s{
      ^ [ \t\u00A0\u3000]* # 行頭のあらゆる空白
      ( # $1としてキャプチャする部分
        (?: # グループ化 (いずれかのパターンにマッチ)
            第[0-9０-９一二三四五六七八九十百千]+
          | [0-9０-９]+
          | [（(]?[0-9０-９]+[)）]
          | [ア-ン]
          | [\x{2460}-\x{2473}]
          | [IVXＩＶＸ]+
          | [・･] | \x{2022} # 箇条書き「・」もこのルールに統合
        )
        [、.．]? # 直後の句読点は任意
      ) # キャプチャ終了
      [ \t\u00A0\u3000]* \n # 行末の改行
      (?: [ \t\u00A0\u3000]* \n ){0,2} # 間の空行を0〜2行許容
      [ \t\u00A0\u3000]* (?=\S) # 次の行に文字があることを確認
    }{$1 }gmx; # 置換：キャプチャした項番($1)と半角スペース

    # --- 3. 段落内の単発改行（ハードラップ）をスペースに置換 ---
    # ただし、段落の区切り（空行）は保護する
    s/\n(?![ \t\u00A0\u3000]*\n)/ /g;

    # --- 4. 後処理：スペースの正規化と圧縮、空行の整理 ---
    # 日本語間の不要なスペースを削除
    s/([ぁ-んァ-ヶ一-龠])[ \t\u00A0\u3000]+([ぁ-んァ-ヶ一-龠])/$1$2/g;
    # 残ったNBSPや全角スペースを半角に統一
    s/[\x{00A0}\x{3000}]/ /g;
    # 2つ以上の連続した半角スペースを1つに圧縮
    s/ {2,}/ /g;
    # 3行以上の連続改行を2行（1つの空行）にまとめる
    s/\n{3,}/\n\n/g;
' > "./司法試験_H30_採点実感_clean.txt"
source "/Users/f/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daisy/0_System/scripts/venv/bin/activate"
source "/Users/f/Library/Mobile Documents/iCloud~md~obsidian/Documents/Daisy/0_System/scripts/venv/bin/activate"
mkdir -p ~/Projects/daegis/bin/halu
nano ~/daegis/bin/halu/agent_halu.py
nano ~/daegis/bin/halu/agent_halu.py
echo $PS1
ps aux | grep python
read -p "Continue? (yes/no) "
cat ~/.bashrc | grep -i exit
bash --norc
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519 f@192.168.0.183
docker compose exec -it mosquitto mosquitto_sub -h localhost -t 'daegis/#' -v
# 受信（サブスクライブ）
mosquitto_sub -h localhost -t 'daegis/#' -v
# 1) インストール
brew install mosquitto
# 受信（サブスクライブ）
mosquitto_sub -h localhost -t 'daegis/#' -v
version: "3.9"
services:
  mosquitto:
    image: eclipse-mosquitto:2
    container_name: ${COMPOSE_PROJECT_NAME:-halu}-mosquitto-1
    ports:
      - "1883:1883"
    volumes:
      - ./conf/mosquitto.conf:/mosquitto/config/mosquitto.conf:ro
    networks: [halu_net]
  halu:
    build: .
    container_name: ${COMPOSE_PROJECT_NAME:-halu}-app-1
    environment:
      - MQTT_HOST=${MQTT_HOST:-mosquitto}
      - MQTT_PORT=${MQTT_PORT:-1883}
      - MQTT_ASK_TOPIC=${MQTT_ASK_TOPIC:-daegis/ask/halu}
      - MQTT_REPLY_TOPIC=${MQTT_REPLY_TOPIC:-daegis/reply/halu}
      - INSTANCE_ID=${INSTANCE_ID:-dev}
      - DEBUGPY=${DEBUGPY:-0}
    depends_on: [mosquitto]
    networks: [halu_net]
    # DEBUGPY=1 のとき外部からアタッチしたい場合は下行を有効化
    # ports: ["5678:5678"]
networks:
  halu_net: {}
　sudo raspi-config
# Interface Options → VNC → <Enable>
# Display Options → VNC Resolution → 1920x1080（推奨）
# Performance Options → GPU Memory → 128（軽いGUIなら十分）
systemctl status vncserver-x11-serviced
# active (running) であればOK。無効なら:
sudo systemctl enable --now vncserver-x11-serviced
# Mac → Pi へトンネル
ssh -N -L 5901:localhost:5900 pi@round-table.local
mkdir -p ~/halu-dev/conf ~/halu-dev/.vscode
cd ~/halu-dev
# docker-compose.yml
cat > docker-compose.yml <<'YML'
# Mosquitto設定（開発用・匿名許可）
cat > conf/mosquitto.conf <<'CONF'
docker compose up -d
docker compose ps
docker compose logs -f --tail=50
docker compose exec mosquitto mosquitto_pub -h localhost -t daegis/ask/halu -m '{"prompt":"ping"}'
services:
  mosquitto:
    # 既存そのまま
  halu:
    # 既存そのまま
    volumes:
      - ./logbook:/data/logbook   # 未来の参照用にマウント（今はホスト側で保存）
#!/usr/bin/env python3
import os, sys, json, subprocess, datetime, pathlib, textwrap, uuid
ROOT = pathlib.Path(__file__).resolve().parents[1]
LOGDIR = ROOT / "logbook"
def read_env_dotenv(dotenv_path):
    env = {}
    if dotenv_path.exists():
        for line in dotenv_path.read_text().splitlines():
            line=line.strip()
            if not line or line.startswith("#") or "=" not in line: continue
            k,v=line.split("=",1); env[k.strip()]=v.strip()
    return env
def load_decision(src):
    if src and src != "-":;         return json.loads(pathlib.Path(src).read_text())
    # stdin
    data = sys.stdin.read().strip()
    return json.loads(data) if data else {}
def shortid():
    return uuid.uuid4().hex[:8]
def main():
    env = os.environ.copy()
    env.update(read_env_dotenv(ROOT/".env"))
    d = load_decision(sys.argv[1] if len(sys.argv)>1 else "-")
    # デフォルト値（共通キー名を固定）
    d.setdefault("actor", env.get("ACTOR","halu.dev"))
    d.setdefault("origin", env.get("ORIGIN","local"))
    d.setdefault("schema_version", env.get("SCHEMA_VERSION","0.9"))
    d.setdefault("consistency_check", {"status":"pass"})
    d.setdefault("evidence", [])
    ts_utc = datetime.datetime.utcnow().replace(microsecond=0)
    d.setdefault("ts", ts_utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
    # id が無ければ決める（logbook::dec_YYYYMMDD_<8hex>）
    if "decision_id" in d:;         dec_id = str(d["decision_id"])
        if not dec_id.startswith("logbook::"): dec_id = "logbook::" + dec_id
    else:
        dec_id = "logbook::dec_" + ts_utc.strftime("%Y%m%d") + "_" + shortid()
        d["decision_id"] = dec_id
    # 保存パス（年/月配下に MD で保存）
    yyyy = ts_utc.strftime("%Y"); mm = ts_utc.strftime("%m"); dd = ts_utc.strftime("%d")
    outdir = LOGDIR / yyyy / mm / dd
    outdir.mkdir(parents=True, exist_ok=True)
    fname = f"{d['decision_id'].split('::',1)[1]}.md"
    outpath = outdir / fname
    # Markdown本文（YAML front matter + JSON原本）
    title = d.get("title") or d.get("answer") or "Decision"
    fm = {
        "id": d["decision_id"],
        "ts": d["ts"],
        "actor": d["actor"],
        "origin": d["origin"],
        "schema_version": d["schema_version"],
        "status": d.get("status","approved"),
        "tags": d.get("tags", []),
    }
    front = "---\n" + "\n".join(f"{k}: {json.dumps(v, ensure_ascii=False)}" for k,v in fm.items()) + "\n---\n"
    body = f"# {title}\n\n"            f"保存元: 自動書記官（NotebookLM 想定）/ commit bot\n\n"            f"```json\n{json.dumps(d, ensure_ascii=False, indent=2)}\n```\n"
    outpath.write_text(front + body)
    # Git add/commit（Git 管理下でのみ）
    try:
        subprocess.run(["git","add",str(outpath)], cwd=ROOT, check=True)
        msg = f"logbook: add {d['decision_id']} ({yyyy}-{mm}-{dd})"
        subprocess.run(["git","commit","-m",msg], cwd=ROOT, check=True)
        # push は任意（リモートがあれば）
        subprocess.run(["git","rev-parse","--is-inside-work-tree"], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
        subprocess.run(["git","remote"], cwd=ROOT, check=True, stdout=subprocess.PIPE)
        subprocess.run(["git","push"], cwd=ROOT, check=False)
    except Exception as e:
        # Git 管理外でも保存は完了しているのでエラーにしない
        print(f"[logbook] saved: {outpath} (git commit/push skipped or partial)")
    print(str(outpath))
if __name__ == "__main__":;     main()
# zsh を既定に（まだなら）
chsh -s /bin/zsh
# zsh を既定に（まだなら）
chsh -s /bin/zsh
git init
git config user.name  "Your Name"
git config user.email "you@example.com"
git add .
git commit -m "init halu-dev"
# サンプルを記録（自動書記官）
echo '{"title":"Phase3 PASS","answer":"正式配備を承認","evidence":[]}' | python3 scripts/logbook_commit.py -
# → logbook/YYYY/MM/DD/dec_....md が生成 & 自動コミット
# リモートがある場合だけ
# git remote add origin <YOUR_GIT_URL>
mosquitto_pub -h localhost -t 'daegis/ask/halu' -m '{"prompt":"ping"}'
# Makefile（TAB必須）
cat > Makefile <<'MAKE'
# VS Code タスク
cat > .vscode/tasks.json <<'JSON'
halu-dev/
├─ docker-compose.yml
├─ .env
├─ Makefile
├─ conf/
│  └─ mosquitto.conf
├─ app/
│  └─ main.py
├─ requirements.txt
├─ Dockerfile
└─ .vscode/
   └─ tasks.json
mkdir -p ~/halu-dev && cd ~/halu-dev
mkdir -p app conf .vscode
cat > docker-compose.yml <<'YML'
cat > conf/mosquitto.conf <<'CONF'
cat > .env <<'ENV'
cat > requirements.txt <<'TXT'
cat > Dockerfile <<'DOCKER'
cat > app/main.py <<'PY'
cat > .vscode/tasks.json <<'JSON'
cat > Makefile <<'MAKE'
make up         # mosquitto + halu 起動（初回は halu イメージをビルド）
make logs       # 別タブで追尾
make sub        # さらに別タブで購読（daegis/#）
make pub-ping   # 送信。購読タブに pong が出れば成功
cat > Makefile <<'MAKE'
make up
make logs
make sub
make pub-ping
brew install gnu-make
gmake --version   # 4.x になっていればOK
brew install make
gmake --version   # 4.x が表示されればOK
which gmake       # 例: /opt/homebrew/bin/gmake
gmake up
gmake logs
echo 'sys_interval 1' >> conf/mosquitto.conf
services:
  mosquitto:
    image: eclipse-mosquitto:2
    ports: ["1883:1883"]
    volumes:
      - ./conf/mosquitto.conf:/mosquitto/config/mosquitto.conf:ro
    healthcheck:
      # $$SYS => コンテナ内では $SYS に見える（Compose の展開を回避）
      test: ["CMD-SHELL", "mosquitto_sub -h localhost -t '$$SYS/broker/version' -C 1 -W 5 || exit 1"]
      interval: 10s
      timeout: 6s
      retries: 3
    networks: [halu_net]cd ~/halu-dev
cat > docker-compose.yml <<'YML'
docker compose config >/dev/null && echo "compose OK"
gmake down
gmake up
docker inspect -f '{{.State.Health.Status}}' halu-dev-mosquitto-1
# → healthy が出れば成功
gmake sub         # 別タブで購読
healthcheck:
  test: ["CMD-SHELL", "mosquitto_pub -h localhost -t hc/ping -m ok && mosquitto_sub -h localhost -t hc/ping -C 1 -W 3"]
  interval: 10s
  timeout: 6s
docker compose logs -f --tail=50 halu
# ここに: [halu] connected rc=0 が出ていれば接続OK
mkdir -p scripts logbook
cat > scripts/logbook_commit.py <<'PY'
chmod +x scripts/logbook_commit.pyecho '{"title":"Phase3 PASS","answer":"正式配備を承認","evidence":[]}' | python3 scripts/logbook_commit.py -
# → logbook/YYYY/MM/DD/dec_....md が出力されます  halu:
    build: .
    env_file: .env
    depends_on:
      mosquitto:
        condition: service_healthy
    networks: [halu_net]
    volumes:
gmake pub-ping
# prompt を starship に統一
eval "$(starship init zsh)"
# あると便利：行中 # をコメントとして扱う
setopt interactivecommentsformat = "$username@$hostname:$directory$character "
[username]
show_always = true
style_user = "cyan"
[hostname]
ssh_only = false
style = "green"
[directory]
style = "bold yellow"
[character]
success_symbol = "# "
error_symbol = "✗ "docker compose exec halu ls -1 /data/logbook/$(date +%Y)/$(date +%m)/$(date +%d)
# starship の設定ファイルを作る（TOMLは"ファイル"です）
mkdir -p ~/.config
cat > ~/.config/starship.toml <<'TOML'
# zshrc に最小設定を追記（重複しないようにガード付き）
grep -q 'starship init zsh' ~/.zshrc || printf '%s\n' 'eval "$(starship init zsh)"' >> ~/.zshrc
grep -q 'interactivecomments' ~/.zshrc || printf '%s\n' 'setopt interactivecomments' >> ~/.zshrc
# 反映
exec zsh -l
gmake logs
docker compose logs -f --tail=50 halu
chmod +x scripts/logbook_commit.py
echo '{"title":"Phase3 PASS","answer":"正式配備を承認","evidence":[]}' | python3 scripts/logbook_commit.py -
chsh -s /bin/bash
restart
sudo reboot
echo $SHELL
bash --version
/bin/bash --noprofile --norc -lc '
set -e
# VS Code Shell Integration を見つけて .bashrc から source（存在すれば）
add_line() { grep -Fqs "$1" "$HOME/.bashrc" || printf "%s\n" "$1" >> "$HOME/.bashrc"; }

# Remote (SSH) 用の場所
RSH=$(ls -d "$HOME/.vscode-server/bin"/*/shellIntegration-bash.sh 2>/dev/null | head -1 || true)
[ -n "$RSH" ] && add_line "source \"$RSH\" 2>/dev/null || true"

# ローカル Mac 用の場所
LOC=$(ls -d "$HOME/.vscode/bin"/*/shellIntegration-bash.sh 2>/dev/null | head -1 || true)
[ -n "$LOC" ] && add_line "source \"$LOC\" 2>/dev/null || true"

# ログイン時に .bashrc を確実に読むための保険（Mac）
[ -f "$HOME/.bash_profile" ] || : > "$HOME/.bash_profile"
grep -Fqs "source ~/.bashrc" "$HOME/.bash_profile" || echo '[[ -f ~/.bashrc ]] && source ~/.bashrc' >> "$HOME/.bash_profile"

# 反映
source "$HOME/.bashrc" || true
echo "[ok] VS Code shell integration: wired (if present). Open a NEW terminal tab."
'
cat > ~/.bashrc <<'EOF'
cat > ~/.bash_profile <<'EOF'
source ~/.bash_profile
echo $SHELL
echo $PS1
chsh -s /bin/bash
pwd
d
mkdir -p ~/daegis/.vscode
cp ~/halu-dev.migrated.20251006-151256/.vscode/tasks.json ~/daegis/.vscode/
cp ~/halu-dev.migrated.20251006-151256/.vscode/settings.json ~/daegis/.vscode/
ls -a ~/halu-dev.migrated.20251006-151256
SRC="$HOME/halu-dev.migrated.20251006-151256/scripts"
DST="$HOME/daegis"
# 置き場作成
mkdir -p "$DST/tools"          "$DST/ops/monitoring/prober"          "$DST/ops/monitoring/alertmanager"
# 移送（上書きOK）
rsync -a "$SRC/seed.sh"            "$DST/tools/"
rsync -a "$SRC/logbook_commit.py"  "$DST/tools/"
rsync -a "$SRC/smoke.py"           "$DST/ops/monitoring/prober/"
rsync -a "$SRC/am_test.sh"         "$DST/ops/monitoring/alertmanager/"
# 実行権（必要なものだけ）
chmod +x "$DST/tools/seed.sh"          "$DST/ops/monitoring/alertmanager/am_test.sh"
# ざっと確認
echo "----- verify moved -----"
ls -l "$DST/tools/seed.sh"       "$DST/tools/logbook_commit.py"       "$DST/ops/monitoring/prober/smoke.py"       "$DST/ops/monitoring/alertmanager/am_test.sh"
# 位置合わせ（今ある場所を起点）
SRC="$HOME/halu-dev.migrated.20251006-151256"
mkdir -p "$HOME/.config/daegis" "$HOME/daegis/ops/hosts/Fs-MacBook-Pro.local"
# .env を秘密保管に移動（編集用の実体）
[ -f "$SRC/.env" ] && mv "$SRC/.env" "$HOME/.config/daegis/.env.local" && chmod 600 "$HOME/.config/daegis/.env.local" || true
# 置き換えサンプル（秘密は伏せる）
cat > "$HOME/daegis/ops/hosts/Fs-MacBook-Pro.local/.env.example" <<'ENV'
rm -f "$SRC/.gitignore"
/bin/bash --noprofile --norc -lc '
set -euo pipefail

SRC="$HOME/halu-dev.migrated.20251006-151256"
DST="$HOME/daegis"

# 1) 置き場作成
mkdir -p "$DST/ark/logbook" \
         "$DST/ops/hosts/Fs-MacBook-Pro.local/mosquitto" \
         "$DST/poc/app"

# 2) logbook を ark へ（階層そのまま移送）
if [ -d "$SRC/logbook" ]; then
  rsync -a "$SRC/logbook/" "$DST/ark/logbook/"
fi

# 3) mosquitto.conf をホスト別のサンプルへ
if [ -f "$SRC/conf/mosquitto.conf" ]; then
  cp "$SRC/conf/mosquitto.conf" \
     "$DST/ops/hosts/Fs-MacBook-Pro.local/mosquitto/mosquitto.conf.sample"
fi

# 4) PoC用アプリを poc へ
if [ -f "$SRC/app/main.py" ]; then
  rsync -a "$SRC/app/main.py" "$DST/poc/app/main.py"
fi

# 5) ゴミ/隠し物の掃除（安全版）
cd "$SRC"
rm -rf .git .githooks .github .ruff_cache .DS_Store __pycache__ 2>/dev/null || true

# 6) 残りを一覧（消す前の最終確認用）
echo "----- leftovers in $SRC -----"
find "$SRC" -mindepth 1 -maxdepth 2 -print | sed -n "1,200p"

# 7) Ward にメモ
WARD="$DST/ops/ward/Daegis-Ward.md"
[ -f "$WARD" ] && {
  BK="$WARD.$(date +%Y%m%d-%H%M%S).bak"; cp "$WARD" "$BK"
  {
    echo
    echo "## Migration note (halu-dev backup → daegis) $(date -Is)"
    echo "- moved: logbook → ark/logbook/"
    echo "- sample: mosquitto.conf → ops/hosts/Fs-MacBook-Pro.local/mosquitto/mosquitto.conf.sample"
    echo "- moved: app/main.py → poc/app/main.py"
    echo "- cleaned: .git, .github, .githooks, caches"
  } >> "$WARD"
  echo "[Ward] updated → $WARD (backup: $BK)"
}

echo "[done] Review the leftovers above. If nothing needed, you can remove the folder:"
echo "      rm -rf \"$SRC\""
'
rm -rf ~/halu-dev.migrated.20251006-151256
ls -R ~/daegis/ark/logbook | head -40
ls ~/daegis/ops/hosts/Fs-MacBook-Pro.local/mosquitto
ls ~/daegis/poc/app
# どこにあるか確認
test -f ~/.config/daegis/.env.local && echo "[ok] found ~/.config/daegis/.env.local" || echo "[NG] no ~/.config/daegis/.env.local"
ls -l ~/.config/daegis/.env.local 2>/dev/null || true
# daegis 配下やホームに .env が他に残ってないか（見つかったらパスを表示）
grep -RIl --exclude-dir=.git --exclude-dir=venv --exclude-dir=.vscode   -e '^MQTT_' -e '^SLACK_' -e '_KEY=' -e '_TOKEN=' ~ 2>/dev/null | sed -n '1,50p'
