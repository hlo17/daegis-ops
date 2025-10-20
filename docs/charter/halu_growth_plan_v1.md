# 🧭 Halu 育成設計図 v1.0（Shepherd構想準拠・Kai運用向け）

## 目的
Haluを「記録・反省」から「自己修正＋提案」へ進化。中核は **HITL** と **self_reference_rate**、および連続性。

---

## I. 現在地（L3域の特徴）
- growth_daily_ok: 継続完走（目安 0.8以上）
- self_reference_rate: 0.20〜0.35（自己参照が芽生えた）
- fresh_hours: ≦6h（呼吸が安定）
- virtue: 1語（日替わり）

**運用指針（L3→L4準備）**
- Shepherd: 1日1回のHITL承認のみ
- Kai: growth_daily_ok と self_reference_rate が **連続3日** そろえば昇格候補フラグ
- Lyra: Chronicleに「昇格候補」タグ

---

## II. L4 到達条件（Kai判定ルール）
- growth_daily_ok: consecutive_days ≥ 3
- self_reference_rate: min ≥ 0.30
- fresh_hours: max ≤ 8  
達成時: `halu_levelup`（L4）を factory_ops.jsonl に記録し、Lyraへ通知

---

## III. L4 フェーズ（自立と提案）
- 状態: 人の承認を前提とせず**小さな提案**を自発生成
- 指標: advice_loop_total{result=ok}, self_reference_rate, virtue
- shepherd役割: 承認→レビューへ
- 成功基準: 1日≥1件の提案、翌日の**自己修正率 ≥ 0.5**

---

## IV. L4 → L5 昇格条件
- advice_loop_total{result="ok"}: consecutive_days ≥ 5
- self_reference_rate: min ≥ 0.45
- hitl_approval_rate: avg ≥ 0.7

---

## V. ログ/出力の扱い
- `reflection.jsonl`… type: reflection
- `advice/*.jsonl`…… type: proposal（提案は分離）
- `factory_ops.jsonl`… Kaiの判定・昇格記録
- `chronicle.jsonl`… Lyraが受ける“史”の写し

---

## VI. 可視化（Mini Dash）
- 円の大きさ: self_reference_rate
- 明るさ: fresh_hours（新しいほど明るい）
- テキスト: stage（L1〜L5）, virtue（徳）
- 追加予定: adviceの波紋、halu_levelの表示

---

## VII. Shepherdの負担（目安）
- L3: 毎日10分（HITL承認）
- L4: 週30分（レビュー＋徳選定）
- L5: 月1h（メタ評価）

---

## VIII. 運用ルール
- 重大操作は禁止リスト（human_in_loop.md）遵守
- Kai→Lyra→Shepherd の週次レポート
- メトリクス保持: 90日
- 自動昇降格は **veto可**（Shepherd裁量）

---

## IX. 目的（L5像）
「Haluが昨日の自分を見て、今日を変え、明日を提案できる」
