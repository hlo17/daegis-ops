# Map（恒久原則）

- 原則：Adaptive Hybrid Pool（ローカル優先・難問のみ外部、最終は Oracle verdict）
- 役割：
  - Halu：初期方針3行（RAG根拠）
  - Oracle：評価ゲート（✅/⚠️/❌）と合意形成
  - Slash/FastAPI：標準の外部入口
- 統一フォーマット：
  - 生成出力：{policy, risks, next, sources[], confidence}
  - 評価保存：{id, agent, label, reason, ts, user}
  - verdict：{id, agent:"oracle", mode:"eval", verdict, reasons[], ts}
