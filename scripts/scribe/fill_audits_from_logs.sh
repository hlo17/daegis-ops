#!/usr/bin/env bash
set -euo pipefail
D_IN="/tmp/audit_in"
DATE_TAG="$(date -u +%Y-%m-%dT%H:%MZ)"
l13_tail_json(){ tail -1 ~/daegis/logs/policy_canary_verdict.jsonl 2>/dev/null || echo '{}'; }
l105_tail_json(){ tail -3 ~/daegis/logs/policy_apply_controlled.jsonl 2>/dev/null | jq -s '.' || echo '[]'; }

# 1) oracle.l13
f="$D_IN/2025-10-10T0200_oracle.l13_PhaseV.json"; if [ -f "$f" ]; then
  l13="$(l13_tail_json)"
  jq --arg when "$DATE_TAG" --argjson l13 "$l13" '
    .phase="Phase V" |
    .layer=["observability","agents"] |
    .component_id="oracle.l13" |
    .topic="Canary判定（plan/publish中心、5分窓併用）" |
    .files=["scripts/learn/decision_enrich.py","scripts/learn/canary_verdict.py","logs/policy_canary_verdict.jsonl"] |
    .commands=["python3 scripts/learn/decision_enrich.py","python3 scripts/learn/canary_verdict.py"] |
    .env_knobs=["L13_WINDOW_SEC=300","L13_ONLY_CANARY=1"] |
    .interfaces.inputs=["logs/decision.jsonl"] |
    .interfaces.outputs=["logs/policy_canary_verdict.jsonl"] |
    .gates_safety=["verdict=FAIL when HOLD_RATE>0.2 or HTTP_5XX>0"] |
    .metrics_ports=["p95_ms","hold_rate","e5xx"] |
    .evidence += [$when + " l13_tail:" + ($l13|tostring)] |
    .evaluation.verdict = ( $l13.verdict // "INSUFFICIENT") |
    .evaluation.reason = "from l13 tail" |
    .status="Confirmed"
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi

# 2) apply.l10_5_gate
f="$D_IN/2025-10-10T0300_apply.l10_5_gate_PhaseV.json"; if [ -f "$f" ]; then
  l105="$(l105_tail_json)"
  jq --arg when "$DATE_TAG" --argjson l105 "$l105" '
    .phase="Phase V" |
    .layer=["agents","governance","sentry"] |
    .component_id="apply.l10_5_gate" |
    .topic="Auto-Adopt Gate（L13/VETO/COOLDOWN連動）" |
    .files=["scripts/learn/auto_adopt_gate.sh","logs/policy_apply_controlled.jsonl","flags/L5_VETO","flags/L105_COOLDOWN_UNTIL"] |
    .commands=["bash scripts/learn/auto_adopt_gate.sh"] |
    .env_knobs=["AUTO_TUNE_ALLOW_INTENTS=plan,publish"] |
    .interfaces.inputs=["logs/policy_canary_verdict.jsonl","flags/L5_VETO"] |
    .interfaces.outputs=["logs/policy_apply_controlled.jsonl"] |
    .gates_safety=["VETO present→skip","L13 verdict!=PASS→skip","COOLDOWN active→skip"] |
    .evidence += [$when + " l105_tail:" + ($l105|tostring)] |
    .status="Confirmed"
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi

# 3) learn.sb2_pipeline
f="$D_IN/2025-10-10T0400_learn.sb2_pipeline_PhaseV.json"; if [ -f "$f" ]; then
  jq '
    .phase="Phase V" |
    .layer=["agents"] |
    .component_id="learn.sb2_pipeline" |
    .topic="SimBrain v2 提案 + confidence タグ注入" |
    .files=["scripts/dev/sb2_pipeline.sh","logs/policy_auto_tune.jsonl","logs/policy_apply_plan.jsonl"] |
    .commands=["bash scripts/dev/sb2_pipeline.sh"] |
    .env_knobs=["SB_MIN_CONF_TAG=mid","SB2_ALLOW_INTENTS=plan,publish"] |
    .interfaces.inputs=["logs/simbrain_proposals.jsonl","logs/policy_auto_tune.jsonl"] |
    .interfaces.outputs=["logs/policy_apply_plan.jsonl"] |
    .gates_safety=["apply_planner: v2提案のみ SB_MIN_CONF_TAG でフィルタ"] |
    .status="Confirmed"
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi

# 4) scribe.dashboard_lite
f="$D_IN/2025-10-10T0500_scribe.dashboard_lite_PhaseV.json"; if [ -f "$f" ]; then
  jq '
    .phase="Phase V" |
    .layer=["docs","observability"] |
    .component_id="scribe.dashboard_lite" |
    .topic="Dashboard Lite 拡張（ALLOW/cooldown表示など）" |
    .files=["scripts/dev/dashboard_lite.sh","docs/runbook/dashboard_lite.md"] |
    .commands=["bash scripts/dev/dashboard_lite.sh"] |
    .interfaces.inputs=["logs/*","flags/L105_COOLDOWN_UNTIL"] |
    .interfaces.outputs=["docs/runbook/dashboard_lite.md"] |
    .status="Confirmed"
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi

# 5) ops.cron
f="$D_IN/2025-10-10T0600_ops.cron_PhaseV.json"; if [ -f "$f" ]; then
  jq '
    .phase="Phase V" |
    .layer=["observability","scheduler"] |
    .component_id="ops.cron" |
    .topic="常設ジョブ（enrich/verdict/ready/sb2）" |
    .files=["(user) crontab","scripts/dev/sb2_pipeline.sh"] |
    .commands=["crontab -l | sed -n \"1,50p\""] |
    .env_knobs=["AUTO_TUNE_ALLOW_INTENTS=plan,publish","SB_MIN_CONF_TAG=mid"] |
    .status="Confirmed"
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
fi
