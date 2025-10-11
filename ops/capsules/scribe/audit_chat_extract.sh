#!/usr/bin/env bash
set -euo pipefail
name="${1:-}"; shift || true
src=""
while [ $# -gt 0 ]; do case "$1" in --from) src="${2:-}"; shift 2;; *) shift;; esac; done
ts="$(date +%s)"; d="$(date +%F)"
out_dir="docs/chronicle/${d}"; arc_dir="archives/${d}"
mkdir -p "$out_dir" "$arc_dir" logs
tmp="$(mktemp)"
if [ -n "${src}" ] && [ -f "${src}" ]; then
  cat "${src}" > "${tmp}"
else
  cat > "${tmp}" <<'J'
{"phase":"unknown","layer":[],"component_id":"unknown","topic":"unknown","decisions":[],"todos":[],"files":[],"commands":[],"env_knobs":[],"interfaces":{"inputs":[],"outputs":[],"side_effects":[]},"gates_safety":[],"metrics_ports":[],"dependencies":{"upstream":[],"downstream":[]},"effects":[],"effects_chain":[],"evidence":[],"time_window":"unknown","owners":[],"evaluation":{"verdict":"INSUFFICIENT","reason":"unknown","factors":[]},"governance":{"classification":"Internal","storage":"unknown","egress":"unknown","dlp_hits":"unknown","trace_id":"unknown"},"reproducibility":{"capsule_or_profile":"unknown","journal_sha":"unknown","status":"Pending"},"status":"Pending"}
J
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "AUDIT_NG reason=jq_not_found" | tee -a logs/audit_validate.log; exit 0
fi
jq -e '.' "$tmp" >/dev/null 2>&1 || { echo "AUDIT_NG reason=invalid_json" | tee -a logs/audit_validate.log; rm -f "$tmp"; exit 0; }

# サニタイズ（LC_ALL=C で警告回避）
safe="$(printf '%s' "${name:-chat}" | LC_ALL=C tr -cs 'A-Za-z0-9_. -' '_' | sed 's/__*/_/g;s/^_//;s/_$//')"

out="${out_dir}/${safe}.audit.json"
i=1; while [ -e "$out" ]; do i=$((i+1)); out="${out_dir}/${safe}.${i}.audit.json"; done
cp "$tmp" "$out"; cp -a "$out" "$arc_dir/" 2>/dev/null || true

sha="$( (sha256sum "$out" 2>/dev/null || shasum -a 256 "$out") | awk '{print $1}')"
size="$(stat -c%s "$out" 2>/dev/null || stat -f%z "$out")"
echo "{\"ts\":${ts},\"kind\":\"audit_json\",\"path\":\"${out}\",\"sha256\":\"${sha}\",\"size\":${size}}" >> asset_registry.jsonl
echo "{\"ts\":${ts},\"capsule\":\"audit_chat_extract\",\"name\":\"${name:-chat}\",\"path\":\"${out}\",\"ok\":true}" >> logs/ops_journal.jsonl
echo "AUDIT_OK path=${out} sha256=${sha}" | tee -a logs/audit_validate.log
rm -f "$tmp"
