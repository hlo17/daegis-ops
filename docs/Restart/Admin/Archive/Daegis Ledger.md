---
tags:
  - Memory_Records
aliases:
created: 2025-09-27 04:15
modified: 2025-10-02 20:02
Describe: "Decision Scribe、決定台帳: 判断や合意を“1行ずつ”追記していく一次原本（後でLogbook等に反映）"
Function: MQTT経由で流れてくる決定情報をMarkdown等に自動保存するロガー。Logbookと連携して「決定履歴」を確実に残す
Derivative from: "[[Master Map]]"
Export: python3 ~/daegis/ops/bin/mdput_clip.py "Daegis Ledger.md" --clean --from-clip
---


## Core & Naming (命名・体系整理)
 2025-09-27: コンポーネント命名整理 — Mosquitto → Daegis Bus（メッセージ基盤）、Decision Scribe → Daegis Ledger（このノート）、Raspberry Pi常駐 → Daegis Raspberry Node、監視カテゴリ → Daegis Observability。
 2025-09-27: 情報体系を再編（Daegis Memory Records / Core Agents / Infrastructure / Observability / Services & Tools / Integration / Vision Roadmap / Daegis Lexicon） — Obsidianタグ運用に合わせて整理。
 2025-09-27: ハンドオフ運用を確立（Daegis AI Handoff + Daegis Ledgerの2本柱） — 次チャット引き継ぎを最短化。
 2025-09-28: Decision Frameに“迷ったらSentryで観測”とNOGO基準を明文化 — 初動と判定を標準化。
 2025-09-28: 進行中タスク欄を「Active Tasks」に統一 — チェックボックス運用と語感を一致。

## Infra & Monitoring (インフラ・監視)
 2025-09-27: Grafana を /grafana サブパスで本稼働 — Caddy handle_path /grafana/* > localhost:3000 を採用、Cloudflare Accessのアプリ/ポリシーを適用し外部ログイン確認。
 2025-09-27: Grafana DataSource “Prometheus” を既定化（prometheus.yml のみ有効）、ダッシュボード “Daegis · Infra Monitoring” を作成（up / CPU / Mem / Net I/O / Disk I/O）、デフォルト時間範囲をLast 6 hoursに更新。
 2025-09-27: Caddy 設定を固定化（/grafana を reverse_proxy、/health 応答、ルートの自動リダイレクトは無効） — セッション崩れ回避。
 2025-09-27: Grafana admin パスワードを強化 — 運用セキュリティを最低ラインへ引き上げ。
 2025-09-28: Alertmanager → Slack (#daegisalerts) 貫通テスト成功 — AlwaysFiringルールで即時発火 → Slack "Smoke test" 受信 → Resolved確認。
 2025-09-28: Prometheus設定事故（evaluation_interval二重定義）を復旧、最小良形に正規化。
 2025-09-29: Mosquitto設定ファイルを最小構成に戻して再起動成功 — 重複キーや無効設定で起動失敗していたため。
 2025-09-29: MQTT ユーザ f・factory・luna の passwd/ACL を再生成 — 認証失敗を解消するため。
 2025-09-30: Mosquitto ACL に factory/research/result と status/research を追加 — reject通知と結果カードのUI反映に必須。
 2025-10-02: Mosquitto復旧・ACL再設定 — 再起動後に認証/ACL不整合を解消。

## Ops & Tools (運用・ツール)
 2025-09-28: Sentry（観測ハーネス）を確定導入 — relay→fallback購読→ledger待ちの三段でGO/NOGO判定。
 2025-09-28: Sentryの購読フォールバックを“安全クォート版（pat方式）”で有効化 — zshのクォート崩れ回避。
 2025-09-28: 実行粒度ルール（ブロック実行/行ごと実行）を正式採用 — 貼り付け事故低減のため。
 2025-09-28: クォート運用（外側”…”/内側\"、'は閉じ→展開→再開）を標準化 — SSH×JSONの安定化。
 2025-09-28: 文字化け対策（CRLF/BOM/ZWSP掃除＋bash n）を固定手順化 — 貼り付け起因の不具合防止。
 2025-09-28: Runbook体系を整備（operations.mdにSentry自動埋め込み、commandexecutionguide.md、daegismap.md） — 運用知見の一元管理。
 2025-09-28: ops/sentry/sentry.sh を正式配置し実運用開始 — 観測と切り分けを自動化。
 2025-09-28: .gitignoreを整備（logs/bundles等を除外） — 機密/生成物の誤コミット防止。
 2025-09-28: GitHubリポジトリhlo17/daegisopsを初期化・push完了 — RunbookとSentryの共有運用開始。
 2025-09-28: sentryシェル関数を追加（PROMPT一発実行） — 観測の起動時間短縮。
 2025-09-28: link_resolver.pyでcontext_bundle.txt生成運用を確立 — 新チャットへの文脈引き継ぎを定型化。
 2025-09-29: gemini_runner.py の不可視文字を一括除去 — Python構文エラーの恒久対策。
 2025-09-29: 全 .py をクレンジングスクリプトで走査 — venv含む依存ライブラリの不具合を防止。
 2025-09-29: researchlistener.sh を systemd 常駐化 — Pi再起動後も自動でMQTT購読が開始されるようにした。
 2025-09-30: researchlistener.sh に task_id抽出・ACK返却・DAG呼び出しを実装 — approve/rejectの処理基盤が完成。
 2025-09-30: runresearch.sh に resultカード生成・MQTT publish を実装 — PoC用QAスコア・要点サマリ付きカードを出力。
 2025-09-30: gemini_runner.py を systemd 常駐化 — approve時は result、reject時は status に正常発行する頭脳を確立。
 2025-09-30: UI factoryresult.html を作成 — result/status をWebカードとして即時表示できる仕組みを導入。
 2025-09-30: SSHトンネル（Mac→Pi 1883）を確立し疎通テスト成功 — Piを外部公開せずMacからローカルMQTTに直結可能。
 2025-09-30: researchfactory.service を作成・常駐化 — mRNA DAGワーカーをPi上で稼働。
 2025-09-30: System Topology を再定義（Solaris/Luna/Ark をMapに正式編入、ResearchFactoryを前面化）。
 2025-09-30: PoC完了 — researchfactory.service の起動ループ、runresearch.sh の JSON/pub の問題をすべて解決し、MacPi間のE2Eワークフローを確立。
 2025-10-02: staging_up_and_smoke.sh に env_file 検査を実装 — 初回実行の事故削減と再現性確保。
 2025-10-02: scripts/lint.sh を作成（promtool + yq をDocker経由で実行） — インストール不要のLintを標準化。
 2025-10-02: Pi の SSH を恒常運用へ移行（sshd 有効化） — iPad/無線からの保守チャネルを確立。
 2025-10-02: 外部モニタ運用を映像/給電の分離（MagSafe直挿し）に変更 — 発熱と安定性を改善。
 2025-10-02: Mac+iPad併用ポリシー導入 — 並行作業効率と認知切替を高めるため（実務=Mac／発想=iPad）。
 2025-10-02: Map v3.6更新（円卓原則統合、役割整理v3.6採用） — 鍛冶師強調で実装効率化



### 月次サマリー (20250930 直近30日)
 Grafana / Caddy / Cloudflare Access を導入し、外部公開の最小構成を確立。
 ダッシュボード基盤を Prometheus + Grafana で整備し、可視化指標を標準化。
 メッセージ基盤を Daegis Bus（Mosquitto） に確立し、ACLと認証を導入。
 意思決定記録を Daegis Ledger に統合、ハンドオフ運用を確立。
 Sentry（観測ハーネス）導入により、Relay→Fallback→Ledger の観測ループを構築。
 Slack通知・GitHubリポジトリ・Runbook体制を整備し、事故防止の仕組みを導入。



### 更新メモ
 2025-10-02: 複数Ledgerファイルを統合。重複除去し、日付順に整理。AI引き継ぎ用に月次サマリー追加。追加漏れなし（全エントリマージ完了）。
 次アクション: Alertmanager Slack貫通とScribe dedupe恒久化を優先。

2025-10-03: Mosquitto起動成功・認証テスト完了
2025-10-03: Citadel P1暗号化成功・drop-in適用
2025-10-03: Citadel P1 公開鍵配布（fingerprint=578E89F73B61D1F15A3F104F36EBC7AE5C425521, keyid=36EBC7AE5C425521）。
  - 公開鍵: ~/daegis/citadel/citadel_pubkey.asc
  - 備考: 秘密鍵はfユーザーの~/.gnupgに保管。バックアップ未実施。

2025-10-03: Halu Relay Event Subscriptions有効化・中継テスト成功
  - Mosquitto認証/ACL整合 → 成功
  - halu-relay.service 常駐化 → 稼働中
  - Slack↔MQTT 双方向中継テスト → OK

2025-10-03 halu_relay.py 復旧・サービス再稼働・スナップショット保存・GitHub 反映済

2025-10-03 円卓RT MVP 接続 / リレー内プロキシ化 / モック投票E2E
- RT 経路: Cloudflare → relay:8000 → (rt_proxy) → roundtable:8010。Nginx 未使用（将来 WAF/Rate 時に差し込み）。
- relay 側: rt_proxy.py を追加し app.include_router() で /rt/* を内部プロキシ化。
- roundtable: FastAPI MVP 稼働（/health, /orchestrate）。G1（投票・選出）+ G2（圧縮→仲裁）を接続。
- E2E: /rt/orchestrate にて votes 集計・coordinator 選出・arbitrated 生成を確認（mock）。
- 運用: スナップショット timer 稼働、復旧手順・ヘルス監視 OK。費用最適化のため外部API直結は段階導入。
- 次アクション: Slack /roundtable の入口連携、相関ID=Slack TS で Ledger 記録、Grok/ChatGPT/Perplexity の実API結線（A/B/C 仕様準拠）。

JSONL をもう少し役立つ“台帳”にします。以下の 4 フィールドを追記推奨です。
    •    arb_backend: "openai" 固定（今）。
    •    rt_agents: 実行時の RT_AGENTS スナップショット。
    •    latency_ms: 仲裁の処理時間（簡易）。
    •    status: "ok" / "fallback" / "error" など。
    
    
タイトル: RT JSONL拡張の暫定復旧（_orch_log2 経由でappend-only）
What we changed
    •    orchestrate_patch.py に _orch_log2 を追加し、既存 _orch_log 呼び出しを差し替え（既存関数は try で呼び出し、失敗時握りつぶし）。
    •    追記先: /var/log/roundtable/orchestrate.jsonl
    •    追加フィールド: arb_backend, rt_agents, latency_ms, status（summary_len は算出）

Why
    •    既存 _orch_log 側の体裁・依存が不安定なため、append-only & 最小責務の安定ロガーを併設して可観測性を確保。

How to verify
```
TASK="Ledger selfcheck"
curl -sS -X POST http://127.0.0.1:8010/orchestrate -H 'content-type: application/json' -d "{\"task\":\"$TASK\"}" >/dev/null
jq -c --arg t "$TASK" 'select(.task==$t)' /var/log/roundtable/orchestrate.jsonl | tail -1
```

Rollback
    •    git checkout -- orchestrate_patch.py で戻せます。

Risks
    •    ログ2重化（_orch_log と _orch_log2）が同時成功すると二重エントリ化の可能性 → 当面 task で dedup して集計。
    
    {
  "ts": "<UTC_ISO8601>",
  "area": "Daegis Roundtable",
  "category": "stability-patch",
  "summary": "orchestrate.jsonl に拡張フィールド（arb_backend/rt_agents/latency_ms/status）を安全に追記するラッパー _orch_log2 を導入。/circle リレーは 8082 常用に変更、8081 の常駐プロセス（command-room.service）を無効化・マスク。",
  "changes": [
    "Add _orch_log2() wrapper and switch call sites from _orch_log()",
    "Measure latency_ms with _t0/_lat around arbitration",
    "rt-slash.service: ExecStartPre=-/usr/bin/fuser -k 8082/tcp",
    "Disable & mask command-room.service (freed 8081)"
  ],
  "verification": [
    "POST /orchestrate returns OK within budget",
    "orchestrate.jsonl includes non-null arb_backend/rt_agents/latency_ms/status",
    "curl /slack/roundtable on 8082 returns JSON echo"
  ],
  "notes": "Base file restored via git checkout before patching to avoid indentation/syntax drift.",
  "owner": "ops",
  "status": "completed"
}

Ledger 追記（今回の修復エントリ雛形 JSON）

そのまま ChangeLog に貼れます。
{
  "ts": "<AUTO>",
  "corr_id": "<AUTO>",
  "category": "hotfix",
  "component": ["DRB-Orchestrator", "Relay-Slash"],
  "summary": "JSONL拡張フィールドの未記録を _orch_log2 追加で暫定復旧。Slash 8082常駐化および8081常駐プロセス排除。",
  "details": {
    "orchestrator": {
      "change": "orchestrate_patch.py に _orch_log2 を追加し既存呼び出しを差し替え。append-only で arb_backend/rt_agents/latency_ms/status を記録。",
      "path": "/var/log/roundtable/orchestrate.jsonl"
    },
    "relay": {
      "port": 8082,
      "unit": "rt-slash.service",
      "execstartpre": "fuser -k 8082/tcp (ignore-fail)",
      "legacy_8081": "command-room.service を停止・disable・退避・mask"
    }
  },
  "verification": {
    "routes_check": "GET /rt_routes で /orchestrate が orchestrate_patch を指すこと",
    "log_check": "jq で task=Ledger selfcheck を抽出して拡張フィールド確認"
  },
  "impact": {
    "observability": "latency_ms と backend 可視化が復旧",
    "risk": "一時的に二重ログの可能性あり"
  },
  "status": "applied",
  "by": "ops"
}

主題（タイトル）候補
    •    orchestrate: no_proposals 500 を暫定無害化 + ASGI 低コスト計測を導入
    •    roundtable/orchestrate: mw_log 導入と no_proposals フォールバック
    •    observability & continuity: /orchestrate の常時JSONL追記 + 200最小レス確保
    
```
{
  "ts": "2025-10-03T15:02:52Z",
  "area": "roundtable/orchestrate",
  "subject": "no_proposals 500 を暫定無害化 + ASGI mw_log で常時記録",
  "change": [
    "ASGI middleware (mw_log) を最外層に追加し、/orchestrate POST ごとに JSONL 1行追記（status=ok/error, latency_ms を含む）",
    "arbitrate 前の guard を追加（compressed==[] の場合は HTTP 200 + 最小レスポンスを返却）",
    "grep 誤検知対策として、JSON のコロン後スペースを許容する正規表現に運用コマンドを修正"
  ],
  "reason": "ValueError('no proposals') により 500 が発生し、パイプラインの欠測と監視抜けが生じていたため。常時記録と最小成功で運用継続性を確保。",
  "files": [
    "/home/f/daegis/roundtable/_rt_mw_log.py",
    "/home/f/daegis/roundtable/app.py",
    "/home/f/daegis/roundtable/orchestrate_patch.py"
  ],
  "commands_run": [
    "curl -sS -X POST :8010/orchestrate -H 'content-type: application/json' -d '{\"task\":\"Ledger selfcheck\"}'",
    "grep -E '\"source\"[[:space:]]*:[[:space:]]*\"mw_log\"' /var/log/roundtable/orchestrate.jsonl | tail -n 3",
    "tail -n 1 /var/log/roundtable/orchestrate.jsonl | jq '{ts,source,status,latency_ms}'"
  ],
  "verification": {
    "http_200": true,
    "jsonl_append": true,
    "examples": [
      {"ts": "2025-10-03T14:54:23.108199+00:00", "source": "mw_log", "status": "error", "latency_ms": 2},
      {"ts": "2025-10-03T14:58:05.671511+00:00", "source": "mw_log", "status": "ok", "latency_ms": 0},
      {"ts": "2025-10-03T15:02:51.859612+00:00", "source": "mw_log", "status": "ok", "latency_ms": 1}
    ]
  },
  "metrics_baseline": {
    "window": "last_200_lines",
    "mw_log_status_counts": {"ok": 2, "error": 1}
  },
  "next_actions": [
    "vote_all → compress_proposal の upstream で空配列になる要因の恒久修正",
    "arbitrate の入力検証を強化（空入力時に dict{summary_len:0,note:'no_proposals'} を返す安全実装）",
    "systemd: UMask=002 と /var/log/roundtable パーミッション固定"
  ],
  "rollback": [
    "upstream 修正後にフォールバック削除（ガード箇所）",
    "json.dumps の separators をデフォルトへ戻す場合は grep 側の空白許容を維持"
  ]
}
```

使い回し用テンプレ
```
{
  "ts": "<UTC ISO8601>",
  "area": "<system/component>",
  "subject": "<concise change title>",
  "change": ["<what changed #1>", "<what changed #2>"],
  "reason": "<why now / impact>",
  "files": ["</abs/path/file1>", "</abs/path/file2>"],
  "commands_run": ["<cmd1>", "<cmd2>"],
  "verification": {
    "http_200": true,
    "jsonl_append": true,
    "examples": [{"ts": "<...>", "source": "<mw_log|...>", "status": "<ok|error>", "latency_ms": 0}]
  },
  "metrics_baseline": {
    "window": "last_200_lines",
    "mw_log_status_counts": {"ok": 0, "error": 0}
  },
  "next_actions": ["<follow-up #1>", "<follow-up #2>"],
  "rollback": ["<how to revert>"]
}
```

「/orchestrate 安定化：no_proposals フォールバック＋ASGI ログ観測
```
{
  "ts": "2025-10-03T15:05:00Z",
  "title": "/orchestrate 安定化：no_proposals フォールバック＋ASGI ログ観測",
  "area": "roundtable-api",
  "change": [
    "ASGI middleware `mw_log` を最外層に挿入し、/orchestrate(POST) を毎回 JSONL 追記",
    "grep/jq フィルタを空白許容に修正（\": \" 形式）",
    "no_proposals（ValueError）を 200 最小レスで返すフォールバック追加"
  ],
  "reason": "500応答で計測が途切れるのを防ぎ、安定した観測/KPI出しを優先",
  "impact": {
    "http_status": "500→200（最小レス）",
    "logging": "毎呼び出し1行、source=mw_log を保証",
    "kpi": ["latency_msが継続計測可", "error件数の可観測化（status=error/ok）"]
  },
  "evidence": {
    "status_counts_cmd": "tail -n 200 /var/log/roundtable/orchestrate.jsonl | jq -r 'select(.source==\"mw_log\")|.status' | sort | uniq -c",
    "p95_cmd": "tail -n 2000 /var/log/roundtable/orchestrate.jsonl | jq -r 'select(.source==\"mw_log\")|.latency_ms' | grep -E '^[0-9]+$' | sort -n | awk 'BEGIN{p=0.95} {a[NR]=$1} END{n=NR; if(n==0){print \"NA\"; exit} i=int(p*n); if(i<1)i=1; if(i>n)i=n; print a[i]}'",
    "last_lines": "grep -E '\"source\":[[:space:]]*\"mw_log\"' /var/log/roundtable/orchestrate.jsonl | tail -n 3"
  },
  "notes": [
    "route_wrap も導入済みだが、観測の出力主体は現状 mw_log",
    "母数N<50時のp95はブレが大きい（暫定値として扱う）"
  ]
}
```

{
  "ts": "2025-10-03T15:06:00Z",
  "title": "/orchestrate 安定化と観測基盤: mw_log + no_proposals フォールバック",
  "area": "roundtable-api",
  "change": [
    "ASGI最外層に mw_log を挿入し毎呼び出しを JSONL 追記（source=mw_log）",
    "grep/jq フィルタをコロン後スペース許容に修正",
    "no_proposals を 200 最小レスで返すフォールバックを導入"
  ],
  "reason": "500断続により計測が途切れる問題を回避し、KPI算出を安定化",
  "impact": {
    "http_status": "500→200（最小レス可）",
    "logging": "毎回1行追記を保証",
    "kpi": ["latency_ms 継続観測", "status(ok/error) 可視化"]
  },
  "evidence": {
    "status_counts": "ok:2 / error:1（直近）",
    "p95": "Data insufficient (n=3)",
    "grep": "grep -E '\"source\":[[:space:]]*\"mw_log\"' /var/log/roundtable/orchestrate.jsonl | tail -n 3"
  },
  "next": [
    "rt-digest.timer(Persistent=true) を有効化（09:05）",
    "N>=50 になるまでは“Data insufficient”をSlackに出す",
    "検索トリガーは allow/deny + ヒステリシス（ON35%/OFF25%）",
    "画像（p95折れ線）はデータ安定後に追加"
  ]
}

{
  "ts": "2025-10-04T00:20:00+09:00",
  "scope": "roundtable",
  "change": "daily_digest_setup",
  "why": "JSONLのmw_logベースKPIを定時配信（初期データ不足を安定ハンドリング）",
  "details": {
    "files": [
      "/usr/local/bin/rt-digest.sh",
      "/etc/systemd/system/rt-digest.service",
      "/etc/systemd/system/rt-digest.timer",
      "/etc/roundtable/search_filter.v1.json"
    ],
    "timer": {"OnCalendar": "09:05", "Persistent": true},
    "digest": {"window_n": 400, "p95_when_n_lt_50": "Data insufficient (n=...)"},
    "grep_fix": "jsonのコロン後スペースを考慮して '\"source\"[[:space:]]*:' で抽出",
    "status_sample": {"ok": 2, "error": 0},
    "notes": [
      "allow配列の '出典' の先頭スペースを削除（マッチ率改善）",
      "Slackは環境変数 SLACK_WEBHOOK_URL を設定で即有効化可能"
    ]
  }
}



2025-10-03: route_wrap / **mw_log** を導入 — `/orchestrate` の JSONL 追記を二重化し、観測を安定化。  
2025-10-03: **no_proposals** 時は 200 の最小レスで返すフォールバックを採用 — 500断続を止血し、KPIの連続観測を優先。  
2025-10-04: `/usr/local/bin/rt-digest.sh` を新規作成 — ok/error 集計と p95 算出（n<50 は “Data insufficient”）。  
2025-10-04: `rt-digest.service/timer`（09:05, Persistent=true）を導入 — 日次ダイジェストを定時配信。  
2025-10-04: `search_filter.v1.json` の「出典」表記ゆれを修正 — マッチ率を改善。  
2025-10-04: `RT_DEBUG_ROUTES=0` を既定化 — ルート一覧のデバッグ出力を停止し、ログ/表層APIを静穏化。  
2025-10-04: Slack Webhook は **環境変数注入**方式に統一 — `SLACK_WEBHOOK_URL`（権限制御＋UMask=002）で運用。
