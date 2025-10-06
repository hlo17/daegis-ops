---
tags:
  - Memory_Records
aliases:
created: 2025-09-27 04:15
modified: 2025-10-05 16:42 JST
Describe: "Decision Scribe、決定台帳（確定事実と合意の一次原本）"
---

# Daegis Ledger — Unified

## Core Decisions（抜粋・既存統合）
- **2025-09-27**: 命名整理（Daegis Bus/MQTT、Daegis Ledger、Daegis Raspberry Node、Daegis Observability）。
- **2025-09-27**: 可視化基盤（Prometheus+Grafana）と Caddy/Cloudflare Access による外部公開の最小構成確立。
- **2025-09-28**: Sentry 導入。GO/NOGO 判定の観測ループを稼働。
- **2025-09-28**: ハンドオフ運用（Hand-off + Ledger）を二本柱として確立。
- **2025-09-30**: E2E（Mac↔Pi）ワークフロー完成、ResearchFactory 常駐化。
- **2025-10-03**: no_proposals フォールバック＋ASGI mw_log で orchestrate 観測安定化。
- **2025-10-04**: `rt-digest.sh` / service / timer（09:05）導入、Slack Webhook を env 方式に統一。
- **2025-10-05**: Cloudflare Named Tunnel “bridge” 恒久化。Slack Slash → MQTT 経路 本稼働。評価スキーマ（✅/🛠/❌）固定。
- **2025-10-06**: **運用方針** — auto-brief を一次情報源とし、hand-off を **日次スナップショット**として自動同期（監査・学習用）。🟢

## Halu Training（直近の合意）
- **短期方針**：RAG v0 → 評価保存固定 → LoRA“型矯正”（小さく回す）。
- **RAG v0**：SQLite FTS5 による why/policy 検索→Top3 根拠をプロンプト注入。
- **評価保存**：MQTT `daegis/feedback/<agent>` → 1行JSON `{id,agent,label,reason,ts}` → DuckDB/Parquet。
- **verdict 集計**：✅/🛠/❌ 比率＋相関 ID 突合で Halu 一致率を測定。

## UIDs / Paths / Services
- **Grafana Managed Alert**: Rule UID **ff05cw894ui9sa** / Folder UID **dezp28u2u1q0wf** / Loki DS UID **df04lyc3gb9c0b**  
  - Query: `sum(count_over_time({job="daegis",host="round-table",level="error"}[5m]))`, `for=5m`
- **Paths**:  
  - `/usr/local/bin/auto-brief.py`（出力 `/srv/round-table/brief.md`）  
  - `/etc/systemd/system/auto-brief@.service.d/env.conf`（API Key）  
  - `/etc/promtail/config.yaml`／`/var/lib/promtail/positions/positions.yaml`
- **Services**: `daegis-slack2mqtt.service`, `cloudflared-bridge.service`, `auto-brief@.service/.timer`

## Guardrails / Risks
- DNS 伝播や CF キャッシュで 530/解決不能の可能性（短時間）。
- Slack 落ち時の代替動線（ローカル FastAPI 経由再送）手順を Runbook に固定化。  
- 評価データの匿名化（SHA256 等）を導入前に最小実装。  
- LoRA 実験の GPU/コスト上限（週次キャップ）明確化。

## Ops Quick Ref（ハイライト）
- **直近5分 error 件数**（Loki）：  
  `curl -G -s http://127.0.0.1:3100/loki/api/v1/query --data-urlencode 'query=sum(count_over_time({job="daegis",host="round-table",level="error"}[5m]))'`
- **Alert 一時テスト**：`for=0s` → エラー1行 → 受信確認 → `for=5m` 復帰。

## Notes
- Map＝恒久ルール、Guidelines＝運用テンプレ、Hand-off＝最新状態の**スナップショット**、Ledger＝確定決定の一次原本。  
- 以後、auto-brief → hand-off 同期は**自動化**前提（systemd timer で `brief.md` を上書き→Git commit）。
