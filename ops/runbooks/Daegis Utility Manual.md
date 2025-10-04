# Daegis Utility Manual (short)
- **Hotkeys**: `source tools/hotkeys.sh ; hk help`
- **Deliver**:
  - `hk deliver-auto <src> <user@host> <path> [--chmod=0755] [--owner=u] [--group=g] [--sudo]`
  - 小さい/ASCII安全: base64 経路、大きい/バイナリ混在: scp 経路
- **Guards**:
  - Git hooks: `.githooks/`（Slack URL/文字種ガード）
  - CI: `.github/workflows/…`（Handoff/typography/secret scan）
- **Troubleshoot**:
  - 端末が落ちる: `bash --noprofile --norc -l` → `source ~/.bashrc` で原因特定
  - 文字化け: `bash tools/scan-typography.sh` → `bash tools/fix-typography.sh`

## Appendix: 軽量ガードと緊急復旧
- ~/.bashrc の先頭:
  - `: "${VSCODE_PYTHON_AUTOACTIVATE_GUARD:=}"`
  - `: "${HISTCONTROL:=ignoredups}"`
  - `case $- in *i*) ;; *) return ;; esac`
- 多行は bash に貼る（zsh でも普段使い可）
- hk が壊れたら:
  - `bash -n tools/hotkeys.sh`
  - `source tools/hotkeys.sh` / または “素”で `tools/deliver-*.sh`
- フックが止める:
  - 直す: `hk hooks-fix`
  - 急ぎ: `git -c core.hooksPath=/dev/null commit/push`

### Terminal Ops Rules (quick)
- `.bashrc` は薄く：対話ガード＋Starship（任意）＋フォールバックPS1のみ
- 非対話（フック/CI/拡張/cron）は“素のbash”前提
- 緊急時：`~/bin/recover-bash.sh` → 即復旧
- Starship で不調なら `starship-off` で即切り替え
