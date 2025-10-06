# Daegis Handoff — 2025-10-04

## Scope & Audience
**Scope**: Haluパイプライン（Broker → Relay → Scribe → Ledger/Slack）の安定化、運用基盤整備（Sentry / Runbook / GitHub）。E2Eフロー（Mac → Pi → result publish）確立と次フェーズ移行。端末連携（Mac=実務 / iPad=発想）と通知貫通。  
**Audience**: 次担当者・ChatGPT（引き継ぎ前提）。

---

## 現在完了
- **E2Eフロー確立**：Mac → (WSS/SSH) → Pi mosquitto → `gemini_runner.py` → `researchlistener.sh` → `runresearch.sh` → 結果カード publish。
- **常駐化**：`geminirunner.service` / `daegisresearchlistener.service` / `researchfactory.service` 稼働中。
- **安定化完了**：Mosquitto復旧、不可視文字クレンジング、JSON構文エラー根治、task_id 抽出 / ACK / DAG起動、reject 通知経路を整備。
- **運用基盤**：Sentry 観測ハーネス（relay ログ → Ledger 待ち）／Scribe `DEDUPE_OFF=1` drop-in／Ledger id 反映／Runbook 自動埋め込み／GitHub push 済（`hlo17/daegisops`）。
- **端末連携**：Mac=実務/検証、iPad=発想/会話。Universal Control による並行作業。
- **PoC完了**：承認メッセージ（approve/reject）でワーカー起動→結果返却までの E2E を確認。
- **システム安定化**：`researchfactory.service` 起動ループ、`runresearch.sh` JSON エラー等 Pi 側バグ解消。
- **Sentry（観測ハーネス）**：relay ログ → 購読フォールバック → Ledger 待ち（再試行付き）で GO/NOGO 判定。
- **Scribe**：`DEDUPE_OFF=1` systemd drop-in 有効（起動ログ `DEDUPE_OFF=True` 表示）。
- **Ledger**：`answersYYYYMMDD.jsonl` に id 反映・Sentry 待ち確認。
- **Runbook**：`ops/runbooks/operations.md` に Sentry セクション自動埋め込み（BEGIN/END マーカー）。
- **GitHub**：`hlo17/daegisops` 新設、Runbook / Notes / Sentry push 済。
- **link_resolver.py**：`context_bundle.txt` 生成フロー確立（新チャット引き継ぎ用）。

    •    MQTT 認証/ACL/ユニット整備（bot_oracle/halu 稼働、相関ID往復OK）。
    •    oracle-bridge.py：heuristic + verdictモード 実装・稼働。
    •    halu-bridge.py：方針3行の安定出力。
    •    slack2mqtt（FastAPI）常駐：/slash/halu /slash/oracle 受け付け→MQTT 連携。
    •    Cloudflare named tunnel で bridge.daegis-phronesis.com を FastAPI にリバース。
    •    運用ワンライナー（tell-halu/tell-oracle）の整備。


---

## 次にやる
    1.    RAG v0（SQLite FTS5 で Top3 根拠を付与）を Halu に接続。
    2.    評価保存の固定：daegis/feedback/<agent> へ JSON 1行/件、DuckDB/Parquet にも蓄積。
    3.    Oracle verdict の集計（✅/⚠️/❌ 比率と相関 ID で突合）。
    4.    来週：LoRA“型矯正”ミニ学習（label=✅/🛠(修正後) 500〜1,000件、A/Bで採否）。
    
- **通知貫通**：Alertmanager → Slack `#daegisalerts`（最低 1 イベント）。
- **Proactive PoC**：`up == 0` の即時通知（価値アラート）。
- **Scribe dedupe 恒久化**：TTL / N 分スコープ方式へ再設計。
- **DAG 拡張**：ResearchFactory DAG の Synth / QA ステージ実装。
- **AutoQA**：ルーブリック確定・スコア根拠ログ追加。
- **UI**：`daegis/ui/*` で result / status Web カード常時表示。
- **Citadel 設計**：機密管理（鍵/シークレット集中管理）。
- **WSS 購読 / SSH トンネル運用定着**：Handoff / Ops に反映。
- **Runbook 週次見直し**：Sentry ブロック自動反映の継続確認。

---

## 現在のリスク
    •    DNS 伝播/Cloudflare 側キャッシュで一時的に 530/解決不能の可能性。
    •    Slack Slash 落ち時の代替動線（MQTT/フォーム）切替手順が口頭依存。
    •    評価データの匿名化ルール未コード化（収集活性化前に最小フィルタ必要）。
- **topic 名不一致**：`plan/req` 等でワーカー無反応。
- **JSON 壊れ**：listener 側で reject（`jq -e .` 必須）。
- **ACL / パスワード不整合**：更新後の再起動・権限確認の徹底。
- **クォート崩れ**：zsh heredoc / SSH 経由（Sentry 安全版へ統一）。
- **重複判定**：PoC 中 `DEDUPE_OFF=1` のため恒久化が必要。
- **連続貼り付け事故**：**ブロック実行**ルール徹底。
- **実装フェーズ移行**：新規技術課題の顕在化。

---

## Status（運用ポリシー）
**Orchestrator** は「**最小成功で流し続ける**」方針へ移行。  
**Digest** は 09:05 定時、Slack は Webhook 注入待ち。  
（直近：ok=2 / error=0, p95=Data insufficient (n=3)）

---

# Daegis Hand-off（最新版・詳細）

## 現在完了していること
### Roundtable Orchestrator
- `route_wrap` + **`mw_log`** により **/orchestrate** の JSONL 追記が安定（1 req = 1 行）。
- **no_proposals → 200 最小レス** フォールバックで 500 断続を止血。
- `orchestrate.jsonl` に **status / latency_ms** を記録し、KPI に供給。

### Digest バッチ
- `/usr/local/bin/rt-digest.sh` 実装（ok/error 集計・p95 算出、n<50 は “Data insufficient”）。
- `rt-digest.service` / `rt-digest.timer` 導入（**09:05**、`Persistent=true`）で日次実行。
- 手動実行で出力確認済み。

### フィルタ / 設定
- 検索フィルタ JSON（`/etc/roundtable/search_filter.v1.json`）の **「出典」先頭スペース** を修正。
- 監視ノイズ低減のため `RT_DEBUG_ROUTES=0` を既定化。

---

## 次にやること（優先順）
1. `/etc/roundtable/rt.env` に **`SLACK_WEBHOOK_URL`** を設定 → `systemctl restart rt-digest.timer`。  
2. **投稿チャンネル確定**（`#daegis-roundtable` / `#daegis-alerts` のどちらかへ集約）。  
3. ログ件数 **n≥50** 到達後、p95 を定常評価に格上げ（グラフ化はその後）。  
4. 検索トリガー（allow/deny + ヒステリシス）を Digest 拡張に統合。  
5. 投票/圧縮まわりの例外監視を継続（フォールバック長期稼働の健全性確認）。

---

## 現在のリスク（詳細）
- **ログ件数不足**：p95 の統計的信頼性が未達。  
- **Slack Webhook 保管**：平文リスク → 所有者/権限制御（600/640）＋ `UMask=002`。  
- **フォールバック常用**：恒久対策ではない → 上流（投票/圧縮）の改修計画を別途推進。

---

## Ops Quick Ref

Ops Quick Ref（運用ワンライナー）
    •    Halu：tell-halu "このPRの要約方針を3行で"
    •    Oracle verdict：tell-oracle "eval: この変更の妥当性を評価して"
    •    Slash 疎通：
    •    curl -fsS -X POST -F 'text=…' -F 'response_url=http://127.0.0.1:8787/dev/null' http://127.0.0.1:8787/slash/halu
    •    FastAPI サービス：systemctl --user restart daegis-slack2mqtt.service
    •    Cloudflared：sudo systemctl restart cloudflared-bridge.service
    •    MQTT 単発受信：timeout 6s mosquitto_sub -h 127.0.0.1 -p 1883 -u f -P nknm -t 'daegis/events/#' -F '%t\t%p'
- **手動 Digest**：`/usr/local/bin/rt-digest.sh`  
- **タイマー確認**：`systemctl status rt-digest.timer`  
- **JSONL 末尾確認**：`grep -E '"source'[[:space:]]*:' /var/log/roundtable/orchestrate.jsonl | tail`

### DAG（監視フェーズ）
RT Agents → Orchestrator (`/orchestrate`) → **mw_log**(JSONL) → **digest.sh**(集計) → **systemd timer (09:05)** → Slack 通知

---

## Snapshot（5行）
- **Sentry**：relay ログ → 購読フォールバック → Ledger 待ち（再試行つき）で GO/NOGO。  
- **Scribe**：`DEDUPE_OFF=1` drop-in 有効（ログ `DEDUPE_OFF=True`）。  
- **Ledger**：`answersYYYYMMDD.jsonl` に id 反映・Sentry 待ち。  
- **Runbook**：`ops/runbooks/operations.md` に Sentry 自動埋め込み。  
- **GitHub**：`hlo17/daegisops` へ Runbook / Notes / Sentry を push 済。

---

## Active Tasks
- [ ] Alertmanager → Slack（`#daegisalerts`）最小 1 件貫通  
- [ ] Proactive Engine PoC：`up == 0` 即時通知  
- [ ] Scribe dedupe 恒久化（当日スコープ / TTL）、pre-dedupe の除去検討  
- [ ] Runbook 週次見直し（Sentry 自動反映の継続確認）

---

## 参照（主要ノート / 実装物）
- **Runbook**：`ops/runbooks/operations.md`, `ops/runbooks/commandexecutionguide.md`, `ops/runbooks/daegismap.md`  
- **Sentry**：`ops/sentry/sentry.sh`  
- **共有**：GitHub `hlo17/daegisops`  
- **監視系**：Grafana（`/grafana/`、Caddy 配下、Cloudflare Access 経由）／Prometheus／Alertmanager（Slack 配線中）／Caddy（`/ → /grafana/` 308 回避、`/health=200`）／Cloudflare Access（allowself 優先）

---

## Operational Notes
- **Terminal Hygiene**：ヒアドキュメント・SSH 内シェル・多段クォート・長置換は **ブロック実行** を厳守。単発 `export` / `chmod` / `bash -n` / `systemctl` / `journalctl` は行ごとで可。  
- **クォート規則**：外側 `"..."` ／内側 `\"`。`'` が必要な場合は `'<lit>'"$VAR"'<'lit>'`。  
- **Sentry 使い方**：`sentry "テキスト"`（`.zshrc` 関数済）。  
- **WSS 購読**：`npx mqtt subscribe -h mqtt.daegisphronesis.com -p 443 --protocol wss -t '<topic>' -u factory -P 'nknm'`  
- **SSH トンネル（Mac→Pi 1883）**：`ssh -N -L 1883:127.0.0.1:1883 roundtable`  
- **疎通テスト（Pi ローカル）**：`mosquitto_pub -h 127.0.0.1 -p 1883 -u f -P 'nknm' -t 'daegis/test' -m 'pong'`  
- **映像連携**：USB-C 直結、給電は別口（MagSafe/純正 AC）で分離（発熱低減）。  
- **Universal Control**：隣接配置＋エッジ越え。不安定時：同一 Apple ID / Wi-Fi / Bluetooth / Handoff ON、再起動→再ログイン。

**Ops ワンライナー**
- staging 起動＋待機＋スモーク：`/tmp/staging_up_and_smoke.sh`  
- lint（インストール不要）：`~/monitoringstaging/scripts/lint.sh`  
- docs 出力：`source ~/daegis/ops/tools/mdio.sh ; mdput / mdappend`  
- 構成表示：`tree -a -I '.git|node_modules|__pycache__' -L 3 ~/monitoringstaging`  
- 端末連携：映像=USB-C 直結／給電=MagSafe 分離。Universal Control は隣接配置＋エッジ越え。  

---

## ResearchFactory DAG（要約）
- **入力**：`daegis/factory/research/out`（runner からの承認済タスク）  
- **段階**：`plan → fanout → synth → qa → publish`  
- **中間トピック**：`<stage>/req` / `<stage>/res`（JSON スキーマは Handoff「DAG 仕様」を参照）  
- **失敗時**：`daegis/status/research` へ `{task_id, stage, reason, at}` を QoS1 / retain で通知  
- **完了**：`daegis/factory/research/result` へカード JSON（retain）

---

## 付録：実行ブロックの頼み方テンプレ
**よく使う定型フレーズ**
1) 単一ファイル上書き（mdput）  
> 「**Handoff を最新版で上書き。mdputブロックで返して**」  
オプション：保存先 Obsidian／明示ファイル名（例：`Daegis Handoff YYYYMMDD.md`）

2) 単一ファイル追記（mdappend）  
> 「**Ledger に以下を追記。mdappend ブロックで**」＋本文

3) 四文書一括（Handoff=上書き、他=追記）  
> 「**handoff/chronicle/ledger/map の4つ、Handoffは上書き・他は追記の実行ブロックを**」

4) Pi 直実行（heredoc）  
> `researchfactory.service` と `research_factory.py` 配置〜起動

5) SSH 経由配布（Mac→Pi）  
> `ssh roundtable 'bash -s'` で配布→`systemd` reload→restart

6) Ledger 差分自動生成  
> 「**Daegis Ledger.md** の末尾日付以降の確定事項を `YYYYMMDD: 決定 — 一言の根拠` で」

7) WSS/トンネル/疎通テスト集  
> 「**Ops Notes.md に追記する mdappend を**」

**ショートカット例**  
「**Handoff を最新版で上書き。mdputで**」／「**Ledgerに今日ぶんを3行追記。mdappendで**」／「**Pi直：service と script を一撃配置**」

---

## Ledger 差分テンプレ（自動化プロンプト）
> 「**Daegis Ledger.md** の末尾日付を抽出し、それ以降の確定事項を  
> `YYYYMMDD: 決定 — 一言の根拠` の行で出して。重複/撤回はマージ。」

---

## チャット移行：初回メッセージテンプレ
1. 四文書の役割（Map / Chronicle / Handoff / Ledger）と運用原則の要約  
2. **最新 Handoff 全文**（＝本ドキュメント）  
3. **Ledger 直近差分（末尾日付 → 本日まで）**

---

## 運用メモ（2025-10-02）
- 四文書（Hand-off / Ledger / Chronicle / Map）は自動抽出を前提に最小整形。
  - Ledger：日付表記を `YYYY-MM-DD:` に統一。  
  - Chronicle：M0〜M9 の章見出しを付与。  
  - Hand-off：**現在完了 / 次にやる / 現在のリスク** を必須節化。  
  - Map：変更なし。
- `newchat handoff | pbcopy` で新チャット冒頭サマリーを生成（本構造を前提）。
- 日常更新は **Hand-off** を中核に、Ledger/Chronicle/Map は追記更新のみ。
- 運用ルール：  
  - **日常更新**：コピー → `⌃⌥⌘H`（または `handoff-update`）。  
  - **新チャット移行**：`newchat handoff | pbcopy` → 冒頭貼付。  
  - **月末**：Ledger は 30 日超過部分をサマリー化して軽量化。
  
## 2025-10-04 JST — Slack Webhook 整理ルール
- /etc/roundtable/rt.env の `SLACK_WEBHOOK_URL=` は **1行だけ残す**。重複は削除。
- 値は Slack で再発行した最新Webhook URL を使う。
- 引用 `" "` は不要。形式は以下が正：
## 2025-10-04 JST — Digestスクリプト運用ルール
- `/usr/local/bin/rt-digest.sh` は **既知良品テンプレで丸ごと再生成**するのが最優先（置換より安全）。
- 203/EXEC対策：shebang固定 `#!/usr/bin/env bash`、CRLF除去 `sed -i 's/\r$//'`、実行ビット付与。
- Slack投稿はスクリプト末尾の `post_to_slack()` で一元化（冪等・ENV未設定なら無害）。
- ENVは `/etc/roundtable/rt.env`（600, owner=grafana）。変更後は `daemon-reload`→`restart rt-digest.timer`。
- トラブル時：`/usr/local/bin/rt-digest.sh.bak.<epoch>` からロールバック。


## 2025-10-04 JST — rt-digest 実行安定化
- `203/EXEC` 対策として、systemd 側で **bash 経由実行**に固定：
sudo systemctl edit rt-digest.service
[Service]
ExecStart=
ExecStart=/bin/bash -lc ‘/usr/local/bin/rt-digest.sh’
sudo systemctl daemon-reload
sudo systemctl restart rt-digest.timer
- これにより shebang/BOM/改行の差異を無視でき、再発を防止。
- スクリプトは `/usr/bin/env bash` 先頭・CRLF除去・実行bit維持が望ましいが、上記設定で実行自体は安定。
## 2025-10-04 JST — rt-digest 実行安定化（systemd を bash 経由に固定）

まれに発生する `203/EXEC` を回避するため、systemd で **bash 経由実行**に固定する。

**実施手順：**
~~~bash
sudo tee /etc/systemd/system/rt-digest.service >/dev/null <<'UNIT'
[Unit]
Description=Roundtable daily digest

[Service]
Type=oneshot
Environment=UMASK=002
EnvironmentFile=-/etc/roundtable/rt.env
ExecStart=/bin/bash -lc '/usr/local/bin/rt-digest.sh'

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl restart rt-digest.timer
sudo systemctl start rt-digest.service
~~~

**検証：**
~~~bash
systemctl show -p ExecStart rt-digest.service
journalctl -u rt-digest.service -n 50 -o cat
~~~

**備考：**
- スクリプト側は `#!/usr/bin/env bash`・CRLF除去・実行bit維持で運用。
- Slack Webhook は `/etc/roundtable/rt.env`（600, owner=grafana）。変更後は `daemon-reload`→`restart rt-digest.timer`。
### 2025-10-04 JST — Slash /roundtable 運用メモ（relay）
- サービス: `rt-slash.service`（ExecStart=/home/f/relay/venv/bin/python /home/f/relay/slash_roundtable.py）
- 設定: `/etc/roundtable/slash.env`（RT_URL, RELAY_PORT=8123, SLACK_WEBHOOK_URL）
- 健全性: `curl -s http://127.0.0.1:8123/health | jq`
- 疎通: 
  ~~~bash
  curl -sS -X POST http://127.0.0.1:8123/slack/roundtable \
    -H 'content-type: application/x-www-form-urlencoded' \
    --data-urlencode 'text=hello from slash' \
    --data-urlencode 'user_name=f' \
    --data-urlencode 'channel_id=CXXXX'
  ~~~
- もしSlack未着: `systemctl show -p Environment rt-slash.service` で SLACK_WEBHOOK_URL を確認し、下記で単発投稿テスト。
  ~~~bash
  sudo bash -lc 'set -a; . /etc/roundtable/slash.env; set +a; \
    curl -fsS -X POST "$SLACK_WEBHOOK_URL" -H "Content-Type: application/json" \
      -d "{\"text\":\"Slash relay ping ✅\",\"username\":\"Roundtable\",\"icon_emoji\":\":speaking_head:\"}" >/dev/null && echo ok || echo ng'
  ~~~
### E2E: Slack Slash `/roundtable` → Roundtable
- Slack App: Slash Commands → `/roundtable` → Request URL: `https://<relay>/slack/roundtable`
- Staging: `http://<PiIP>:8123/slack/roundtable`
- 検証:
  ~~~bash
  curl -sS -X POST http://127.0.0.1:8123/slack/roundtable \
    -H 'content-type: application/x-www-form-urlencoded' \
    --data-urlencode 'text=hello from slash' \
    --data-urlencode 'user_name=f' \
    --data-urlencode 'channel_id=CXXXX'
  ~~~
- 健全性: `curl -s http://127.0.0.1:8123/health | jq`
- 失敗時: `journalctl -u rt-slash.service -n 100 -o cat` / Webhook直叩き可
## 2025-10-04 JST — Slash Relay 運用固定（systemd + hardening）

- rt-slash.service は **/home/f/relay/venv/python** で起動。
- hardening: `ProtectHome=read-only`, `ProtectSystem=full`, `ReadWritePaths=/home/f/relay /etc/roundtable`

~~~bash
sudo tee /etc/systemd/system/rt-slash.service >/dev/null <<'UNIT'
[Unit]
Description=Daegis Slash Relay (Roundtable)
After=network-online.target

[Service]
EnvironmentFile=/etc/roundtable/slash.env
WorkingDirectory=/home/f/relay
ExecStart=/home/f/relay/venv/bin/python /home/f/relay/slash_roundtable.py
Restart=on-failure
RestartSec=2

# hardening
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=read-only
ReadWritePaths=/home/f/relay /etc/roundtable
UMask=007
LimitNOFILE=8192
StandardOutput=journal
StandardError=journal
UNIT

sudo install -d -m 0755 /etc/systemd/system/rt-slash.service.d
sudo tee /etc/systemd/system/rt-slash.service.d/preflight.conf >/dev/null <<'UNIT'
[Service]
ExecStartPre=/home/f/relay/venv/bin/python -c "import fastapi,requests,uvicorn,multipart"
StartLimitBurst=5
StartLimitIntervalSec=60
UNIT

sudo systemctl daemon-reload
sudo systemctl restart rt-slash.service

# 健全性
systemctl status rt-slash.service --no-pager
curl -fsS http://127.0.0.1:8123/health | jq
~~~ 
### Ward 反映（手動）

    /usr/local/bin/ward-apply.sh

### Ward 反映（自動）

    systemctl enable --now ward-apply.timer
    systemctl status ward-apply.timer --no-pager

### 監視ルール確認（Prometheus）

    curl -fsS http://127.0.0.1:9091/api/v1/rules \
      | jq -r '.data.groups[].rules[]?.name' | paste -sd',' -
