---
baseline_commit: c7c339ed1a02e29a74a92fe88433895794c21953
---

# Story 2.1: Godot Theme Foundation and Economy Data

Status: review

## Story

As a player,
I want UI styled with Leaf Me Alone design tokens and economy values loaded from data,
So that the game looks cohesive and balance is tunable without code changes.

## Acceptance Criteria

1. **Given** DESIGN.md tokens defined **When** theme loads **Then** `themes/leaf_me_alone_theme.tres` maps primary color tokens and typography roles (UX-DR1, UX-DR2)
2. **And** `data/economy.json` defines water Ð5, fertilize Ð10, species placement costs (Peanut 20, Cashew 35, Teak 50)
3. **And** ContentRegistry exposes economy and species defs at runtime
4. **And** project-wide theme applied via `project.godot` `[gui] theme/custom`
5. **And** existing run flow test still passes (no regression)

## Tasks / Subtasks

- [x] Task 1: Create Godot Theme resource (AC: #1, #4)
  - [x] Create `themes/leaf_me_alone_theme.tres` with DESIGN.md color tokens (primary, surface, surface-panel, text, muted, border, dogecoin, danger, etc.)
  - [x] Map typography semantic roles via theme type variations: `Label/display`, `Label/heading`, `Label/body`, `Label/label`, `Label/numeric`, `Label/meme`
  - [x] Style `Button/primary` and `Button/secondary` per DESIGN.md component tokens
  - [x] Style `PanelContainer/pause_panel` with surface-panel bg, thick border, hard shadow (UX-DR24 foundation)
  - [x] Set `[gui] theme/custom` in `project.godot`
- [x] Task 2: Economy data + EconomyDef (AC: #2)
  - [x] Create `scripts/data/economy_def.gd` — water_cost, fertilize_cost, species_costs Dictionary
  - [x] Create `data/economy.json` with care costs and species placement costs
  - [x] Create `data/fallback/economy.json` (embedded minimum for boot failure path)
- [x] Task 3: Extend ContentRegistry (AC: #3)
  - [x] Load economy JSON in `load_all()` alongside species/apes
  - [x] Add `get_economy() -> EconomyDef` accessor (duplicate(true) read-only copy)
  - [x] Validate species_costs keys match loaded species ids; warn on mismatch with species `plant_cost`
  - [x] Boot fails loudly if economy JSON missing from primary and fallback
- [x] Task 4: Tests and verification (AC: #5)
  - [x] Add `test/content_registry_economy_test.gd` — economy costs, species access, theme resource loads
  - [x] Run full GdUnit4 suite; all tests pass (4/4)

## Dev Notes

(See original story context — architecture, schema, and references preserved in git history.)

## Dev Agent Record

### Agent Model Used

Composer

### Debug Log References

- EconomyDef class required Godot `--import` scan before autoload could resolve `class_name` type hints
- GdUnit4 headless requires `--ignoreHeadlessMode` flag

### Completion Notes List

- Created `leaf_me_alone_theme.tres` with primary/secondary buttons, panel styles, Label typography variations, global theme in project.godot
- Added economy JSON pipeline with EconomyDef resource and ContentRegistry.get_economy()
- 3 new unit tests + run_flow regression — all passing

### File List

- leaf-me-alone/themes/leaf_me_alone_theme.tres
- leaf-me-alone/data/economy.json
- leaf-me-alone/data/fallback/economy.json
- leaf-me-alone/scripts/data/economy_def.gd
- leaf-me-alone/autoload/content_registry.gd
- leaf-me-alone/project.godot
- leaf-me-alone/test/content_registry_economy_test.gd

### Change Log

- 2026-07-26: Story 2.1 implementation — theme foundation + economy data pipeline

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Review Date:** 2026-07-26

**Summary:** Implementation matches ACs. Theme maps DESIGN.md primary tokens and typography roles; economy JSON loads with fallback; ContentRegistry exposes get_economy(); tests cover costs, species alignment, theme load, and run flow regression.

### Action Items

- [x] All ACs satisfied — no blocking issues found

**Notes (non-blocking):**
- Soil/card accent color tokens deferred to later UI stories (AC only requires primary + typography foundation)
- Scene-level hardcoded colors in Epic 1 greybox remain; global theme applies to new/un-overridden controls
