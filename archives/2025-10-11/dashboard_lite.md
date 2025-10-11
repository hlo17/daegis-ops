## Dashboard Lite — 2025-10-10T06:57:20Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T06:30:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T06:30:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T06:30:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T06:30:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T06:30:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T06:55:45Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T06:55:45Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T06:55:45Z", "intent": "other", "proposed_ms": 3300.0, "sla_after": 3300.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T06:55:45Z", "intent": "plan", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T06:55:45Z", "intent": "publish", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T06:55:45Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T06:55:45Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T06:55:45Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T06:55:45Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T06:55:45Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760077801.2928348, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760077801.2928348, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760077801.2928348, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760077801.2928348, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760077801.2928348, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760077801.440061, "window_sec": 1800, "canary_intents": [], "n": 5104, "hold_rate": 0.2241, "e5xx": 88, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760078401.881363, "window_sec": 1800, "canary_intents": [], "n": 5220, "hold_rate": 0.2241, "e5xx": 90, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760079001.424803, "window_sec": 1800, "canary_intents": [], "n": 5336, "hold_rate": 0.2241, "e5xx": 92, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=(unset)
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:28:11Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:00:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:00:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:00:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:00:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:00:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:28:10Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:28:10Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:28:10Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:28:10Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:28:10Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:28:10Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:28:10Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:28:10Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:28:10Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:28:10Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760079601.666802, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760079601.666802, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760079601.666802, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760079601.666802, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760079601.666802, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760079601.8020298, "window_sec": 1800, "canary_intents": [], "n": 5684, "hold_rate": 0.2241, "e5xx": 98, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760080201.2254539, "window_sec": 1800, "canary_intents": [], "n": 5800, "hold_rate": 0.2241, "e5xx": 100, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760080801.8551428, "window_sec": 1800, "canary_intents": [], "n": 5916, "hold_rate": 0.2241, "e5xx": 102, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=(unset)
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:32:13Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:12Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:12Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:12Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:12Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:12Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:13Z", "intent": "plan", "proposed_ms": 2635.24, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:13Z", "intent": "analyze", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:13Z", "intent": "publish", "proposed_ms": 2636.43, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:13Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:13Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760080801.8551428, "window_sec": 1800, "canary_intents": [], "n": 5916, "hold_rate": 0.2241, "e5xx": 102, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760081402.2162127, "window_sec": 1800, "canary_intents": [], "n": 6032, "hold_rate": 0.2241, "e5xx": 104, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760081531.6702735, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:33:40Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760080801.8551428, "window_sec": 1800, "canary_intents": [], "n": 5916, "hold_rate": 0.2241, "e5xx": 102, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760081402.2162127, "window_sec": 1800, "canary_intents": [], "n": 6032, "hold_rate": 0.2241, "e5xx": 104, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760081531.6702735, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=(unset)
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:34:35Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760081402.2162127, "window_sec": 1800, "canary_intents": [], "n": 6032, "hold_rate": 0.2241, "e5xx": 104, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760081531.6702735, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760081675.2795038, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:36:03Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760081675.2795038, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760081762.8783183, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760081763.0925705, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:40:22Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:32:52Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760082021.5657701, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082021.781432, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082021.9932177, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:46:26Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:45:02Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:45:02Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:45:02Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:45:02Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:45:02Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:45:02Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:45:02Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:45:02Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:45:02Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:45:02Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760082021.5657701, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082021.781432, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082021.9932177, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:51:30Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760082601.354039, "window_sec": 1800, "canary_intents": [], "n": 6496, "hold_rate": 0.2241, "e5xx": 112, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760082689.6127841, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082689.8739908, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T07:56:33Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T07:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T07:47:09Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T07:47:09Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760081402.0520904, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760082689.6127841, "window_sec": 300, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082689.8739908, "window_sec": 900, "verdict": "INSUFFICIENT", "reason": "NO_DATA", "canary_intents": ["plan", "publish"]}
  {"event": "canary_verdict", "ts": 1760082964.3349936, "window_sec": 300, "canary_intents": [], "n": 6496, "hold_rate": 0.2241, "e5xx": 112, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T08:08:54Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:00:01Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:00:01Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:00:01Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:00:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:00:01Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T08:00:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:00:01Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:00:01Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:00:01Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:00:01Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760082964.3349936, "window_sec": 300, "canary_intents": [], "n": 6496, "hold_rate": 0.2241, "e5xx": 112, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760083201.749158, "window_sec": 1800, "canary_intents": [], "n": 6612, "hold_rate": 0.2241, "e5xx": 114, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760083710.8894796, "window_sec": 300, "canary_intents": [], "n": 6612, "hold_rate": 0.2241, "e5xx": 114, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T08:24:54Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:00:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:15:01Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:15:01Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:15:01Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:15:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:15:01Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T08:15:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:15:01Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:15:01Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:15:01Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:15:01Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760083201.5769715, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760083801.1756253, "window_sec": 1800, "canary_intents": [], "n": 6728, "hold_rate": 0.2241, "e5xx": 116, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760084401.881403, "window_sec": 1800, "canary_intents": [], "n": 6844, "hold_rate": 0.2241, "e5xx": 118, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760084659.874819, "window_sec": 300, "canary_intents": [], "n": 6844, "hold_rate": 0.2241, "e5xx": 118, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T08:31:30Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:30:02Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:30:02Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:30:02Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:30:02Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T08:30:02Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:30:02Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:30:02Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:30:02Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:30:02Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T08:30:02Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan", "t_run": "2025-10-10T08:30:02Z", "intent": "chat_answer", "proposed_ms": 885.44, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:30:02Z", "intent": "gate", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:30:02Z", "intent": "other", "proposed_ms": 3300.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:30:02Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T08:30:02Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760085002.209758, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760085002.209758, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760085002.209758, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760085002.209758, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760085002.209758, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760084659.874819, "window_sec": 300, "canary_intents": [], "n": 6844, "hold_rate": 0.2241, "e5xx": 118, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760085002.3442717, "window_sec": 1800, "canary_intents": [], "n": 6960, "hold_rate": 0.2241, "e5xx": 120, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760085065.288748, "window_sec": 300, "canary_intents": [], "n": 6963, "hold_rate": 0.224, "e5xx": 123, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-10T11:07:34Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-10T11:00:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T11:00:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T11:00:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T11:00:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-10T11:00:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T11:00:01Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T11:00:01Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T11:00:01Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T11:00:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-10T11:00:01Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan_skip", "intent": "publish", "proposed_ms": 2636.43, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-10T11:00:01Z"}
  {"event": "apply_plan_skip", "intent": "chat_answer", "proposed_ms": 885.44, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-10T11:00:01Z"}
  {"event": "apply_plan_skip", "intent": "gate", "proposed_ms": 2850.0, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-10T11:00:01Z"}
  {"event": "apply_plan", "t_run": "2025-10-10T11:00:01Z", "intent": "plan", "proposed_ms": 2850.0, "source": "L10"}
  {"event": "apply_plan", "t_run": "2025-10-10T11:00:01Z", "intent": "publish", "proposed_ms": 2850.0, "source": "L10"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760094001.383547, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760094001.383547, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760094001.383547, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760094001.383547, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760094001.383547, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760093402.1557014, "window_sec": 1800, "canary_intents": [], "n": 8584, "hold_rate": 0.2241, "e5xx": 148, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760094001.602245, "window_sec": 1800, "canary_intents": [], "n": 8700, "hold_rate": 0.2241, "e5xx": 150, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760094418.3870466, "window_sec": 300, "canary_intents": [], "n": 8703, "hold_rate": 0.2241, "e5xx": 153, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=plan,publish
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
## Dashboard Lite — 2025-10-11T04:36:33Z

- decisions: 234, holds: 34

### SimBrain proposals (tail 5)
  {"event": "simbrain_proposal", "t_run": "2025-10-11T04:30:01Z", "intent": "chat_answer", "hold_rate": 0.2407, "sla_before": 804.94, "sla_after_proposed": 885.44, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-11T04:30:01Z", "intent": "gate", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-11T04:30:01Z", "intent": "other", "hold_rate": 0.4211, "sla_before": 3000.0, "sla_after_proposed": 3300.0, "action": "WIDEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-11T04:30:01Z", "intent": "plan", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
  {"event": "simbrain_proposal", "t_run": "2025-10-11T04:30:01Z", "intent": "publish", "hold_rate": 0.0, "sla_before": 3000.0, "sla_after_proposed": 2850.0, "action": "TIGHTEN", "dry_run": true}
- policy dry-run wins: 55/324

### Shadow apply (tail 5)
  {"event": "policy_shadow_apply", "ts": 1760047220.508838, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event":"policy_shadow_apply","ts":1760047235.5085783,"intent":"chat_answer","sla_before":800.0,"sla_after":720.0,"gate_stats":{"win_rate":0.1367,"wins":41,"total":300,"hold_rate":0.3333,"holds":26,"seen":78},"gate_thresholds":{"win_rate_th":0.5,"min_samples":1,"max_hold_rate":1.0}}
  {"event": "policy_shadow_apply", "ts": 1760047235.5091338, "intent": "other", "sla_before": 0.0, "sla_after": 0.0, "forced": true, "assist": "mw_tail"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}
  {"event": "policy_shadow_apply", "ts": 1760048688.1196268, "intent": "chat_answer", "sla_before": 800, "sla_after": 720, "forced": false, "assist": "manual_patch"}

### Canary (tail 3)
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"publish","pct":5,"proposed_ms":1132}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":3000}
  {"event":"canary_start","t":"2025-10-10T01:12:14Z","intent":"plan","pct":5,"proposed_ms":2500}

### Revokes (tail 3)
  {"event":"canary_revoke","t":"2025-10-09T23:50:22Z"}
  {"event":"canary_revoke","t":"2025-10-09T23:52:35Z"}
  {"event":"canary_revoke","t":"2025-10-10T01:12:14Z"}

### Auto-Tune (dry candidates · tail 5)
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-11T04:30:01Z", "intent": "plan", "proposed_ms": 2635.24, "sla_after": 2635.24, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-11T04:30:01Z", "intent": "analyze", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-11T04:30:01Z", "intent": "publish", "proposed_ms": 2636.43, "sla_after": 2636.43, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-11T04:30:01Z", "intent": "chat_answer", "proposed_ms": 885.44, "sla_after": 885.44, "confidence_tag": "low", "source": "simbrain_v2"}
  {"event": "auto_tune_dry", "candidate": true, "t_run": "2025-10-11T04:30:01Z", "intent": "gate", "proposed_ms": 2850.0, "sla_after": 2850.0, "confidence_tag": "low", "source": "simbrain_v2"}

### Apply Plan (tail 5)
  {"event": "apply_plan_skip", "intent": "plan", "proposed_ms": 2635.24, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-11T04:30:02Z"}
  {"event": "apply_plan_skip", "intent": "analyze", "proposed_ms": 2850.0, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-11T04:30:02Z"}
  {"event": "apply_plan_skip", "intent": "publish", "proposed_ms": 2636.43, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-11T04:30:02Z"}
  {"event": "apply_plan_skip", "intent": "chat_answer", "proposed_ms": 885.44, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-11T04:30:02Z"}
  {"event": "apply_plan_skip", "intent": "gate", "proposed_ms": 2850.0, "confidence_tag": "low", "reason": "CONFIDENCE_BELOW_MIN", "min_tag": "mid", "t_run": "2025-10-11T04:30:02Z"}

### Bandit shadow (tail 5)
  {"event": "bandit_shadow", "ts": 1760157001.278466, "intent": "chat_answer", "A_delta": 0.95, "A_win_rate": 0.9907, "A_n": 108, "B_delta": 1.05, "B_win_rate": 0.9907, "B_n": 108}
  {"event": "bandit_shadow", "ts": 1760157001.278466, "intent": "gate", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 4, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 4}
  {"event": "bandit_shadow", "ts": 1760157001.278466, "intent": "other", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 19, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 19}
  {"event": "bandit_shadow", "ts": 1760157001.278466, "intent": "plan", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}
  {"event": "bandit_shadow", "ts": 1760157001.278466, "intent": "publish", "A_delta": 0.95, "A_win_rate": 1.0, "A_n": 51, "B_delta": 1.05, "B_win_rate": 1.0, "B_n": 51}

### Sentinel / Alerts
- VETO: absent
- alerts (tail 5):
  [2025-10-09T20:23:35Z] HOLD x0 (>=0)

### Prometheus targets
- activeTargets: 1

### Canary verdict (tail 3)
  {"event": "canary_verdict", "ts": 1760156467.8955944, "window_sec": 1800, "canary_intents": [], "n": 20764, "hold_rate": 0.2241, "e5xx": 358, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760157001.6252964, "window_sec": 1800, "canary_intents": [], "n": 20880, "hold_rate": 0.2241, "e5xx": 360, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}
  {"event": "canary_verdict", "ts": 1760157393.6885347, "window_sec": 300, "canary_intents": [], "n": 20996, "hold_rate": 0.2241, "e5xx": 362, "p95_ms": 3005.72, "verdict": "FAIL", "reason": "HOLD_RATE>0.2;HTTP_5XX>0"}

### Auto-adopt gate
- AUTO_TUNE_ALLOW_INTENTS=(unset)
- cooldown: none

_Appended by scripts/dev/dashboard_lite.sh_
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=402 window=300s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=412 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=414 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=414 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=416 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=420 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=423 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=423 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=423 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=423 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=429 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=429 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=432 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=434 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=434 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=438 window=1800s
### KPI (fixed)
  verdict=FAIL p95_ms=3005.72 hold_rate=0.2241 e5xx=438 window=1800s
