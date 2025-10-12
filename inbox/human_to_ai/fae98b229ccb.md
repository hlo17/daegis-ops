Luna autopilot に関する外部レビューの要点（要約）:
- 提案: high=探索 / low=整頓 は維持。weight を [full:+2,wax:+1,wan:-1,new:-2]
- 安全域: canary=PASS & e5xx=0 & hold<=0.10 未満では mode=conserve を強制
- 逸脱時: p95>2500 または hold>0.20 で cooldown=30m, mode=recover

この方針で v0 を適用してよければ、payloadに {weight,mode} を追加して配信して下さい。
