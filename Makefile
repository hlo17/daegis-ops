.RECIPEPREFIX := >
VENV := .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
PRECOMMIT := $(VENV)/bin/pre-commit
PYTEST := $(VENV)/bin/pytest

.PHONY: bootstrap check test kpi weekly

bootstrap:
> test -d $(VENV) || python3 -m venv $(VENV)
> $(PY) -m pip install -U pip
> $(PIP) install pre-commit pytest ruff
> $(PRECOMMIT) install

check:
> $(PRECOMMIT) run -a
> $(PYTEST) -q

test:
> $(PYTEST) -q

# 例: make kpi TASK=router-health TTR=12 KS=30 ACC=10 TOT=24 PASS=1
kpi:
> $(PY) scripts/kpi_update.py \
>   "$$(jq -nc --arg task "$(TASK)" --argjson ttr_min $(TTR) --argjson keystrokes $(KS) \
>   --argjson copilot_accepts $(ACC) --argjson copilot_total $(TOT) --argjson test_pass $(PASS) \
>   '{task:$$task,ttr_min:$$ttr_min,keystrokes:$$keystrokes,copilot_accepts:$$copilot_accepts,copilot_total:$$copilot_total,test_pass:$$test_pass}')"

weekly:
> $(PY) scripts/kpi_weekly_summary.py
