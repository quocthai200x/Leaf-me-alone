---
baseline_commit: d5d247e2ed46bfdf1e633e433a76883a86b2a666
---

# Story 6.2: Stat Cards via CardEffectApplier

Status: review

<!-- Ultimate context engine analysis completed - comprehensive developer guide created -->

## Story

As a player,
I want stat cards that buff same-clan plants for the rest of the run,
So that I can specialize my Red Soil defenders.

## Acceptance Criteria

1. **Given** CardPickPhase with stat card options **When** player selects one of three stat cards **Then** exactly one card selected per pick; max 2 picks per run (FR40)
2. **And** CardEffectApplier applies +10–20% ATK/DEF/grow speed/diss resist to Red clan only (FR41)
3. **And** stacked buff capped at +40% per stat per run
4. **And** card flip + accent flash on select (UX-DR14, UX-DR28)
5. **And** Sin/risk cards excluded from pool (FR43)
6. **And** effects persist for current run only (FR44)
7. **And** `test/card_stacking_test.gd` validates cap

## Tasks / Subtasks

- [x] Task 1: CardDef + JSON data pipeline (AC: #2, #5, #6)
  - [x] Create `scripts/data/card_def.gd`
  - [x] Create `data/cards/stat_cards.json`
  - [x] Extend `ContentRegistry` — load cards from `data/cards/`
  - [x] Add `MAX_CARD_STACK := 0.40` to constants
- [x] Task 2: RunState stat buff storage (AC: #2, #3, #6)
  - [x] Extend `RunState` with stat_buffs + card_picks_count
  - [x] add_stat_buff / get_stat_buff with cap enforcement
- [x] Task 3: CardEffectApplier + CardSystem (AC: #1, #2, #3, #5)
  - [x] card_effect_applier.gd + card_system.gd
  - [x] Wire overlay + RunRoot to CardSystem/CardEffectApplier
- [x] Task 4: Integrate buffs into combat/dissatisfaction (AC: #2)
  - [x] plant_ability_system run stat buffs for Red clan
  - [x] dissatisfaction_system diss_resist scaling
- [x] Task 5: Card flip + accent flash UX (AC: #4)
- [x] Task 6: Tests (AC: #7)
  - [x] card_stacking_test.gd + overlay test updates
  - [x] Full suite 135/135 green

## Dev Agent Record

### Agent Model Used

Claude (Cursor Agent)

### Completion Notes List

- CardDef + JSON pipeline via ContentRegistry (stat + soil cards).
- RunState tracks stat_buffs with +40% cap; CardEffectApplier sole apply path.
- CardSystem replaces CardPickStubData in RunRoot; overlay flip juice + async commit.
- ATK/DEF buffs in plant_ability_system; diss_resist scales dissatisfaction gains.
- grow_speed_pct stored for future growth system (no growth tick in slice yet).
- Max 2 picks enforced in CardEffectApplier.

### File List

- leaf-me-alone/scripts/data/card_def.gd (new)
- leaf-me-alone/data/cards/stat_cards.json (new)
- leaf-me-alone/data/cards/soil_cards.json (new)
- leaf-me-alone/scripts/systems/card_effect_applier.gd (new)
- leaf-me-alone/scripts/systems/card_system.gd (new)
- leaf-me-alone/scripts/data/run_state.gd (modified)
- leaf-me-alone/scripts/utils/constants.gd (modified)
- leaf-me-alone/autoload/content_registry.gd (modified)
- leaf-me-alone/scripts/systems/plant_ability_system.gd (modified)
- leaf-me-alone/scripts/systems/dissatisfaction_system.gd (modified)
- leaf-me-alone/scenes/run/card_pick_overlay.gd (modified)
- leaf-me-alone/scenes/run/run_root.gd (modified)
- leaf-me-alone/test/card_stacking_test.gd (new)
- leaf-me-alone/test/card_pick_overlay_test.gd (modified)
- _bmad-output/implementation-artifacts/6-2-stat-cards-via-cardeffectapplier.md (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Action Items:**

- [x] [Low] Use `before_test()` not `before()` in card_stacking_test — fixed
- [x] [Low] Enforce max 2 card picks per run in CardEffectApplier — added guard

**Notes:** grow_speed_pct stored but not consumed until a growth tick system exists (acceptable for slice).

## Change Log

- 2026-07-27: Story created
- 2026-07-28: Implemented CardEffectApplier, CardSystem, stat buff stacking, tests
