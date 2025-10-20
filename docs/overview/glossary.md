# Daegis Glossary (Audit-Ready)

- distributed_consistency: `YES | NO | UNKNOWN`
- governor.reasons: `LOW_SCORE`, `SLA_HOLD`, `HTTP_5XX`
- policy.outcome: `WIN | LOSE | TIE`
- minimal_brain:
  - L2 = observe→classify→record→count（append-only）
  - L2+ = L2 + EWMA 提案（一次脳のみ出力）
- dormant metrics: Prom クライアント無時の既定状態（HTTP 200 + メッセージ）