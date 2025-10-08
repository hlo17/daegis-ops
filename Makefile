.RECIPEPREFIX := >
.PHONY: bootstrap check test kpi weekly

bootstrap:
> python -m pip install -U pip pre-commit pytest ruff
> pre-commit install

check:
> pre-commit run -a
> pytest -q

test:
> pytest -q

# 例: make kpi TASK=router-health TTR=12 KS=30 ACC=10 TOT=24 PASS=1
kpi:
> python - <<'PY'
> import json,os,subprocess
> d={
>   "task": os.getenv("TASK","unknown"),
>   "ttr_min": float(os.getenv("TTR","0")),
>   "keystrokes": int(os.getenv("KS","0")),
>   "copilot_accepts": int(os.getenv("ACC","0")),
>   "copilot_total": int(os.getenv("TOT","0")),
>   "test_pass": int(os.getenv("PASS","0")),
> }
> subprocess.check_call(["python","scripts/kpi_update.py", json.dumps(d)])
> PY

weekly:
> python scripts/kpi_weekly_summary.py
