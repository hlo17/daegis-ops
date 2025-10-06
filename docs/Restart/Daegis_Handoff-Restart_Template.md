# 🧭 Daegis Handoff-Restart Template
_Updated: 2025-10-05 17:06 JST_

この文書は、Daegis プロジェクトを新しいチャット・AI環境に移行するときに、
どのファイルをアップすれば即座に再開できるかを示す標準手順書です。

---

## 🔹 Step 0：このプロンプトを貼る

```
# Daegis Handoff — Chat Restart Prompt

このチャットは Daegis プロジェクトの続きです。  
過去の手動・自動ログ（auto-brief / hand-off / ledger）をもとに環境を再構築してください。  
参照ファイルを順にアップロードします。
```

---

## 🔹 Step 1：必須ファイル（最低限この2つ）

| ファイル | 役割 | 内容 |
|-----------|------|------|
| **Daegis_HandOff.unified.md** | 最新状態のスナップショット（今どこ・次何・リスク・キーワード） | 現場状態・自動brief・同期タイマー設定など |
| **Daegis_Ledger.unified.md** | 確定した決定・UID・ルールの原本 | 仕様・命名・主要UID・責務マップなど |

💡 この2つをアップするだけで、「どのAIでも前回の状態から再構築」できます。  
手動でアップできない場合は、「ファイル名と概要」をコピペでも可。

---

## 🔹 Step 2：任意ファイル（精度を上げたい場合）

| ファイル | 意義 |
|-----------|------|
| **brief.md** | 最新の自動要約（auto-brief の出力） |
| **hand-off.md** | 日次スナップショット（`brief.md` の同期結果） |
| **ledger.md** | 手動追記が残っている場合はこちらを優先 |
| **map.md** | 全体構成図・RACI・依存関係など |
| **guidelines.md** | 運用ルール・命名・文書方針 |
| **chronicle.md** | 日次時系列ログ・履歴参照用 |

---

## 🔹 Step 3：確認用ワンライナー

```bash
# タイマー稼働確認
systemctl --user status auto-brief.timer sync-hand-off.timer --no-pager

# 最新ハンドオフの要約出力
ls -l /srv/round-table/brief.md ~/daegis/records/hand-off.md

# 直近ログ
journalctl -t auto-brief -t sync-hand-off -n 20 --no-pager
```

---

## 🔹 Step 4：AIへの指示テンプレ

```
Daegisの現行ハンドオフを読み込み、現在の状況（status）・次の行動（next）・注意点（risks）・関連キーワード（keywords）を要約してください。
その上で、Haluトレーニング（RAG v0, FTS5, verdict loop）を次のフェーズとして再開します。
```

---

## 🔹 Step 5：ファイルをアップしたあと言う一言

```
すべてアップしました。前回の続きから復元してください。
```

---

## 🧩 最小構成まとめ

| レベル | 目的 | 必要ファイル |
|---------|------|---------------|
| 🔰 基本再開 | 前回状態の再構築 | `Daegis_HandOff.unified.md`, `Daegis_Ledger.unified.md` |
| 💡 詳細再現 | 状況＋履歴＋設定まで再現 | ＋ `brief.md`, `hand-off.md`, `ledger.md` |
| 🧠 高精度トレーニング | 全履歴・方針・RACI・規範を学習 | ＋ `map.md`, `chronicle.md`, `guidelines.md` |

---

## ✅ 保存推奨場所

`ops/runbooks/AI-Handoff.md` の末尾、または `docs/setup/Daegis-Chat-Restart.md`  
→ 次回のチャット立ち上げ時に、上記テンプレをコピペすれば即復元可能。

---

## 🪶 備考

- このテンプレートは AI 種別非依存（GPT / Gemini / NotebookLM / Grok / Perplexity 等）  
- ファイル構成を最小化しても再構築できるよう、HandOff と Ledger を中核に設計。  
- 参照キーワード：`Daegis Hand-off unified` / `Daegis Ledger unified` / `auto-brief` / `sync-hand-off`
