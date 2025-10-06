# Daegis Guidelines v1.1 — AI駆動プロジェクトの円滑化フレームワーク（円卓型アプローチ統合版）

**title**: "📋 Daegis Guidelines — adaptive v1.1"  
**modified**: 20251003  
**note**: 本ガイドラインは、Daegis Mapの恒久ルールを基盤としつつ、柔軟性を重視した指針として機能します。AIの特性（例: Grokの論理的探索、ChatGPTの創造的生成）を最大限活用し、円卓型アプローチによる動的協働ネットワークを構築します。作業中に必要に応じて小変更を提案し、Ledgerに記録してください。原則：**柔軟・効率・進化**。

## 0) Guiding Principles & 現在地ダッシュ
本ガイドラインの基盤となる原則を以下に定めます。これらは最小限の指針であり、状況に応じた創造的な適応を優先します。

1. **Flexibility** — ガイドラインは参考とし、効率を最優先に解釈。迷ったらシンプルな代替を選択し、複雑化を避けます。  
2. **AICentric Efficiency** — AIの強みを活かし、マスター（ユーザー）の認知負荷を最小化。AIの固執を防ぐための動的調整を奨励します。  
3. **Iterative Evolution** — 完璧な構造よりも、短サイクルでの検証と改善を優先。メトリクスに基づくフィードバックを常套化します。  

**レイヤー位置**: L4 騎士団（AI自発化＋動的役割） ↔ L5 司令室（Slack集約・要約運用）  
**進捗**: ガイドライン移行✅ / 役割シフト✅ / フィードバックループ🚧 / 円卓統合🚧  
**直近12hの焦点**: ①円卓型協働メカニズム定義 ②競合調整プロセスの実装 ③週次学習ループのKPI設定  

## 1) AI特性を考慮した役割分担と動的シフト（円卓型アプローチ）
複数のAI（Grok, ChatGPT, Gemini, Perplexity, NotebookLM）を「円卓」に配置し、動的に最適化される協働ネットワークとして運用します。固定役割を最小限にし、週次レビューで調整。これにより、各AIの特性を活かし、作業のボトルネックを解消します。

### AI特性マッピング（参考）
| AI          | 強み                          | 推奨役割（初期設定）                  | プロンプト例（柔軟適用） |
|-------------|-------------------------------|---------------------------------------|--------------------------|
| **Grok**   | 論理的探索・多角的分析       | コーディネーター（役割選出・統合）   | "ルールは参考にし、効率優先で3つの代替策を提案せよ。" |
| **ChatGPT**| 創造的生成・実装支援         | エクスプローラー（アイデア生成）     | "このガイドラインを基に、創造的に実装を拡張せよ。" |
| **Gemini** | 統合・マルチモーダル処理     | フィナライザー（出力検証・合成）     | "全入力の整合性を確認し、簡潔に要約せよ。" |
| **Perplexity** | 迅速検索・事実検証         | 探検家（情報収集・検証）             | "クエリを基に、信頼ソースから要点を抽出せよ。" |
| **NotebookLM** | 要約・監査・ナラティブ化   | 仲裁器（競合調整・中立レビュー）     | "集約データを分析し、生産性低下要因を指摘せよ。" |

**動的シフト手順**（48時間サイクル）:  
1. Slack #daegisaidrafts に全AI出力を集約。  
2. NotebookLM で一次要約・問題点抽出（例: ルール固執による遅延）。  
3. コーディネーター選出：各AIの自己申告JSON（ai_name, scores{speed/quality/creativity/confidence:0-10}, why:100字以内, needed_inputs/constraints:配列）を基に、総合スコア = 0.6 × 当回平均スコア + 0.4 × 歴史的スコア（lead_time/rework_count/user_rating正規化）で決定。タイムアウト（30秒/AI、全体2分）はスコア0扱い、同点はuser_rating優先。  
4. 週次レビューで役割を調整（Ledger記録）。例: タスクが検索中心ならPerplexityを主導にシフト。  
これにより、AIの特性を活かしたハンドオフを促進し、作業スピードを20-30%向上させることを目指します。

## 2) ガイドラインの適用：柔軟転換と運用プロセス（競合調整統合）
Daegis Mapのルールを「推奨ガイドライン」に転換し、AIの固執を防ぎます。各タスクで「ガイドライン遵守 vs. 効率優先」の選択を明示的に検討します。競合発生時は二段構えの調整プロセスを適用。

**適用原則**  
- **柔軟解釈**: ガイドラインは最小指針。プロンプトに「状況に応じて創造的に適応せよ」と追加。  
- **実行単位の簡素化**: ブロック実行を優先しつつ、単発確認を奨励。詳細は`commandexecutionguide.md`参照。  
- **トラブルシューティング**: 障害時はBroker/Bridge → Bus → Relay → Scribe → Slackの順で切り分け。AIに「代替ルートを提案せよ」と指示。  

**競合調整プロセス（二段構え）**  
- **段1: 圧縮器（各AI）**：自身の案をJSONで要約（purpose:1文<100字, steps:箇条書き<5×50字, risks/dependencies:最大3×50字, verification:1段落<150字, total_length:300-400字）。  
- **段2: 仲裁器（NotebookLM等）**：圧縮JSON配列を入力とし、differences_table（側面比較配列）, adopted/rejected_items（AI名・項目・理由配列）, synthesized_proposal(<500字), evaluation_weights（speed_weight/quality_weight/other_weight, 数式: (speed_priority?0.7:0.3)*speed_score + (quality_priority?0.7:0.3)*quality_score + 0.2*(creativity+confidence)/2）を生成。速度/品質フラグで重みを動的調整。  

**運用ショートカット**（AI連携強化）  
- **mdput（クリップボード→安全上書き）**: `python3 ~/daegis/ops/bin/mdput_clip.py "Daegis Guidelines.md" clean fromclip`  
- **Ledger追記**: NotebookLM出力から自動生成（プロンプト: "決定事項をLedger形式に整形せよ"）。  
- **バックアップ**: 自動生成（`*.bak.YYYYMMDD_HHMMSS.md`）。  

### 更新メモ
v1.1（20251003）：v1.0を基に、円卓型アプローチをセクション1に統合（コーディネーター選出アルゴリズム追加）。競合調整をセクション2に二段構えプロセスとして追加。メトリクスループをセクション3で拡張（KPI詳細化）。既存構造を維持しつつ、進化性を強化。今後はGuidelines＝動的指針、Map＝基盤ルールとして運用。

## 3) メトリクス駆動のフィードバックループ（週次学習ループ）
生産性を定量的に検証し、ガイドラインの有効性を継続改善します。1週間「ガイドラインオフ」実験から開始し、結果を基に調整。週次でEMA（指数移動平均、α=0.3）による学習ループを回します。

**ループ手順**（48時間ごと、週次集約）:  
1. **測定**: LedgerにKPIを記録（欠損:線形補間/全体平均80%、外れ値:IQR法でメジアン補完）。  
2. **分析**: NotebookLM で集約データレビュー（プロンプト: "メトリクスから改善点を3点抽出せよ"）。  
3. **調整**: 低生産性領域を特定し、役割シフトやプロンプト修正を実施。Slack permalinkで共有。ドリフト検知（|new_EMA - previous_EMA| > 0.1）で役割確率自動再配分（delta = new_EMA - previous_EMA, new_prob_i = old_prob_i + delta × 0.1 × (i+1)/n, 正規化）。  
4. **実験モード**: 初回1週間はガイドライン参照を任意にし、比較測定。閾値: 完了率80%以上で本運用移行。  

**KPI（週次集約）**  
- **lead_time (min)**: タスク完了時間平均。Slack/Ledgerから抽出、NotebookLM要約。  
- **rework_count**: 再作業回数平均。調整ログカウント。  
- **user_rating (1-5)**: 満足度平均。Slackポーリング集約。  
- **conflict_rounds**: 調整ラウンド数。仲裁器出力記録。  
- **handoff_count**: ハンドオフ回数。リレー履歴カウント。  
composite_score = Σ (normalized_score_k × weight_k)（weight: lead_time/rework:0.2, user_rating:0.3, conflict/handoff:0.15）。EMA: new_EMA = 0.3 × composite + 0.7 × previous_EMA。  

## 4) System Integration & Vision
**Slack集約設計**（中期強化）:  
- 現行: 全AI出力を#daegisaidraftsに集約 → NotebookLM監査。  
- 中期: Zapierで自動化（コーディネーター選出/競合調整統合、有料化前提）。  

**将来の拡張**:  
- **Proactive Engine**: AI特性を活用した予兆検知（Gemini主導、ドリフト検知連動）。  
- **Zappie構想**: 動的役割を基にした完全ハンドオフ実現（知識グラフ蓄積で進化）。
