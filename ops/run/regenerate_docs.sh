#!/usr/bin/env bash
set -euo pipefail
ROOT="${DAEGIS_ROOT:-$HOME/daegis}"
cd "$ROOT"

now="$(date -u +%FT%TZ)"
today="$(date -u +%F)"

# 必要なディレクトリ
mkdir -p docs/{overview,chronicle,brief,hand_off,copilot,rollup,runbook} \
         ops/{ward,bridge,citadel,monitoring/prometheus/rules} \
         archives logs

# 6文書の最小テンプレ（既存があれば追記/更新、壊さない）
touch docs/overview/DAEGIS_MAP.md
grep -q "Generated on" docs/overview/DAEGIS_MAP.md || cat >> docs/overview/DAEGIS_MAP.md <<EOF

<!-- Generated on ${now} -->
# Daegis Map (snapshot)
- Phase: (unknown)
- Components: (see docs/chronicle/system_map.json)
EOF

touch docs/chronicle/phase_mvp_completion.md
grep -q "Generated on" docs/chronicle/phase_mvp_completion.md || cat >> docs/chronicle/phase_mvp_completion.md <<EOF

<!-- Generated on ${now} -->
# Chronicle (MVP→Phase II/V/VI)
参照: docs/chronicle/$(date +%F)/, phase_ledger.jsonl
EOF

touch docs/brief/Brief.md
grep -q "Generated on" docs/brief/Brief.md || cat >> docs/brief/Brief.md <<EOF

<!-- Generated on ${now} -->
# Brief
- Current goal: Safety chain visibility & governance completeness
EOF

mkdir -p docs/hand_off
touch docs/hand_off/HANDOFF_TEMPLATE.md
grep -q "Generated on" docs/hand_off/HANDOFF_TEMPLATE.md || cat >> docs/hand_off/HANDOFF_TEMPLATE.md <<EOF

<!-- Generated on ${now} -->
# Hand-off Template
- What changed:
- Evidence:
- Risks:
- Next actions:
EOF

mkdir -p docs/copilot
touch docs/copilot/INSTRUCTIONS.md
grep -q "API-one proof" docs/copilot/INSTRUCTIONS.md || cat >> docs/copilot/INSTRUCTIONS.md <<'EOF'
# Copilot Instructions v2 (extract)
- API-one proof only (/chat or :9091/api/v1/rules)
- Tasks-only (no nohup/systemctl)
- Append-only policy
EOF

# README は INSTRUCTIONS から生成する簡易版
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("docs/copilot/INSTRUCTIONS.md")
out = pathlib.Path("docs/copilot/README.md")
if p.exists():
    txt = p.read_text(encoding="utf-8")
    out.write_text("# Copilot README (generated)\n\n" + txt, encoding="utf-8")
PY

# Prometheus ルール（最小）— daegis-chat-alerts グループだけ置く
RULE=ops/monitoring/prometheus/rules/daegis-alerts.yml
if [ ! -s "$RULE" ]; then
cat > "$RULE" <<'YML'
groups:
- name: daegis-chat-alerts
  rules:
  - alert: ChatOpsLatencyHigh
    expr: rt_latency_ms_bucket{le="3000"} < 1
    for: 5m
    labels: {severity: warning}
    annotations:
      hint: "API-one proof: curl :9091/api/v1/rules | jq"
YML
fi

# dashboard_lite を空でも用意
touch docs/runbook/dashboard_lite.md
echo "[ok] regenerate_docs done at ${now}"
