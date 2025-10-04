2025-10-05: Shell運用を統一—実行は素のbash、対話は軽量rc（再現性確保）。
2025-10-05: 開発環境ポリシーをRunbookへ確定—実行はbash --noprofile、ヘルスチェック常設。
2025-10-04: 合意—5層モデル採用・既定OFF(WSS/ACAP/SlackRelay)・CLIをtools/df.shに統一。
2025-10-04: 全体像(Grok版)をRunbookへ採用—弱点対処優先・Halu Relay活性化を即時実施の方針。
2025-10-05: Sora Relay を mask—未使用 & env 不在のため再起動ループを停止。
2025-10-05: round-table構成調整 — Sora Relay停止、Shell統一、Bus/Health確認完了。
2025-10-04: Ward自己診断を強化し、不要な失敗ユニットを整理（赤ゼロ方針）。
2025-10-04: Ward self-test green—failed units 0、フォールバック健全性で常時監視。
2025-10-04: Ward自動ヘルス導入—毎時セルフテストで赤ゼロ維持。
2025-10-05: rt-health を常設セルフテストに統合—ヘルス判定の基準を単一路に統一。
2025-10-05: 小粒仕上げ—rt-smoke標準化・MQTTスモーク・ACLサンプル・linger。
2025-10-05: ops小粒仕上げ—aliases自動化/ACLステージ/確認系整備。
2025-10-05: ops CLI 常設—rt-smoke/rt-health 統一・logrun 再生成・~/bin リンク確立。
2025-10-05: Baseline確立—rt/mqtt/units=GREEN、ACL準備配置（未有効）。
2025-10-05: Mosquitto ACL 有効化—anon拒否・認証成功を確認。
2025-10-05: dfctl 利用停止—Pi未配置のため無効化。保管先 ~/daegis/ops/dfctl.py を予約。
2025-10-05: ACL掃除→再検証—anon遮断/auth通過を確定、再発検知はward-selftestに委譲。
2025-10-05: Mosquitto SoT確立＆ACL強制—auth PASS/anon BLOCKを恒常化。
