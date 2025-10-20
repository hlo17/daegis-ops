📜 **Daegis — 監査エビデンス テンプレート（L7〜L10）**

- 日付（UTC）: _実行時に記入_
- 環境: _hostname_
- 状態: ✅ 通常運転（`flags/L5_VETO` = 無）

---

### SimBrain 提案ログ（L7）
```bash
tail -5 logs/simbrain_proposals.jsonl | jq '.'
```

### Auto-Tune 候補（L9）
```bash
tail -5 logs/policy_auto_tune.jsonl | jq '.'
```

### Apply 計画（L10）
```bash
tail -5 logs/policy_apply_plan.jsonl | jq '.'
```

### Sentinel/VETO 状況（L11）
```bash
ls -l flags/L5_VETO || echo "no veto (OK)"
```

> 提出要領: 上記各セクションの出力をそのまま貼付。Dashboard Lite の最新スナップショット添付推奨。