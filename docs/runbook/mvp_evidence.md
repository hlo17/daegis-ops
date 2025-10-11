# Daegis OS MVP Evidence (YYYY-MM-DD)
- Smoke: MISS/HIT/504 ヘッダ抜粋（x-cache / x-corr-id / x-episode-id）
- SAFE: enable/disable ヘッダ差分（x-mode: SAFE）
- Decision Log: LOG_DECISION=0 タスクで無出力を確認
- Decision Ledger: 最新1行（episode_id, corr_id, decision_time, compass_version, event_time, observed_time, intent_hint）
- Alert Hints: :9091/api/v1/rules の hint 出力2本
- **Chronicle Weekly**: `scripts/dev/chronicle_weekly.sh` で週次サマリを追記（VS Code: *Chronicle: Run + Notify (now)*）。`CHRONICLE_SLACK_WEBHOOK` 設定時はSlack通知も送信。`scripts/dev/chronicle_timer_install.sh` で **systemd があれば timer、無ければ crontab** により毎週自動実行（Sun 00:10 UTC）。
- Episodes Tail: `bash scripts/dev/episodes_tail.sh 10` の出力貼付
- Intent breadcrumb: "Intent: Smoke (3 headers)" タスクで X-Intent ヘッダと decision.jsonl の intent_hint を確認
- Review Gate: "Review: Gate (API x3)" でPortGuard / /chat headers(x-episode-id,x-intent) / :9091 hints を一括検証
- Review Gate: PASS（/chat headers + :9091 hints 確認）
- Phase V V1: ethics_check exports verified (2025-10-10 01:44:00)
- Gate: [Compass] metrics label ACTIVE|DORMANT (2025-10-10 01:44:00)
## Evidence Snapshot — 2025-10-09 11:50:45
- Rules groups (:9091):
```
daegis-kpi
```
- Note: Phase II 6 docs appended.
- Rule SHA = 73b61da462e525af46977040ad368d0c60c3c938891fe3f0326af0f829a381d0
- Quorum TTL = 900s via scripts/guard/quorum_safe.sh
- Compass Exporter verified: curl :9091/metrics | grep daegis_compass_intents_total → OK (Phase IV init)

- Audit Link (Phase IV): LEDGER_SHA=88b9b11e623e326bda248192c24a116364f98cdc90affae24b3a96e26ad99a72, GIT_HEAD=846bb3c402b74007ab8d3fc08945ab2528a992bd
- Phase IV Audit Loop completed → Chronicle linked and verified (GATE: PASS)
- Audit Link (Phase IV): LEDGER_SHA=88b9b11e623e326bda248192c24a116364f98cdc90affae24b3a96e26ad99a72, GIT_HEAD=846bb3c402b74007ab8d3fc08945ab2528a992bd
- Audit Link (Phase IV): LEDGER_SHA=88b9b11e623e326bda248192c24a116364f98cdc90affae24b3a96e26ad99a72, GIT_HEAD=846bb3c402b74007ab8d3fc08945ab2528a992bd
- Phase V V1.1: metrics_check verified (2025-10-09T16:56:00Z)
- Gate: [Consensus] score = ABSENT
- Phase VI PoC(dry): Hash-Relay executed (2025-10-09T17:09:00Z)
- Gate: [Hash-Relay] nodes=1 distributed_consistency=UNKNOWN
- Phase VI.1: /hash endpoint enabled and Gate shows distributed_consistency=YES (2025-10-10T02:18:00Z)
- Evidence: bash scripts/dev/review_gate.sh | tail -5 shows [Hash-Relay] nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES

- Snapshot added via scripts/dev/evidence_snapshot.sh

````
## Evidence Snapshot — 2025-10-09T18:42:05Z

**INTENTS:** `chat_answer,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"HOLD","rule_id":"consensus_guard","hint":"score=0.74 < TH=0.8"},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":true,"score":0.7368421052631579,"threshold":0.8,"reason":"LOW_SCORE"},"tuning":null}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=0 drift=0 unknown=1 distributed_consistency=UNKNOWN
```

### F) Review Gate tail
```txt
=== Review Gate: API Validation ===
Port Guard: [FAIL] 8080 not responding
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.

## Evidence Snapshot — 2025-10-09T18:45:52Z

**INTENTS:** `chat_answer,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"PASS","rule_id":"none","hint":""},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":false,"score":0.7058823529411765,"threshold":0.7,"reason":"OK"},"tuning":null}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

### F) Review Gate tail
```txt
=== Review Gate: API Validation ===
Port Guard: [OK] 8080 service running
/chat Headers: [FAIL] header missing
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.

## Evidence Snapshot — 2025-10-09T18:51:16Z

**INTENTS:** `chat_answer,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"PASS","rule_id":"none","hint":""},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":false,"score":0.7222222222222222,"threshold":0.7,"reason":"OK"},"tuning":null}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

### F) Review Gate tail
```txt
=== Review Gate: API Validation ===
Port Guard: [OK] 8080 service running
/chat Headers: [FAIL] header missing
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.


- Env persisted: CONSENSUS_HOLD_THRESHOLD=0.80 via scripts/dev/env_local.sh (UTC 2025-10-09T18:56:04Z)
- VS Code task "Dev: Run (env+clean)" added for one-click startup
- Evidence snapshots can be appended anytime via VS Code task: **Evidence: Snapshot (append)**.
## Evidence Snapshot — 2025-10-09T19:05:35Z

**INTENTS:** `chat_answer,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"PASS","rule_id":"none","hint":""},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":false,"score":0.7619047619047619,"threshold":0.7,"reason":"OK"},"tuning":null}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=0 drift=0 unknown=1 distributed_consistency=UNKNOWN
```

### F) Review Gate tail
```txt
=== Review Gate: API Validation ===
Port Guard: [FAIL] 8080 not responding
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.

## Evidence Snapshot — 2025-10-09T19:21:42Z

**INTENTS:** `chat_answer,plan_create,tool_call,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"HOLD","rule_id":"consensus_guard","hint":"score=0.69 < TH=0.80"},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":true,"score":0.6875,"threshold":0.8,"reason":"LOW_SCORE"},"tuning":{"sla_suggested_ms":600}}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

### F) Review Gate tail
```txt
[QUORUM] [2025-10-09T19:21:43Z] Quorum pending: missing HUMAN SECOND (touch ops/quorum/<NAME>.ok)
[Compass] metrics present: MISSING
[Compass] metrics: ACTIVE
[Consensus] score: PRESENT
[Hash-Relay] nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.


## Minimal Brain L2 / L2+ 定義（確定）
L2 Minimal Brain = {Observe: latency/intent, Classify: PASS/HOLD/FAIL, Record: ledger.ethics+provider, Count: per-intent counters} — 一次脳のみがカウント。
L2+ = L2 + EWMAベースの `tuning.sla_suggested_ms` を出力（Prometheus有効時は Gauge）。書込は ledger直前・一次脳のみ。

### L2+ パラメータ
α=0.3, k=1.2, clamp=[500,8000]ms（p95追加レイテンシ≤1ms目安）

### INTENTS Allowlist（最終）
chat_answer, plan_create, tool_call, retrieval, quorum_review, audit_link, config_update, other（未知は other 集約）

### known_good & 帰還SLO
P1=5分 / P2=30分。復帰手順は Runbook ドリル節を参照（復帰後は Evidence Snapshot を追記）。

### 10分デモ台本（固定）
Port Guard → /chat（ledger確認）→ /metrics dormant解説 → `python -m pip install prometheus-client` でFlip → 厳格SLAでHOLD発生 → `hash_relay.sh` → Evidence Snapshot → Review Gate PASS

### スロットル運用（Rate-limit v2）
単一セッション・Diffのみ・1タスク=1ファイル=≤60行・60s→120s→180sバックオフ・失敗1回でフォールバック（ChatGPT等）

- **Federated Consistency**: `Audit: Federate (15m loop)` を実行し、Hash-Relay で `distributed_consistency=YES` を24h継続（KPI: drift=0/24h）。
- **Reflex Alerts**: HOLD 3連続 or 5xx 2連続で `logs/alerts.log` に通知（Slackは `ALERT_SLACK_WEBHOOK` 設定時）。

`````
## Evidence Snapshot — 2025-10-09T19:31:05Z

**INTENTS:** `chat_answer,plan_create,tool_call,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"HOLD","rule_id":"consensus_guard","hint":"score=0.72 < TH=0.80"},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":true,"score":0.7222222222222222,"threshold":0.8,"reason":"LOW_SCORE"},"tuning":{"sla_suggested_ms":600}}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

### F) Review Gate tail
```txt
[QUORUM] [2025-10-09T19:31:06Z] Quorum pending: missing HUMAN SECOND (touch ops/quorum/<NAME>.ok)
[Compass] metrics present: MISSING
[Compass] metrics: ACTIVE
[Consensus] score: PRESENT
[Hash-Relay] nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.

## Evidence Snapshot — 2025-10-09T20:24:24Z

**INTENTS:** `chat_answer,plan_create,tool_call,other`  |  **NODES:** `http://127.0.0.1:8080`

### A) /chat → headers (first 20 lines)
```txt
(no headers)
```

### B) decision.jsonl tail (mini)
```json
{"intent":"chat_answer","ethics":{"verdict":"HOLD","rule_id":"consensus_guard","hint":"score=0.69 < TH=0.80"},"provider":{"name":"scribe-internal","model":"auto"},"consensus_guard":{"trigger":true,"score":0.6875,"threshold":0.8,"reason":"LOW_SCORE"},"tuning":{"sla_suggested_ms":600}}
```

### C) /metrics state + excerpt
```txt
(no response)
```

### D) /hash
```json
{}
```

### E) Hash-Relay SUMMARY
```txt
SUMMARY nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

### F) Review Gate tail
```txt
[QUORUM] [2025-10-09T20:24:24Z] Quorum pending: missing HUMAN SECOND (touch ops/quorum/<NAME>.ok)
[Compass] metrics present: MISSING
[Compass] metrics: ACTIVE
[Consensus] score: PRESENT
[Hash-Relay] nodes=1 consistent=1 drift=0 unknown=0 distributed_consistency=YES
```

> Notes: env changes require restart; /metrics shows "Prometheus dormant" without prometheus_client.


---

## INTENTS Allowlist（確定）
`chat_answer, plan_create, tool_call, retrieval, quorum_review, audit_link, config_update, other`
- 未知は **other** 集約。agent ラベルは付与しない（爆発防止）。
- 1リクエスト＝**一次脳だけ**カウント（HALU/SCRIBEは diagnostics のみ）。

## Minimal Brain 定義（L2 / L2+）
- **L2（最小の脳）**  
  *Observe*（latency, intent）→ *Classify*（PASS/HOLD/FAIL）→ *Record*（`ledger.ethics + provider`）→ *Count*（intent counters; append-only）
- **L2+（提案する脳）**  
  L2 + `EWMA(α=0.3)` による `tuning.sla_suggested_ms = clamp(500..8000)*1.2` を ledger に追記。  
  Prometheus有効時は `daegis_tuner_sla_suggested_ms{intent}` Gauge を露出。**一次脳のみ**出力。

## Governor & Reflex（可視化ルール）
- **Consensus Guard**: `score < CONSENSUS_HOLD_THRESHOLD` で  
  `ledger.consensus_guard = {trigger, score, threshold, reason}` を**毎回**記録。  
  レスポンスヘッダ `X-Consensus-Guard` はミドルウェアで注入（非ブロッキング）。
- **Governor（合成）**: `LOW_SCORE / SLA_HOLD / HTTP_5XX` を `ledger.governor.reasons[]` に集約。  
  ヘッダ `X-Governor` は**提案のみ**（挙動は変えない）。
- **Reflex Alerts**: `HOLD x3` または `5xx x2` で `logs/alerts.log` へ通知（Slack: `ALERT_SLACK_WEBHOOK` 設定時のみ送信）。

## /metrics 運用方針（dormant既定）
- 既定：**dormant**（`prometheus_client` 無）。HTTP 200 + `"Prometheus dormant or unavailable"` を返す。  
- Active時：`*_init-once` で重複登録ゼロ、No-Op hydration で**NameError/500を撲滅**。  
- 将来の監査要件で 500 を返したい場合は ENV スイッチを追加（別フェーズ）。

## 10分デモ台本（固定）
1) `scripts/port_guard.sh` → OK  
2) `/chat` → 200 & ledger（`provider/ethics`）  
3) `/metrics` → dormant 説明 or OpenMetrics  
4) 厳格SLA → HOLD（`ledger.ethics=HOLD`、`X-Governor` 提示）  
5) `hash_relay.sh` → `distributed_consistency=YES`  
6) Evidence Snapshot → Runbook追記  
7) Review Gate → **GATE: PASS**

## 24h / 7d KPI（計測観点）
- 24h：Allowlist全意図で `intents_*` 非ゼロ、`sla_suggested_ms` 出力率 ≥ 90%、Hash-Relay `drift=0`  
- 7d：`consensus_score` 変動 < 5%、`MTTReturn（known_good）` SLO 100%、HOLD比率が目標帯に収束

## Chronicle Weekly（週報）
- `decision/consensus/hash-relay/alerts` を週次集計し、本章に **追記**。  
- KPIサマリ：`HOLD率 / sla_suggested_ms 出力率 / drift=0/24h / alerts件数 / policy 勝率（Dry-Run）`

## 監査用語（固定語彙）
- `distributed_consistency = YES | NO | UNKNOWN`  
- `governor.reasons ∈ {LOW_SCORE, SLA_HOLD, HTTP_5XX}`  
- Policy Dry-Run `outcome ∈ {WIN, LOSE, TIE}`  
- `known_good`：復帰先の固定状態。SLO目安 **P1=5m / P2=30m**（月次ドリル）


- Returnability drill: HOLD→recover MTTR=0s (UTC 2025-10-09T20:59:23Z)

---

# L9 — Auto-Tune (dry)
- 入力: `logs/simbrain_proposals.jsonl`, `logs/bandit_shadow.jsonl`
- 出力: `logs/auto_tune_dry.jsonl`（intent, proposed_sla_ms, source, expected_gain, risk_score, decision ∈ {candidate, reject}）
- Gate基準（7d）: `WIN_RATE ≥ 0.60` / `HOLD_RATE ∈ [5%,15%]` / `n ≥ 50`
- Chronicle: 「Auto-Tune candidates (7d)」集計を掲載
- Metrics（active時のみ）: `daegis_auto_tune_candidates_total{intent}`

# L10 — Controlled Apply（canary）
- 配分: `AUTO_TUNE_CANARY_PCT`（初期 5）
- 成功判定: `HOLD_RATE_canary ≤ HOLD_RATE_control + 2pp` かつ `p95_latency_canary ≤ p95_latency_control × 1.05`
- 昇格/撤回: 2連勝で昇格、1敗で撤回（即時ENVロールバック）
- 監査: `logs/auto_tune_canary.jsonl` / `logs/auto_tune_revoke.jsonl`
- ヘッダ（可視化のみ）: `X-Policy-Canary: on|off; intent=...; pct=...`

# Learning → Policy データフロー
`decision.jsonl → memory_curator → simbrain (L7) → bandit (L8) → auto_tune_dry (L9) → controlled_apply (L10) → governor/chronicle`

# ENVフラグ（抜粋）
- `AUTO_TUNE_ENABLED` (0/1), `AUTO_TUNE_CANARY_PCT` (デフォ=5)
- Killswitch: `AUTO_TUNE_GLOBAL_KILLSWITCH=1` で停止
- L5系: `L5_FORCE_SHADOW`, `L5_AUTO_APPLY`, `L5_HARD_APPLY`（既定=未設定）


## （修正）Learning → Policy データフロー（正）
`decision.jsonl → memory_curator → simbrain (L7) → bandit (L8) → auto_tune_dry (L9) → controlled_apply (L10) → governor/chronicle`

### ENV フラグ（再掲）
- `AUTO_TUNE_ENABLED` (0/1), `AUTO_TUNE_CANARY_PCT`（初期 5）
- Killswitch: `AUTO_TUNE_GLOBAL_KILLSWITCH=1`
- L5系: `L5_FORCE_SHADOW`, `L5_AUTO_APPLY`, `L5_HARD_APPLY`（既定=未設定）


---

## Daily Update — '"$TS"'
**範囲**: L10.5 / L11 / L13 / SB2 / Dashboard

- **L13 → L10.5 連動（fail-closed）**  
  verdict=PASS かつ ALLOW ⊆ CANARY のときのみ半自動採択。VETO／COOLDOWN／PASS の三重ゲートで安全側固定。
- **Auto-Adopt Gate 強化**  
  L13 PASS連動／ALLOW ⊆ CANARY 検証／COOLDOWN until_ts 自動補完（ログから復元）／VETO尊重。
- **SB2 パイプライン常設**  
  `scripts/dev/sb2_pipeline.sh`：SB2→L9→L10 の一括実行（`SB_MIN_CONF_TAG` 準拠）。  
  apply_planner は **v2のみ confidence gate**（既定 min=mid）。従来提案は後方互換で素通り。
- **Dashboard Lite 拡張**  
  ALLOW リスト／cooldown 残秒を表示。次ステップで「last adopt/skip reason」も追加予定。
- **運用ライン（現状）**  
  `AUTO_TUNE_CANARY_INTENTS=plan,publish` / `AUTO_TUNE_ALLOW_INTENTS=plan,publish` / latest(L13)=PASS / VETO=OFF
- **監査ログ**  
  `policy_canary_verdict.jsonl`（canary-only評価）、`policy_apply_plan.jsonl`、`policy_apply_controlled.jsonl` 更新済。

