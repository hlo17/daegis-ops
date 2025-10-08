---
# Daegis Self Progress Dashboard v1 - Obsidian Note Template
# Usage: Copy this template to your daily note, fill the frontmatter fields
# Import to spreadsheet: Copy the Weekly Rollup formulas for analysis
date: YYYY-MM-DD
focus: ""
minutes: 0
edits_added: 0
edits_deleted: 0
tests_pass: 0
tests_fail: 0
cache_hit_ratio: 0.0
notes: ""
---

# Daily Progress - {{date}}

## Focus
{{focus}}

## Work Summary
- **Time spent**: {{minutes}} minutes
- **Code changes**: +{{edits_added}} / -{{edits_deleted}} lines
- **Tests**: {{tests_pass}} pass / {{tests_fail}} fail
- **Cache performance**: {{cache_hit_ratio}}% hit ratio

## Notes
{{notes}}

---

## Weekly Rollup (Copy formulas to spreadsheet)

### Time & Effort
- Total minutes: `=SUM(C2:C8)` (assuming minutes in column C)
- Avg daily minutes: `=AVERAGE(C2:C8)`
- Total edits: `=SUM(D2:D8)+SUM(E2:E8)` (added + deleted)

### Quality Metrics  
- Test success rate: `=SUM(F2:F8)/(SUM(F2:F8)+SUM(G2:G8))*100` (pass/(pass+fail)*100)
- Avg cache hit ratio: `=AVERAGE(H2:H8)`

### Productivity Score
- Edits per minute: `=SUM(D2:D8)/SUM(C2:C8)` (added lines / total minutes)
- Tests per session: `=(SUM(F2:F8)+SUM(G2:G8))/COUNT(C2:C8)` (total tests / days worked)

**Spreadsheet columns**: A=Date, B=Focus, C=Minutes, D=EditsAdded, E=EditsDeleted, F=TestsPass, G=TestsFail, H=CacheHitRatio, I=Notes