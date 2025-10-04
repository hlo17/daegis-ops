
## 開発環境ポリシー（Shell運用）
- updated: 2025-10-04T18:00:11Z
- principle: 実行は常に **bash --noprofile --norc -lc '…'**
- rationale: 完全な非対話・無菌環境で再現性を確保（AI生成コードを全マシンで同挙動に）
- interactive: 各自の軽量rcを許可（補完・履歴など最小限の快適性のみ）
- 禁止事項:
  - Starship等の重い初期化を自動起動に含めない
  - exit/return系トリガをrcに書かない
- 合言葉: 「**実行は素のbash、対話は好み**」が唯一の正

## 開発環境ポリシー（最終）
- updated: 2025-10-04T18:01:57Z
- **唯一の正**: 実行はつねに `bash --noprofile --norc -lc '…'`。対話は各自の**軽量rc**（重い初期化は不可）
- rationale: ローカル設定に依存しない**再現性**と**安定性**を担保
- 禁止: Starship 等の重い初期化の自動起動／rc内の exit/return トリガ／外部 eval
- 運用スニペット:
  - 直近ログ: `bash --noprofile --norc -lc 'ls -1t "/home/f/daegis/logs"/*.log 2>/dev/null | head -1 | xargs -r tail -n +1'`
  - スモーク: `bash --noprofile --norc -lc '"/home/f/daegis/tools/rt-smoke.sh"'`

### 実行テンプレ（コピペ可）
```bash
bash --noprofile --norc -lc '
  curl -fsS -X POST "http://127.0.0.1:8010/orchestrate"     -H "content-type: application/json" -d "{\"task\":\"daily test\"}" | jq -e .
'
```

### ヘルスチェック手順
1) **Roundtable**: /orchestrate に60連投 → 成功で [smoke-ok]  
2) **Mosquitto**: 127.0.0.1:1883 の LISTEN を確認  
3) **ログ**: `loglast` で直近 run の JSON を確認  

### トラブルシュート（抜粋）
- 退出トリガ疑い: `grep -nE "^[[:space:]]*(exit|return[[:space:]]+0)\b" ~/.bashrc || echo "[clean]"`
- GPG 非対話: `~/.gnupg` の perms 700/600、gpg.conf の `pinentry-mode loopback`
