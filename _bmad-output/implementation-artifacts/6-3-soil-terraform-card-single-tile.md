---
baseline_commit: a3dafbf7198b125db976a15d193a556dd0732025
---

# Story 6.3: Soil Terraform Card — Single Tile

Status: review

## Story

As a player,
I want soil cards that permanently change one tile's soil type,
So that I can reshape chokepoints for the remainder of the run.

## Acceptance Criteria

1. **Given** soil card selected **When** player targets one tile **Then** GridData soil type changes permanently for run (FR42)
2. **And** single tile only — no region scope
3. **And** TileMapLayer syncs from GridData
4. **And** dissatisfaction recalculates for affected plants
5. **And** soil card accent stripe purple (UX-DR14)

## Tasks / Subtasks

- [x] Task 1: GridData terraform API (AC: #1, #2)
- [x] Task 2: CardEffectApplier soil apply + pending_soil_card_id (AC: #1)
- [x] Task 3: Targeting UX — overlay IGNORE + InputRouter map click (AC: #1, #5)
- [x] Task 4: run_root sync map, pathfinding, diss recalc on soil CARD_PICKED (AC: #3, #4)
- [x] Task 5: test/soil_terraform_test.gd — 139/139 suite green

## Dev Agent Record

### Completion Notes List

- GridData.can_terraform_cell / terraform_cell (blocks structures)
- Soil pick: begin_soil_pick → map click → apply_soil_at_cell → CARD_PICKED with cell
- Overlay enters targeting mode (cards hidden, mouse_filter IGNORE)
- dissatisfaction_system.recalculate_for_terraform reduces mismatch penalty when fixed

### File List

- leaf-me-alone/scripts/data/grid_data.gd
- leaf-me-alone/scripts/data/run_state.gd
- leaf-me-alone/scripts/systems/card_effect_applier.gd
- leaf-me-alone/scripts/systems/dissatisfaction_system.gd
- leaf-me-alone/scenes/run/card_pick_overlay.gd
- leaf-me-alone/scripts/input/input_router.gd
- leaf-me-alone/scenes/run/map_view.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/test/soil_terraform_test.gd (new)
- _bmad-output/implementation-artifacts/6-3-soil-terraform-card-single-tile.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Notes:** soil_terraform_fertile maps to SAND (target_soil 1) — no FERTILE enum in slice.

## Change Log

- 2026-07-28: Story created and implemented
