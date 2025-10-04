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
