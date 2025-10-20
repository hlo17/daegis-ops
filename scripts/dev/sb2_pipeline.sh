#!/usr/bin/env sh
# SB2 → L9 → L10 のドライ常設パイプ（append-only）
# - SB2 提案を生成してから、AutoTune(dry)→Apply Planner を実行
# - SB_MIN_CONF_TAG（既定=mid）で v2 だけ信頼度ゲート
# - 失敗しても fail-closed（exit 0）で他の監視に影響しない
set -eu
ROOT="${ROOT:-$(pwd)}"
cd "${ROOT}" 2>/dev/null || true
export PYTHONUNBUFFERED=1
[ -d .venv ] && . .venv/bin/activate || true
export PYTHONPATH="${PYTHONPATH:-$PWD}"

# 1) SB2 提案（bootstrap優先／無ければsimbrain_v2.py）
if [ -f scripts/learn/simbrain_v2_bootstrap.py ]; then
  python3 scripts/learn/simbrain_v2_bootstrap.py || true
elif [ -f scripts/learn/simbrain_v2.py ]; then
  python3 scripts/learn/simbrain_v2.py || true
fi

# 2) L9/L10 実行（v2のみ confidence でゲート。従来候補は素通し）
export SB_MIN_CONF_TAG="${SB_MIN_CONF_TAG:-mid}"
python3 scripts/learn/auto_tune_dry.py || true
# 2.5) SB2 タグ注入（confidence_tag/source を L10 に渡す）
python3 scripts/learn/sb2_tag_inject.py || true
python3 scripts/learn/apply_planner.py || true

echo "[sb2-pipeline] done (SB_MIN_CONF_TAG=${SB_MIN_CONF_TAG})"

# -- v2 tag inject + re-plan (append-only) --
python3 scripts/learn/sb2_tag_inject_v2.py || true
python3 scripts/learn/apply_planner.py || true
echo "[sb2-pipeline v2] tag-inject+replan done (SB_MIN_CONF_TAG=${SB_MIN_CONF_TAG:-mid})"
exit 0
# --- [append-only] sb2 injector hotfix chain v2025-10-10 ---
# 1) 既存を優先（エラーは握りつぶす）
python3 scripts/learn/sb2_tag_inject_v2.py >/dev/null 2>&1 || true
# 2) 候補が乏しい/low しか流れない場合に hotfix を併用
HAS_CAND=$(tail -200 logs/policy_auto_tune.jsonl 2>/dev/null | grep -c '"event":"auto_tune_candidate"')
if [ "${HAS_CAND:-0}" -eq 0 ]; then
  python3 scripts/learn/sb2_tag_inject_v2_hotfix.py >/dev/null 2>&1 || true
fi
# --- end hotfix chain ---
# --- [append-only] adopt guard kick v2025-10-10 ---
bash scripts/learn/auto_adopt_gate_guard.sh || true
# --- end adopt guard kick ---
