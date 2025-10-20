# 🧭 Daegis — 30秒版 Runbook（現場即応用）
_Append-only / Minimal / 現場オペ用テンプレ_

---

## ① 停止系（緊急／VETO／ロールバック）

### VETOを立てる
```bash
bash scripts/guard/veto_toggle.sh on
```
- `flags/L5_VETO` が存在していることを確認
- 以降、L10/L5.2 は自動適用を停止

### ロールバック
```bash
nano scripts/dev/env_local.sh
# → known_good の export 行を再掲し保存
source scripts/dev/env_local.sh
pkill -f "uvicorn.*router.app" || true; sleep 1
python -m uvicorn router.app:app --host 0.0.0.0 --port 8080 &
# 監査ログへ撤回の事実を追記（policy_apply_controlled.jsonl に append）
```

---

## ② 適用系（ENV昇格）

### 候補確認
```bash
tail -10 scripts/dev/env_candidates.sh
```
→ `export DAEGIS_SLA_*_MS=` が出ていることを確認

### 適用
```bash
cat scripts/dev/env_candidates.sh >> scripts/dev/env_local.sh
source scripts/dev/env_local.sh
pkill -f "uvicorn.*router.app" || true; sleep 1
python -m uvicorn router.app:app --host 0.0.0.0 --port 8080 &
```

### 状態確認
```bash
curl -s localhost:8080/health
bash scripts/dev/dashboard_lite.sh
```

---

### 🧩 ヒント
- `flags/L5_VETO` が存在 → L10/L5.2 自動適用スキップ
- `logs/policy_apply_plan.jsonl` の最新行が採用候補
- `scripts/dev/log_retention.sh` で古いログ削除（14日既定）