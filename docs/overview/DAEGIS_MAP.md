## Daegis OS Layer Map (v2.1 Phase II — Autonomous Safeguards & Traceability)

| Layer | Focus | Phase II Objective | Evidence Key |
|:------|:------|:-------------------|:-------------|
| A Runtime Integrity | Port Guard / Tasks-only | 全実行を VS Code Tasks へ統一 | scripts/port_guard.sh |
| B Ontology & Intent | Compass / Intents Graph | 署名付 Compass 追記 | ops/policy/compass.json |
| C Ledger & Trace | Decision Ledger (JSONL) | 10 MB × 3 ローテーション + episode trace | logs/decision.jsonl |
| D Safety Control | SAFE Fallback / Quorum | 二者承認 + 準自動 Alert 連動 | scripts/guard/* |
| E Observability | Prometheus :9091 / Grafana | Episode Trace Panel 追加 | ops/monitoring/prometheus/rules/daegis-alerts.yml |

**運用原則 (v2):**  
- API-one proof（/chat or /api/v1/rules）  
- No new places（宣言→配線→API検証を1PR内で）  
- Append-only（破壊変更は次Phase）  
- Sensitive gate（HUMAN.ok + SECOND.ok）
<!-- Generated on 2025-10-11T07:21:05Z -->
# Daegis Map (snapshot)
- Phase: (unknown)
- Components: (see docs/chronicle/system_map.json)
