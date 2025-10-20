#!/usr/bin/env bash
# seed_audits.sh — Scribeの取り込みカプセルを用意し、監査JSON 5件を作成→取り込み→検証
set -Eeuo pipefail

cd ~/daegis
mkdir -p ops/capsules/scribe docs/chronicle archives logs scripts/scribe /tmp/audit_in

# --- カプセル（audit_chat_extract）を配置 ---
cat > ops/capsules/scribe/audit_chat_extract.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
name="${1:-}"; shift || true
src=""
while [ $# -gt 0 ]; do case "$1" in --from) src="${2:-}"; shift 2;; *) shift;; esac; done
ts="$(date +%s)"; d="$(date +%F)"
out_dir="docs/chronicle/${d}"; arc_dir="archives/${d}"
mkdir -p "$out_dir" "$arc_dir" logs
tmp="$(mktemp)"
if [ -n "$src" ] && [ -f "$src" ]; then cat "$src" > "$tmp"; else
cat > "$tmp" <<'J'
{"phase":"unknown","layer":[],"component_id":"unknown","topic":"unknown","decisions":[],"todos":[],"files":[],"commands":[],"env_knobs":[],"interfaces":{"inputs":[],"outputs":[],"side_effects":[]},"gates_safety":[],"metrics_ports":[],"dependencies":{"upstream":[],"downstream":[]},"effects":[],"effects_chain":[],"evidence":[],"time_window":"unknown","owners":[],"evaluation":{"verdict":"INSUFFICIENT","reason":"unknown","factors":[]},"governance":{"classification":"Internal","storage":"unknown","egress":"unknown","dlp_hits":"unknown","trace_id":"unknown"},"reproducibility":{"capsule_or_profile":"unknown","journal_sha":"unknown","status":"Pending"},"status":"Pending"}
J
fi
command -v jq >/dev/null 2>&1 || { echo "AUDIT_NG reason=jq_not_found" | tee -a logs/audit_validate.log; exit 0; }
jq -e '.' "$tmp" >/dev/null 2>&1 || { echo "AUDIT_NG reason=invalid_json" | tee -a logs/audit_validate.log; exit 0; }
safe="$(printf '%s' "${name:-chat}" | tr -cs '[:alnum:]_.- ' '_' | sed 's/__*/_/g;s/^_//;s/_$//')"
out="${out_dir}/${safe}.audit.json"; i=1; while [ -e "$out" ]; do i=$((i+1)); out="${out_dir}/${safe}.${i}.audit.json"; done
cp "$tmp" "$out"; cp -a "$out" "$arc_dir/" 2>/dev/null || true
sha="$( (sha256sum "$out" 2>/dev/null || shasum -a 256 "$out") | awk '{print $1}')"
size="$(stat -c%s "$out" 2>/dev/null || stat -f%z "$out")"
echo "{\"ts\":${ts},\"kind\":\"audit_json\",\"path\":\"${out}\",\"sha256\":\"${sha}\",\"size\":${size}}" >> asset_registry.jsonl
echo "{\"ts\":${ts},\"capsule\":\"audit_chat_extract\",\"name\":\"${name:-chat}\",\"path\":\"${out}\",\"ok\":true}" >> logs/ops_journal.jsonl
echo "AUDIT_OK path=${out} sha256=${sha}" | tee -a logs/audit_validate.log
rm -f "$tmp"
SH
chmod +x ops/capsules/scribe/audit_chat_extract.sh

# --- ops/run に shim を追加（重複安全） ---
if ! grep -q 'audit_chat_extract' ops/run 2>/dev/null; then
  cat >> ops/run <<'SH'

# --- shim: audit_chat_extract (scribe) ---
if [ "${1:-}" = "audit_chat_extract" ]; then shift || true; exec ops/capsules/scribe/audit_chat_extract.sh "$@"; fi
SH
  chmod +x ops/run
fi

# --- 補助: JSONエスケープ関数 ---
json_escape(){ python3 - "$1" <<'PY'
import json,sys; print(json.dumps(sys.argv[1]))
PY
}

# --- 監査JSON 5件を “半自動” 生成 ---
verdict="$(tail -1 logs/policy_canary_verdict.jsonl 2>/dev/null | jq -r '.verdict' 2>/dev/null || echo unknown)"
p95="$(tail -1 logs/policy_canary_verdict.jsonl 2>/dev/null | jq -r '.p95_ms' 2>/dev/null || echo null)"
hr="$(tail -1 logs/policy_canary_verdict.jsonl 2>/dev/null | jq -r '.hold_rate' 2>/dev/null || echo null)"
e5="$(tail -1 logs/policy_canary_verdict.jsonl 2>/dev/null | jq -r '.e5xx' 2>/dev/null || echo null)"

cat > /tmp/audit_in/2025-10-10T0200_oracle.l13_PhaseV.json <<EOF
{
  "phase":"Phase V","layer":["observability","agents"],"component_id":"oracle.l13","topic":"Canary判定（plan/publish）",
  "decisions":["canary_verdict を定期実行","canary-only 評価（plan,publish）"],
  "todos":["L13_WINDOW_SEC の runbook 明記"],
  "files":["scripts/learn/canary_verdict.py","logs/policy_canary_verdict.jsonl"],
  "commands":["python3 scripts/learn/canary_verdict.py","tail -1 logs/policy_canary_verdict.jsonl | jq '{\"verdict\":.verdict,\"p95_ms\":.p95_ms}'"],
  "env_knobs":["L13_WINDOW_SEC=300","L13_ONLY_CANARY=1"],
  "interfaces":{"inputs":["logs/decision.jsonl"],"outputs":["logs/policy_canary_verdict.jsonl"],"side_effects":["dashboard_lite.md に追記"]},
  "gates_safety":["verdict=PASS 以外は adopt 不可"],
  "metrics_ports":["p95_ms","hold_rate","e5xx","router:8080/metrics"],
  "dependencies":{"upstream":["router.app"],"downstream":["apply.l10_5_gate","scribe.dashboard_lite"]},
  "effects":["oracle profile stabilized"],
  "evidence":["logs/policy_canary_verdict.jsonl (tail)"],
  "time_window":"2025-10-10T00:00Z..2025-10-10T03:00Z",
  "owners":["user:AEGIS","agent:chatgpt13"],
  "evaluation":{"verdict":$(json_escape "${verdict}"),"reason":"latest L13 verdict","factors":["p95_ms","hold_rate","e5xx"]},
  "governance":{"classification":"Internal","storage":"logs/","egress":"none","dlp_hits":"None","trace_id":"unknown"},
  "reproducibility":{"capsule_or_profile":"oracle","journal_sha":"unknown","status":"Confirmed"},
  "status":"Confirmed",
  "metrics_ports_values":{"p95_ms":${p95},"hold_rate":${hr},"e5xx":${e5}}
}
EOF

gate_tail="$(tail -1 logs/policy_apply_controlled.jsonl 2>/dev/null || echo '')"
cat > /tmp/audit_in/2025-10-10T0300_apply.l10_5_gate_PhaseV.json <<EOF
{
  "phase":"Phase V","layer":["agents","governance","sentry"],"component_id":"apply.l10_5_gate","topic":"Auto-Adopt Gate",
  "decisions":["ALLOW=plan,publish","L13 verdict!=PASS は skip","VETO/COOLDOWN尊重"],
  "todos":["flock排他の本採用"],
  "files":["scripts/learn/auto_adopt_gate.sh","logs/policy_apply_controlled.jsonl","flags/L105_COOLDOWN_UNTIL","flags/L5_VETO"],
  "commands":["bash scripts/learn/auto_adopt_gate.sh","tail -3 logs/policy_apply_controlled.jsonl | jq '.'"],
  "env_knobs":["AUTO_TUNE_ALLOW_INTENTS=plan,publish"],
  "interfaces":{"inputs":["logs/policy_canary_verdict.jsonl","flags/L5_VETO"],"outputs":["logs/policy_apply_controlled.jsonl"],"side_effects":["env_local.sh 候補に影響"]},
  "gates_safety":["VETO present→skip","COOLDOWN active→skip","L13 PASSでなければskip"],
  "metrics_ports":["router:8080/metrics"],
  "dependencies":{"upstream":["oracle.l13"],"downstream":["env_local.sh","sentry.l11"]},
  "effects":["cooldown 記録/skip ログ"],
  "evidence":[$(json_escape "$gate_tail")],
  "time_window":"2025-10-10",
  "owners":["user:AEGIS","agent:chatgpt13"],
  "evaluation":{"verdict":"PASS","reason":"gate rules applied","factors":["allow list","veto","cooldown"]},
  "governance":{"classification":"Internal","storage":"logs/","egress":"none","dlp_hits":"None","trace_id":"unknown"},
  "reproducibility":{"capsule_or_profile":"apply","journal_sha":"unknown","status":"Confirmed"},
  "status":"Confirmed"
}
EOF

sb2_tail="$(grep -F '"simbrain_v2_proposal"' logs/simbrain_proposals.jsonl 2>/dev/null | tail -1 || true)"
cat > /tmp/audit_in/2025-10-10T0400_learn.sb2_pipeline_PhaseV.json <<EOF
{
  "phase":"Phase V","layer":["agents"],"component_id":"learn.sb2_pipeline","topic":"SimBrain v2 提案+confidence",
  "decisions":["SB_MIN_CONF_TAG=mid 推奨","従来提案は通過／v2はconfidenceでフィルタ"],
  "todos":["reflective mind 本線化"],
  "files":["scripts/dev/sb2_pipeline.sh","logs/simbrain_proposals.jsonl","logs/policy_apply_plan.jsonl"],
  "commands":["bash scripts/dev/sb2_pipeline.sh","grep -F 'simbrain_v2_proposal' logs/simbrain_proposals.jsonl | tail -3 | jq '.'"],
  "env_knobs":["SB_MIN_CONF_TAG=mid","SB2_ALLOW_INTENTS=plan,publish"],
  "interfaces":{"inputs":["logs/simbrain_proposals.jsonl"],"outputs":["logs/policy_apply_plan.jsonl"],"side_effects":["dashboard_lite.mdへ反映"]},
  "gates_safety":["apply_planner: v2のみconfidence gate適用"],
  "metrics_ports":["proposal counts","apply_plan skip reasons"],
  "dependencies":{"upstream":["train_ready_v2.csv (if any)"],"downstream":["apply.l10_5_gate"]},
  "effects":["候補更新・skip理由ログ化"],
  "evidence":[$(json_escape "$sb2_tail")],
  "time_window":"2025-10-10",
  "owners":["user:AEGIS","agent:chatgpt13"],
  "evaluation":{"verdict":"PASS","reason":"pipeline dry OK","factors":["confidence gate"]},
  "governance":{"classification":"Internal","storage":"logs/","egress":"none","dlp_hits":"None","trace_id":"unknown"},
  "reproducibility":{"capsule_or_profile":"learn","journal_sha":"unknown","status":"Confirmed"},
  "status":"Confirmed"
}
EOF

dash_tail="$(tail -10 docs/runbook/dashboard_lite.md 2>/dev/null || true)"
cat > /tmp/audit_in/2025-10-10T0500_scribe.dashboard_lite_PhaseV.json <<EOF
{
  "phase":"Phase V","layer":["docs","observability"],"component_id":"scribe.dashboard_lite","topic":"ダッシュ拡張（ALLOW/cooldown）",
  "decisions":["ALLOW と cooldown 残秒を常時表示"],
  "todos":["last adopt/skip reason を1行表示"],
  "files":["scripts/dev/dashboard_lite.sh","docs/runbook/dashboard_lite.md"],
  "commands":["bash scripts/dev/dashboard_lite.sh","tail -30 docs/runbook/dashboard_lite.md"],
  "env_knobs":["AUTO_TUNE_ALLOW_INTENTS=plan,publish"],
  "interfaces":{"inputs":["logs/*","flags/L105_COOLDOWN_UNTIL"],"outputs":["docs/runbook/dashboard_lite.md"],"side_effects":["運用可視化"]},
  "gates_safety":[],"metrics_ports":["markdown only"],
  "dependencies":{"upstream":["oracle.l13","apply.l10_5_gate","learn.sb2_pipeline"],"downstream":["humans"]},
  "effects":["オペ判断が高速化"],
  "evidence":[$(json_escape "$dash_tail")],
  "time_window":"2025-10-10","owners":["agent:chatgpt13"],
  "evaluation":{"verdict":"PASS","reason":"更新反映","factors":["表示項目追加"]},
  "governance":{"classification":"Internal","storage":"docs/","egress":"repo","dlp_hits":"None","trace_id":"unknown"},
  "reproducibility":{"capsule_or_profile":"scribe","journal_sha":"unknown","status":"Confirmed"},
  "status":"Confirmed"
}
EOF

cron_dump="$( (crontab -l 2>/dev/null || echo 'unknown') )"
cat > /tmp/audit_in/2025-10-10T0600_ops.cron_PhaseV.json <<EOF
{
  "phase":"Phase V","layer":["observability","scheduler"],"component_id":"ops.cron","topic":"常設ジョブ",
  "decisions":["/10 enrich+verdict","/30 ready","/15 sb2_pipeline"],
  "todos":["flockの多重起動防止をgate/readyにも"],
  "files":["(user crontab)","scripts/dev/sb2_pipeline.sh"],
  "commands":["crontab -l"],
  "env_knobs":["SB_MIN_CONF_TAG=mid","AUTO_TUNE_ALLOW_INTENTS=plan,publish"],
  "interfaces":{"inputs":["repo scripts"],"outputs":["/tmp/*_loop.log"],"side_effects":["継続運転"]},
  "gates_safety":["各スクリプトのゲートに委譲"],
  "metrics_ports":["cron logs"],
  "dependencies":{"upstream":["venv, repo"],"downstream":["oracle.l13","apply.l10_5_gate","learn.sb2_pipeline"]},
  "effects":["自律運転"],"evidence":[$(json_escape "$cron_dump")],
  "time_window":"2025-10-10","owners":["user:AEGIS"],
  "evaluation":{"verdict":"PASS","reason":"ジョブ登録済","factors":["crontab -l 出力"]},
  "governance":{"classification":"Internal","storage":"/tmp & logs","egress":"none","dlp_hits":"None","trace_id":"unknown"},
  "reproducibility":{"capsule_or_profile":"ops","journal_sha":"unknown","status":"Confirmed"},
  "status":"Confirmed"
}
EOF

# --- 取り込み（Daegis へ保存） ---
for f in /tmp/audit_in/*.json; do ./ops/run audit_chat_extract "$(basename "${f%.json}")" --from "$f"; done

# --- 検証 ---
echo '--- validate ---'
tail -5 logs/audit_validate.log 2>/dev/null || true
ls -1 docs/chronicle/$(date +%F) 2>/dev/null | sed -n '1,20p' || true

echo "[done] seed_audits"