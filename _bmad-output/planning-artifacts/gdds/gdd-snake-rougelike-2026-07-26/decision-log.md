# Decision Log — Leaf Me Alone GDD

**Workspace:** `gdd-snake-rougelike-2026-07-26`  
**Created:** 2026-07-26  
**Mode:** Create (Express)

---

## Version History

| Version | Date | Change |
|---------|------|--------|
| 0.1 | 2026-07-26 | Finalized after discipline pass |

---

## Decisions

### D-001 — Game title
**Decision:** **Leaf Me Alone** (pun: Leave Me Alone + Leaf)  
**Source:** Brainstorming session 2026-07-26  
**Status:** Captured in gdd.md

### D-002 — Primary game type
**Decision:** **Tower Defense** (primary) with **Roguelike** run/meta layer  
**Rationale:** Combat core is wave-based pause-phase TD; roguelike covers procedural maps, card picks, and Carbon Credit meta.  
**Status:** Captured in gdd.md frontmatter and genre sections

### D-003 — Engine and platform
**Decision:** Godot, PC, mouse placement  
**Source:** Brainstorming  
**Status:** Captured in Technical Specifications

### D-004 — Run structure
**Decision:** 5 waves × 5–10 min; card pick every 2–3 waves; random Director boss wave 5  
**Status:** Captured in gdd.md

### D-005 — Win/loss conditions
**Decision:** Win = 5 waves + boss; Lose = Forest Core dies OR all 3 Root Nests lost  
**Status:** Captured in gdd.md

### D-006 — Dual economy
**Decision:** In-run Dogecoin (planting + care); meta Carbon Credit (Carbon Shop unlocks)  
**Source:** Brainstorming EN doc (care costs Dogecoin)  
**Status:** Captured in gdd.md

### D-007 — Plant roster scope
**Decision:** 16 species (12 core by soil + 4 wildcards); 4 soil types × 3 plants with Attack/Defense/Buff/Debuff roles  
**Status:** Captured in gdd.md

### D-008 — Ape role roster
**Decision:** 9 corporate ape roles (agent proposal from brainstorm — pending designer sign-off)  
**Status:** Captured with [NOTE FOR DESIGNER] in gdd.md

### D-009 — Deadly Sins scope
**Decision:** In-run only, not meta; Red Soil clan fully specified; Sand/Rock/Mold clans deferred  
**Status:** Captured in gdd.md

### D-010 — Vertical slice scope
**Decision:** Full loop in 1 tropical biome — Cashew/Teak/Peanut, HR/PR apes, flee + dissatisfaction + cards + Dogecoin  
**Status:** Captured in Out of Scope / epics.md

### D-011 — Explicit cuts for v1.0
**Decision:** No in-run shop, no difficulty modifiers, no complex pre-run loadout, no starting buffs, skins deferred  
**Status:** Captured in Out of Scope

### D-013 — Finalization
**Decision:** GDD v0.1 finalized after discipline pass autofixes (wave script, card timing, balance bands, assumptions index)  
**Status:** Complete

---

## Open Items (Deferred)

| ID | Item | Blocker? |
|----|------|----------|
| O-001 | Ape role table final approval (nam) | No — proposed roster in GDD |
| O-002 | Balance numbers: plant prices, coin drops, HP, mood thresholds | No — placeholders tagged [ASSUMPTION] |
| O-003 | Card risk definitions (Q12b) | No — needs playtest |
| O-004 | 7 Deadly Sins for Sand, Rock, Mold clans | No — post-Red-clan playtest |
| O-005 | Plant art style (chibi match apes?) | No |
| O-006 | 3 Director boss identities and unique mechanics | No — mission types A/B/C defined |
| O-007 | Mutation paths Combat/Root/Seed detail | No |
| O-008 | Mold weather ally vs debuff rules | No |
| O-009 | Green Ape ally trigger frequency | No |
