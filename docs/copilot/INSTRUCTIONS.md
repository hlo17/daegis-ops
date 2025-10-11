
⸻

🛰 Phase II Decisions（Autonomous Safeguards & Traceability）
        • Prometheus は :9091（Docker）のみ正とし、systemd 版は mask 済み（変更禁止）。
        • Alert → SAFE は “人間承認ワンキー” 前提（HUMAN.ok / SECOND.ok の 15分有効）。
        • Prometheus ルールの Single Source of Truth は /etc/prometheus/rules/*.yml（本リポは ops/monitoring/prometheus/rules/daegis-alerts.yml）。
        • ルールには SAFE ヒント注釈（annotations.hint）を付与し、API-one proof で可視確認する。
        • Decision Ledger（logs/decision.jsonl）は append-only（将来 10MB×3 ローテーション）。
