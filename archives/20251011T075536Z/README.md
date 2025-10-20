# Copilot README (generated)

Daegis · Copilot Instructions (v2)

Scope:
このレポ内では “最小・可視・可逆” の変更のみを提案・生成する。
まず docs/copilot/README.md を入口にして Ground Truth を参照。矛盾があれば ask first。

⸻

🧭 Core Rules
	•	API-one proof
　検証は HTTP/CLI の単一エンドポイントで証明する（例: /chat, /api/v1/rules, scripts/port_guard.sh, tail logs/decision.jsonl）。
　アプリ本体（例: router/app.py）は変更せず、観測で立証する。
	•	No new places
　新ディレクトリの追加は禁止。必要な場合のみ
　①宣言（なぜ既存で不足か docs に1行明記）
　②配線（Prometheus/Grafana/Router が実際に読む設定を同PRに反映）
　③検証（API一本で新パスが読まれている証拠を取得）
　を同一PRで行う。
	•	Tasks-only runtime
　起動・停止は VS Code Tasks のみ許可。
　nohup, pkill, systemctl は使用禁止。
　例外: 一時検証＋直後にタスク化する場合。
	•	Append-only rule
　既存コードは追記のみ。破壊・置換は次フェーズで。
　変更は ≤3ファイル / ≤50行 を目安。
	•	Sensitive gate
　上記ルール違反が含まれる変更は必ず人間承認（HUMAN.ok / SECOND.ok）または Review Gate 通過後に実施。

⸻

⚙️ Runtime & Infrastructure Policies
	•	Router: :8080 固定（VS Code Task "Uvicorn (copilot-exec)" から起動）
	•	Prometheus: :9091 (Docker) 固定。
　systemd prometheus は無効化済み（mask 状態）。
　ルールの Single Source of Truth は /etc/prometheus/rules/*.yml。
	•	Grafana: DS は ${DS_PROMETHEUS} = http://localhost:9091。
	•	Port Guard: すべての実行前に scripts/port_guard.sh を通す（fail-fast）。

⸻

🔍 Verification & Observability
	•	Evidence-first
　変更は必ず “見える証拠” を残す。
　例: /chat のヘッダ、decision.jsonl 末尾、:9091/api/v1/rules の hint、Port Guard の終了コード。
	•	Runbook integration
　証跡は docs/runbook/mvp_evidence.md または docs/chronicle/phase_*.md に追記。
　常に Reproducible / Reversible / Observable を優先。

⸻

🧩 Dev & Review Flow
	1.	Plan（3行）
	2.	Patch（最小差分 / touched files を明示）
	3.	Tests（2〜3本のAPIコマンドで検証）
	4.	KP（リスク / ロールバック / 次アクション）

⸻

Review Gate（自動関門）
	•	bash scripts/dev/review_gate.sh により以下を検証：
	1.	Port Guard (scripts/port_guard.sh) → OK
	2.	/chat → x-episode-id ヘッダ確認
	3.	:9091/api/v1/rules → hint 出力（なければ Warning）
	•	3つ全てが PASS で “GATE: PASS” と表示されればレビュー可能。

⸻

Quorum SAFE (二者承認)
	•	ops/quorum/HUMAN.ok と SECOND.ok が15分以内に存在する場合のみ、
　scripts/guard/quorum_safe.sh が
　Ready: scripts/guard/safe_fallback.sh --enable を出力（実行はしない）。

⸻

🛡️ Operational Guardrails
	•	禁止: 新依存 / 新ポート / システム権限操作（sudo, systemd）
	•	Rollback: git checkout --, docker restart または VS Code タスクで戻せる状態を保つ。
	•	Metrics expectations:
　開発環境では /metrics = HTTP 500 (expected without prometheus_client)。
　Prometheus経由での監視を優先。

⸻

🧠 Behavior Style
	•	明確に: Goal / Scope / Deliverables の3行で指示。
	•	変更より証拠を：先に「どう検証するか」を書く。
	•	不確実な推測はせず、常に質問を。
	•	常に Reproducible・Reversible・Observable を守る。

⸻

📚 Reference Paths
	•	Docs: docs/copilot/README.md, docs/runbook/mvp_evidence.md
	•	Router: router/app.py, router/chat_cache_timeout.py
	•	Monitoring: ops/monitoring/**
	•	Runbooks: ops/runbooks/**
	•	Verification: scripts/dev/*, scripts/guard/*

⸻

🧩 Example Workflows
	•	Smoke test: ./scripts/dev/smoke.sh → MISS→HIT→504
	•	Metrics check: ./scripts/dev/metrics_check.sh
	•	Evidence snapshot: VS Code task "Evidence: Snapshot (append)"
	•	SAFE操作: "SAFE: Approve (HUMAN)" → "SAFE: Quorum Check"

⸻

Follow these to stay useful, safe, and fast.
Keep every change small, visible, and reversible.
