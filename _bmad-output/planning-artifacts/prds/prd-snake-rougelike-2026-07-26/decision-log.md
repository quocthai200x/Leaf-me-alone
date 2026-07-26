# Decision Log — PRD: Leaf Me Alone (snake-rougelike)

## Session 2026-07-26

| ID | Decision | Status | Notes |
|----|----------|--------|-------|
| D-001 | PRD workspace created | Recorded | Path: `_bmad-output/planning-artifacts/prds/prd-snake-rougelike-2026-07-26/` |
| D-002 | Primary input: GDD v0.1 | Recorded | Builds on GDD; does not relitigate design decisions |
| D-003 | Secondary input: brainstorming session 2026-07-26 | Recorded | EN + VI versions |
| D-004 | Working mode: Express | Recorded | Full draft from GDD + brainstorm; user reviews |
| D-005 | PRD audience | Assumed | Solo/small-team builder → Godot implementation; tagged in §0 |
| D-006 | Persona Alex | Assumed | Marked `[ILLUSTRATIVE]` — not research-grounded |
| D-007 | MVP scope | From GDD | Vertical slice E1–E7 + E6/E8 minimal; aligns GDD D-010/D-011 |
| D-008 | Monetization | Open | Tagged `[ASSUMPTION]` + O-010; no GDD decision |
| D-009 | Full PRD draft v0.1 | Superseded | Express draft; superseded by v1.0 finalize |
| D-010 | Finalize: input reconciliation | Recorded | Gaps closed — tagline, tutorial FRs, wave script, species biology, GDD metrics |
| D-011 | Finalize: discipline pass | Recorded | Autofixed FR renumber (77 FRs), glossary, assumptions index, capability reframing |
| D-012 | HR Unemployment rule | Recorded | Adopt GDD: zero dissatisfaction events while HR present (O-011 resolved) |
| D-013 | Red-clan Sins scope | Recorded | Stat/soil cards only in MVP; Sin cards post-slice per addendum reconciliation |
| D-014 | PRD v1.0 finalized | Recorded | 2026-07-26 — ready for architecture / epics alignment |

## Decision Log Audit (Finalize)

| Entry | Captured in | Notes |
|-------|-------------|-------|
| D-001–D-008 | prd.md §0, §13 | Audience, mode, scope assumptions |
| D-010 reconciliation gaps | prd.md §1, §4, §6, §11; addendum.md | Wave table, balance params, achievement voice |
| D-011 validation fixes | prd.md §3–4.13, §13 | Tutorial FR-76/77, glossary, FR continuity |
| D-012 O-011 | prd.md §12 | GDD rule adopted |
| D-013 Sin scope | prd.md FR-43, addendum | Aligned with GDD D-009 + Out of Scope |
| O-010 monetization | prd.md §8, §12 | Deferred — not phase-blocking for slice |
| O-005 plant art | prd.md §6, §12 | Deferred — not phase-blocking for slice |

## Open Items (Deferred Post-Finalize)

| ID | Item | Owner | Notes |
|----|------|-------|-------|
| O-PRD-002 | Monetization model | nam | Before store submission |
| O-PRD-003 | Plant art style | nam | GDD O-005 |
| O-002 | Balance numbers | nam | First playtest — table in addendum.md |

## Version History

| Version | Date | Change |
|---------|------|--------|
| 0.1 | 2026-07-26 | Express draft (69 FRs) |
| 1.0 | 2026-07-26 | Finalized — 77 FRs, addendum, reconciliation + validation pass |
