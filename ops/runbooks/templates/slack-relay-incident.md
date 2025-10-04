
## Close-out（復旧後の締め）

- [ ] 直後スナップショット作成：`relay-snapshot.sh` を実行し、パスを下に記録  
      例）`/home/f/backups/relay-YYYYmmdd-HHMMSS.tgz`
- [ ] 署名検証の状態を確認
      - 本番: `SLACK_SIGNING_SECRET` 設定済み / 署名検証 **有効**
      - テスト: 意図的に **無効**（理由を記載）
- [ ] GitHub 反映（任意だが推奨）
      - `git add` → `git commit -m "relay: update / runbooks: <短い要約>"` → `git push`
- [ ] ヘルスタイマー確認  
      `systemctl list-timers | grep halu-relay-health`
- [ ] チャンネル通知の最終確認（ダミー POST など）
- [ ] Ward/Ledger に実施ログ・スナップショットパス・コミットIDを追記
