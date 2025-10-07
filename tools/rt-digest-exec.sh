#!/usr/bin/env bash
set -euo pipefail
source "$HOME/venv/halu5/bin/activate"
echo "[INFO] train..."
timeout 130s env HALU_TRAIN_BUDGET_SEC=120 HALU_N_LAYER=2 HALU_N_EMBD=192 HALU_CTX_LEN=192 \
  python "$HOME/daegis/tools/train_5min_tinystories.py" || true
echo "[INFO] kpi..."
"$HOME/daegis/tools/halu-kpi.sh"
echo "[INFO] plot..."
python "$HOME/daegis/tools/halu-kpi-plot.py" || true
echo "[DONE]"
