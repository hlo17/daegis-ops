# 📜 Daegis Map — ver. 3.0

## Guiding Principles
1. **Simplicity** / 2. **User-Centricity** / 3. **Evolution**

## Communication
- Markdown統一。AIは**箇条書き4点法**（案名/長所/短所/出典）。
- 共有の最小単位：Relay last / Ledger p<id> / Slack permalink。
- 周知: #daegis-roundtable、AIドラフト: #daegis-ai-drafts。

## Dev & Ops
- 壊れた行は**既知の良形へ丸ごと置換**。
- 実行単位：依存強→**ブロック**、単発→**行ごと**。
- 表記: `Mac:` / `Pi:`。変更後: `__pycache__`掃除→systemd再起動→経路テスト。
- 切り分け順: Broker → Relay → Scribe → Slack。
- 詳細: [[command-execution-guide.md]]

### Self-Defense & Auto-Maintenance Layer
- Daegisは自己防衛・自動整備レイヤを採用し、Runbook/Hotkeys/Guards/CIを標準構成とする。恒久的な引き継ぎ窓口は `ops/runbooks/AI-Handoff.md` と `.ai/manifest.json`。
