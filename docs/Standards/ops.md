# Ops Standard (Daegis)
- 常駐は systemd user unit:
  - service: ~/.config/systemd/user/<name>.service
  - timer  : ~/.config/systemd/user/<name>.timer
- バックアップ命名: ark/backups/<topic>.<YYYY-MM-DD>.tgz
- 手動テストの原則: `systemctl --user start <name>.service` 後、成果物を `ls -lh` / `tar tzf` で検証
- ログ所在:
  - Halu: ~/halu/logs -> ~/daegis/ark/logbook (symlink)
- Mac⇔Pi 同期は rsync ツールを ~/daegis/tools/ に置く
