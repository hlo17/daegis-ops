# Copilot Integration Index

This folder is the **index for AI assistants** (Copilot/Chat).  
**Ground Truth lives elsewhere**; this folder only points to it and explains the update policy.

## Ground Truth (read in this order)
1. docs/01_OVERVIEW_DAEGIS.md
2. docs/02_APIS_AND_TOPICS.md
3. docs/03_METRICS_AND_ALERTS.md
4. docs/04_CONVENTIONS.md

## What to do with these
- Use this index to find canonical docs.  
- When suggestions conflict with these docs, **ask first**.  
- Prefer **minimal, observable, reversible** changes.  
- **Do not introduce new runtime deps/services** without explicit approval.

## Auto-Update Policy
- When any Ground Truth changes, **keep this index in sync** (paths/titles).  
- If you add a new canonical doc, list it here and update `.github/copilot-instructions.md`.

## Pointers
- Router banner & patterns: `router/app.py` (has paste-guard notes)
- Ops runbooks: `ops/runbooks/**`
- Ward (worklog): `ops/ward/Daegis-Ward.md`
