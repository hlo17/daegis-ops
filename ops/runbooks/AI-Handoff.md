# AI-Handoff — Start here
1) `source tools/hotkeys.sh ; hk help`
2) 便利資産は `.githooks/`, `tools/`, `ops/runbooks/`

### First Aid
端末が落ちる/起動しない場合は、`~/.bashrc` の冒頭3行（未定義ガード＋非対話 return）を確認。  
配達は `tools/deliver-*.sh` を“素の bash”で実行できるため、hk に依存せず復旧可能。
