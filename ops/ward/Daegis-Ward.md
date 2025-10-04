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

## System map refresh (Grok-based)
- created: 2025-10-04T18:16:47Z
- scope: 全体像整理・冗長排除・統合
- action: Runbookへ5層整理＋次アクション追記、ObservabilityへWard/Sentry統合方針を明記
- status: 反映済（Runbook 2025-10-05 版）

## Sora Relay masked
- when: 2025-10-04T18:29:22Z
- reason: EnvironmentFile 不在で再起動ループ。現フェーズでは未使用のため静的に停止
- note: Slack 未配線（SLACK_WEBHOOK_URL 未設定）

## System Adjustments Log
- updated: 2025-10-04T18:30:27Z
- scope: round-table (Pi) — system services & configuration hygiene
- summary:
  - disabled: **daegis-sora-relay.service**  
    → reason: EnvironmentFile 不在で再起動ループ、Slack未配線。mask済み。  
    → next: Citadel導入後に （SLACK_WEBHOOK_URL含む）生成して unmask。
  - unified: **Shell policy** — 実行は bash --noprofile --norc, 対話は軽量rc。Starship 封印。
  - validated: **Mosquitto bus** 1883 LISTEN & ACL 最小構成。  
  - verified: **Orchestrate /health** returns "ok" after Pi reboot。  
  - planned: **Alertmanager 貫通 / ACL 最終化** は保留中（M5 完了後）。

## Ward self-test remediation
- when: 2025-10-04T18:34:43Z
- action:
  - hardened: ward-selftest（healthフォールバック/静音化）
  - cleaned: failed units を整理（*relay masked*, alertmanager disabled, watchdog系停止, hw系mask）
- note: Alertmanager/ACL はM5後半で再開。dnsmasqは未使用前提で停止。

## Ward self-test green & failed-units cleanup
- when: 2025-10-04T18:37:04Z
- result: [units ok], [relay masked ok], [health ok: orchestrate-fallback], [bus quiet-ok]
- change: timers停止・不要ユニット無効化/マスク、reset-failed 済み
- note: /health は一部環境でプレーンor欠落 → フォールバック成功を暫定標準とする

- 2025-10-04T18:38:42Z /health は環境により plain or なし → orchestrate-fallback を標準ヘルスとみなす（M5後半でJSONへ統一）
## Mosquitto ACL (snapshot 2025-10-04T18:38:48Z)
/etc/mosquitto/mosquitto.conf:6:include_dir /etc/mosquitto/conf.d
/etc/mosquitto/conf.d/base.conf:2:allow_anonymous false
/etc/mosquitto/conf.d/base.conf:3:password_file /etc/mosquitto/passwd
/etc/mosquitto/conf.d/base.conf:4:acl_file      /etc/mosquitto/conf.d/daegis.acl

- policy: f=readwrite(暫定, dev用) / others=最小権限。最終化はM5後半。

- 2025-10-04T18:42:20Z rt-health を ward-selftest に組み込み（/health→/orchestrate フォールバック一元化）

- 2025-10-04T18:43:44Z ops小改修: rt-smoke標準化/mqtt-smoke追加、mosquitto.acl.sample用意、linger有効

- 2025-10-04T18:45:42Z ops小粒: aliases自動読込、ACLサンプルを/etcへステージ、日常確認の定型コマンド整備

## Ops CLI hardening (bin links)
- when: 2025-10-04T18:56:18Z
- done: rt-smoke を rt-health 経由に統一、logrun を再生成（rc 伝播・stdin/argv 両対応）

## Baseline Snapshot (2025-10-04T18:57:28Z)
- rt: [health ok: orchestrate-fallback]
- smoke: [rt-smoke ok]
- mqtt: [mqtt quiet-ok]

### systemd failed (should be empty)
- 2025-10-04T19:00:19Z ACL enable howto をRunbookに補足

- 2025-10-04T19:02:06Z ACL有効化を確認：anon=DENY / user(f)=ALLOW を検証（pub/sub）。

## dfctl 状況（2025-10-04T19:13:59Z）
- state: 利用停止（Pi未配置のためコマンド無効）
- note: 機能説明は Geminiログ参照（管理系CLIツール）
- 保管想定: ~/daegis/ops/dfctl.py （未配置）
- 再開条件: Pi上に dfctl.py を配置後、 ~/bin/dfctl にリンクを張る

## ACL cleanup & verify (2025-10-04T19:23:32Z)
- action: mqtt-retain-clear で `daegis/selftest/acl`, `daegis/factory` の retained を一掃
- verify: anon=blocked(handshake) / auth=PASS / anon publish=not visible
- note: ward-selftest に anon blocked チェックを追加済み

- 2025-10-04T19:33:37Z Mosquitto SoT化（/etc/mosquitto/mosquitto.conf 単独）・localhost限定・ACL強制。anon拒否/認証OKを確認。

- 2025-10-04T19:35:35Z Mosquitto SoT化（/etc/mosquitto/mosquitto.conf 単独）・localhost限定・ACL強制。anon拒否/認証OKを確認。
