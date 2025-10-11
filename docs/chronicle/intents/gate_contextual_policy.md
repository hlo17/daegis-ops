# Gate=Contextual (VI→VII bridge, agreed)
- open_half: canary==PASS && e5xx==0 && hold_rate<=0.10 3連続
- open_full: 上記 5連続
- close_on_fail: 1失敗で閉 + cooldown=30m
- window: 5min 窓の連続性
