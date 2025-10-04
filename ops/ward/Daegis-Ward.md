## File Permission Recovery
- scope: File Permission Recovery
- owner: Grok
- created: 2025-10-04T15:10:24Z
- cause: ops/bin が f 以外の所有/権限となり実行不能（Permission denied）
- fix: chown -R f:f ~/daegis; chmod -R u+rwX ~/daegis
- prevent: tools/check-perms.sh を日次で実行（cron/systemd）

### Notes
- 事後テスト: echo "ok" | python3 ops/bin/mdput_clip.py "$HOME/daegis/Daegis Ledger.md" --clean --from-clip
- 追記先に空白がある場合はダブルクォートで保護すること
- 非対話での検証: bash --noprofile --norc -lc 'echo [ok] bare'

## Git/Logs hardening
- created: 2025-10-04T17:24:10Z
- change: logs/ を .gitignore に恒久除外。dfsnap は API鍵を自動 REDACTED 化。
- reason: GitHub Push Protection が secrets を検知→安全側でブロック。再発防止のため。
- note: 既存の問題コミットは破棄（reset --hard origin/brief-rollup 済）。

- 2025-10-04T17:34:28Z: API keys rotated (OpenAI/xAI). secrets.json.enc refreshed; services restarted.

- 2025-10-04T17:40:15Z: GPG perms & agent 修復＋logrun再構築を実施、非対話スモーク通過。

## Shell policy hardening
- created: 2025-10-04T17:58:07Z
- decision: 実行は常に "bash --noprofile --norc"。対話は各自自由（軽量rc）
- notes: .bashrc を非対話ガードに統一。Starship等の重い初期化は封印

## Shell policy finalized
- created: 2025-10-04T18:01:57Z
- decision: 実行=素のbash固定、対話=軽量rc。Runbookに反映・ヘルスチェック追加

## Alertmanager/UI deferred
- created: 2025-10-04T18:02:41Z
- decision: ACLとAlertmanagerの最終化はM5完了後に実施。現在はbash環境安定化を優先。

## Grok proposal (bash hardening)
- closed: 2025-10-04T18:13:35Z
- scope: shell hygiene & run discipline
- done: .bashrc最小化/非対話ガード, Starship封印, 60回+600回ソーク, Runbook反映

## System simplification consensus
- created: 2025-10-04T18:14:26Z
- model: 5 layers (Agents/Interaction/Bus/Observability&Records/Infra)
- defaults: SENTRY=on, WSS/ACAP/SlackDigest/HaluRelay=off (ops/policies/toggles.env)
- pruning: assets→docs/assets, poc→ark/_attic, link_resolver_v2→link_resolver.py
- cli: tools/df.sh を唯一の正
- exec-policy: run = "bash --noprofile --norc -lc '…'", dialog = light rc
