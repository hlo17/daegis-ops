# Charter

## Purpose
- 円卓型AI協働システム（Daegis OS）は、複数のAIエージェントと人間（議長）が「意思決定 → 検証 → 証跡 → 学習」を **1本のAPIで監査可能** にする実験型OS。
- 中心に6文書体制（Map / Ledger / Chronicle / Brief / Runbook / Charter）を置き、全変更は **Append-only ＋ API-one proof** 原則で管理。

## Guardrails
- Auto-Adopt は L5_VETO / L105_COOLDOWN_UNTIL で即時停止。
- Canary は **エラー削減で PASS** を目指す（しきい値緩和は最後の手段）。

## Current KPIs
- canary=FAIL, hold=0.2241, e5xx=394, p95=3005.72, adopt_last200=unknown
