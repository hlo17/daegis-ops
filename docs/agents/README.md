# How to use (Daegis × AGENTS.md)
1. 設計は `docs/chronicle/plans.md` を編集（AIはまずここを読む）
2. 仕様は `docs/agents/*.md` に追記（Mission/Exec Plan/Tests 必須）
3. テスト: `make ci` または `guardian beacon`
4. レビュー: `tools/ai_review.sh <topic>` を実行 → AIが Introspect 経由で応答
5. 定期健診: `bash scripts/ops/agents_check.sh`（WORMに結果が残る）
