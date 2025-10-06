---
title: monitoring
tags: [registry, system]
category: ops
owner: f
---
# monitoring
(draft)
## What/Why
Prometheus+Alertmanager+Grafana（将来Sentry連携）。まずはローカルdockerでPoC。

## Entrypoint (draft)
- ops/monitoring/* （composeと設定雛形あり）
- テスト: `ops/monitoring/prober/smoke.py`
