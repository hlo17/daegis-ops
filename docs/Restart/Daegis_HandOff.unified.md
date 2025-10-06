# Daegis Hand-off — Unified (auto-brief × snapshot) — 2025-10-05 16:42 JST

## Scope & Audience
**Scope**: Halu トレーニング期（RAG→評価固定→LoRA）を支える観測・要約・指令の統合。  
**Audience**: 次担当者／円卓AI（Halu, Oracle, Grok, Gemini, Perplexity, NotebookLM）／オーナー。

---

## 0) 運用方針（結論）
- **一次情報源**：`/srv/round-table/brief.md`（auto-brief, 08:55 JST 日次生成）  
- **二次（公式スナップショット）**：`~/daegis/records/hand-off.md` に **毎日自動同期**  
  - 目的：監査・再現性・学習データ化（Halu 学習用の状態確定ログ）
- **可視化/監視**：Promtail→Loki→Grafana ダッシュボード「Daegis / Auto-Brief Logs」＋ Managed Alert
- **通知**：Slack `#daegis-roundtable`（Digest/共有）／`#daegis-alerts`（Alerts）

---

## 1) 現在の状況（完了/到達点）
- **ログ収集**：Promtail 稼働（`__path__: /var/log/daegis/*.log`）。正規化 `time= level= msg="..."` で `level` をラベル化。  
  `positions.yaml` は `/var/log/daegis/auto-brief.log` のみ保持に整理済み。
- **可視化**：Grafana「Daegis / Auto-Brief Logs」導入・稼働。変数 `$job,$host`、全パネル DS=Loki。
- **アラート**：Managed Alert 稼働（Rule UID: **ff05cw894ui9sa** / Folder UID: **dezp28u2u1q0wf** / DS UID: **df04lyc3gb9c0b**）。  
  Query: `sum(count_over_time({job="daegis",host="round-table",level="error"}[5m]))`、`for=5m`、receiver=`daegis-slack-webhook`。
- **自動ブリーフ**：`/usr/local/bin/auto-brief.py`（`urllib.request` で OpenAI 呼出, UTF-8）。  
  出力：`/srv/round-table/brief.md`（Git 連携可）。`auto-brief@{USER}.service/.timer`（毎朝 08:55 JST）。Slack 投稿 OK。  
- **稼働経路**：Slack Slash → FastAPI (slack2mqtt) → MQTT → Halu / Oracle。Cloudflare named Tunnel「bridge」終端。  
  Halu/Oracle の `tell-*` コマンド動作・評価スキーマ（✅/🛠/❌ + reason）固定済み。

---

## 2) 次にやること（優先度順）
1. **OPENAI_API_KEY を unit drop-in で固定**（未確認なら確認）：  
   `/etc/systemd/system/auto-brief@.service.d/env.conf` → `daemon-reload` → restart。
2. **ダッシュボード微調整**：  
   - Stat「直近1時間の error 件数」= `sum(count_over_time({... level="error"}[1h]))`  
   - 「最近のエラー」= `{job="$job",host="$host",level="error"} | line_format "{{.msg}}"`
3. **アラート運用テスト（単発）**：`for=0s` → エラー1行投入 → 受信確認 → `for=5m` に戻す。  
4. **バックアップ取得**：Dashboard JSON／Alert Rules／Promtail config+positions。  
5. **RAG v0 接続**：SQLite FTS5 で過去応答（why/policy）全文検索→上位3件を Halu へ注入。  
6. **評価保存の固定**：`daegis/feedback/<agent>` へ `{id,agent,label,reason,ts}` を 1行JSON、DuckDB/Parquet に蓄積。  
7. **Oracle verdict 集計**：✅/🛠/❌ 比率＋相関ID一致率を計測・可視化。  
8. **LoRA “型矯正” 初回A/B**：✅/🛠 サンプル 500〜1,000 件で 3行方針の型補正。

---

## 3) 注意点・リスク
- **HEREDOC 終端**：末尾を `PY` 単独行で終了（ゴミ混入防止）。  
- **文字コード**：`LANG/LC_ALL/PYTHONIOENCODING=UTF-8`、`open(..., encoding="utf-8")`（latin-1 回避）。  
- **positions 汚染**：旧 `/home/f/daegis/logs/...` 残置で再取込スパイク → 変更後は promtail 再起動。  
- **Grafana API**：Alert 更新は **PUT /provisioning/alert-rules/{uid}**。`folderUID` 未指定・`execErrState` 不正値に注意。  
- **鍵管理**：`OPENAI_API_KEY` は unit drop-in のみ。履歴や world-readable を避ける。  
- **LogQL 窓**：可視化は `[$__interval]`、判定は固定窓 `[5m]` が安定。  
- **21時スパイク**：旧パス backfill 由来。positions 整理により収束済み。

---

## 4) Quick Commands（確認系）
- **直近5分 error 件数**  
  `curl -G -s http://127.0.0.1:3100/loki/api/v1/query --data-urlencode 'query=sum(count_over_time({job="daegis",host="round-table",level="error"}[5m]))'`
- **アクティブアラート**  
  `curl -sS -H "Authorization: Bearer $GRAFANA_API_TOKEN" "http://localhost:3000/grafana/api/alertmanager/grafana/api/v2/alerts?active=true" | jq`
- **ルール更新（for=0s 例）**  
  `curl -sS -H "Authorization: Bearer $GRAFANA_API_TOKEN" http://localhost:3000/grafana/api/v1/provisioning/alert-rules/<UID> | jq '.for="0s"' | curl -sS -H "Authorization: Bearer $GRAFANA_API_TOKEN" -H "Content-Type: application/json" -X PUT -d @- http://localhost:3000/grafana/api/v1/provisioning/alert-rules/<UID>`

---

## 5) 引き継ぎキーワード
- **プロジェクト**：Daegis / Roundtable  
- **主要パス**：`/srv/round-table/brief.md`（一次）／`~/daegis/records/hand-off.md`（二次）  
- **主要サービス**：`daegis-slack2mqtt.service`、`cloudflared-bridge.service`、`auto-brief@.service/.timer`  
- **トピック**：`daegis/feedback/<agent>`（評価ログ）  
- **タグ**：RAG v0 / LoRA型矯正 / 評価保存固定 / Oracle verdict 集計 / 3行方針 / heuristic / FastAPI bridge

---

## 6) Snapshot（5行）
- **経路**：Slack Slash → FastAPI(slack2mqtt) → MQTT → Halu/Oracle 本稼働。  
- **トンネル**：Cloudflare named Tunnel「bridge」→ FastAPI 終端・DNS 張替え済。  
- **評価**：スキーマ（✅/🛠/❌ + reason）固定。  
- **短期方針**：RAG導入→評価保存固定→来週 LoRA“型矯正”。  
- **可観測化**：Promtail→Loki→Grafana＋Managed Alert、Slack 通知導線あり。

---

## 7) 即時バリデーション（60秒）
1) `systemctl --user status auto-brief@${USER}.service`（Active）  
2) `journalctl -u promtail -n 50 | tail`（parse error 無し）  
3) Grafana で `$job=daegis/$host=round-table` 表示OK  
4) “直近5分 error 件数” の curl が 0 or 想定値  
5) `brief.md` の更新時刻が今朝 08:55±1分


## [2025-10-06] Finder-based Snapshot Automation

- **導入:** dotfiles や ops 状況を自動的に Markdown に記録し、Finder で自動ポップアップ。  
- **実行例:** `ops/ward/dotfiles-audit-*.md`  
- **目的:** 手作業環境変更の可視化と、Halu トレーニング運用への継承。  
- **継承対象:** Halu Ops にも同形式の `ward` 記録を導入予定。
