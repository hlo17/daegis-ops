# Daegis Map — 2030 Plan & Quick Wins

*Last updated: 2025-09-29*

## Vision (2030)

**Human-in-the-loop decision factory.** People declare goals & constraints; the factory plans, fans out, synthesizes, self‑grades, and proposes decisions; humans approve/reject with minimal friction. Luna orchestrates tempo (phase/tide) system‑wide.

---

## Current Stack (baseline)

- **Ingress (“玄関”)**: Cloudflare Tunnel → Mosquitto (MQTT 1883 / WS 9001)
- **Auth/ACL**: mosquitto\_passwd; ACL: `ui` readwrite `daegis/#`, `luna` write `daegis/+/state` & `daegis/chat/+`, factories write in their own namespace
- **State dial**: `daegis/luna/state` → phase/tide
- **UI**: Command Room (static HTML on :8081 via systemd), uses MQTT over WSS via CF
- **Research worker**: Gemini-backed PoC, I/O over MQTT

---

## Unique Concepts → Implementation Hooks

- **CRISPR = “問題の編集”** → `planner:rewrite` step before every DAG; metric: success/cost delta pre/post
- **mRNA = 実行設計図の注入** → `daegis/mRNA/<cell>/<step>` distributes small JSON playbooks; metric: reuse & variance
- **TSP蒸発（オンライン化/並列化）** → Command Room fan‑out templates; metric: wall‑clock vs CPU time ratio

---

## Quick Wins (now)

1. **Luna×Dial enforcement**
   - Subscribe `daegis/luna/state` in all workcells
   - Map phase/tide → `{model,temp,concurrency,qa_threshold}`
2. **Approve/Reject via MQTT (UI不要)**
   - Control topic: `daegis/factory/research/control`
   - Payloads: `{task_id, action: approve|reject, reason?}`
   - On approve: re‑emit `research/out` with `approved:true`
3. **Auto‑QA rubric** (JSON)
   - Example weights: accuracy 40 / sources 30 / clarity 20 / consistency 10 ⇒ pass ≥80
   - On fail: bounded retry
4. **mRNA logging**
   - Publish latest mRNA to `/mRNA/...` and render in UI list (read‑only)

---

## Next Iteration (small PoCs)

- **Standard DAGs ×3** (5–7 nodes each)
  - Research / Build(code) / Content(doc)
  - `plan → reframe? → fanout → synth → autoqa → summarize → publish`
- **Cache/KV**
  - `/cache/search`, `/cache/summary`, `/cache/mrna`; metric: hit‑rate, cost↓
- **“最後の一押し” UI**
  - Card: 3 bullets + suggested action; Approve/Reject buttons (bridge to MQTT control)

---

## Longer‑term R&D

- **Policy optimization (learning Luna)**: Feedback control from KPIs → phase/tide
- **mRNA distillation**: cluster successful plans → reusable templates
- **Auto‑compliance**: PII/policy checks as part of Auto‑QA; hash‑chain audit

---

## MQTT Topic Schema (initial)

- **Luna**: `daegis/luna/state` (retained)
- **Factory (Research)**
  - In:  `daegis/factory/research/tasks/<id>`
  - Out: `daegis/factory/research/out`
  - Ctrl: `daegis/factory/research/control`
  - Status: `daegis/status/research`
- **UI**: `daegis/ui/agenda`, `daegis/chat/#`, `daegis/poll/...`, `daegis/tasks/#`
- **mRNA**: `daegis/mRNA/<cell>/<step>`
- **Cache**: `daegis/cache/<bucket>/<key>` (optional)

**QoS / Retain (guideline)**

- Tasks/Out: QoS1, retain=false
- Control: QoS1, retain=false (操作は履歴に残さない)
- Status: QoS0–1, retain=false
- State (Luna): QoS0/1, retain=true

**ACL (starter)**

```
user ui     ; readwrite daegis/#
user luna   ; write daegis/+/state
             write daegis/chat/+
user factory_research ; write daegis/factory/research/out
                        read  daegis/factory/research/tasks/#
                        read  daegis/factory/research/control
```

---

## Ingress (“玄関”) Hardening Plan

- **Current**: Cloudflare Tunnel → Mosquitto WS (9001)
- **Add Nginx (front of LAN)**
  - Terminate TLS, route by host/path (`/mqtt` to WS), health checks
  - Basic rate limits & IP allowlists for admin paths
  - Forward `X-Client-*` headers for audit
- **Zero Trust**: CF Access in front of Command Room; MQTT WS may remain key‑auth (username/password) or service token

---

## KPIs (1st pass)

- **Speed**: wall‑clock/job −50%
- **Quality**: Auto‑QA ≥80, reject ≤15%
- **Cost**: token/¥ per artifact −30%
- **Human effort**: median read‑to‑approve ≤10s

---

## Roles / RACI (initial)

- **You (Owner)**: rubric design, reframe policy, accept/reject governance
- **Jamie (Factory dev)**: research worker I/O, control handling, Gemini adapter, Auto‑QA
- **Me (Systems)**: MQTT schema, ingress hardening, UI bridge, DAG templates, ops

---

## Immediate Todos (this week)

-

---

## Notes

- Keep everything **idempotent** (task\_id + action keys)
- Prefer **small JSON contracts** over large binaries
- Every human decision emits a **status event** for audit

