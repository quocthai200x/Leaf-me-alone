---
baseline_commit: b5e89325d79f3f18bbd483ff37f1f598de0ad37d
---

# Story 5.1: Forest Core and Root Nest Placement

Status: done

<!-- Ultimate context engine analysis completed - comprehensive developer guide created -->

## Story

As a player,
I want Forest Core and three Root Nests on each generated map,
So that I have clear objectives to defend.

## Acceptance Criteria

1. **Given** map generated at run start **When** structures placed per procedural rules **Then** one Forest Core and three Root Nests exist on grid (FR45)
2. **And** Root Nests enable between-wave restoration hook (FR50) — stub API only; no restoration math yet
3. **And** structure HP visible in combat HUD (Story 4.7 dependency — wire real cells, do not reimplement HUD)

## Tasks / Subtasks

- [x] Task 1: Structure data model on GridData (AC: #1)
  - [x] Add `structures: Array` to GridData with entries `{id, type, cell, current_hp, max_hp, restoration_enabled}`
  - [x] Set cell `structure_ref` index on occupied structure tiles; block plant placement on structure cells
  - [x] Add `get_structures()`, `get_structure_at(cell)`, `get_forest_core_cell()`, `get_root_nest_cells()`
- [x] Task 2: Procedural placement logic (AC: #1)
  - [x] Create `scripts/systems/structure_placement_logic.gd` — seed-deterministic placement on RED walkable tiles
  - [x] Forest Core: anchor near island center (prefer lower-center RED tile cluster — replaces PathfindingService hardcoded stub)
  - [x] Three Root Nests: fixed semantic offsets from core, snap to nearest valid RED tile per seed
  - [x] Call from `RunManager.start_run()` after `generate_from_seed()`
- [x] Task 3: Structure entity greybox scenes (AC: #1)
  - [x] Create `scenes/entities/structures/forest_core.tscn` + `root_nest.tscn` (ColorRect placeholders)
  - [x] Create `scripts/entities/structure_base.gd` — cell tracking, group `"structures"`
  - [x] Spawn under `MapView/Entities` on run start
- [x] Task 4: Wire PathfindingService + StructureHpSystem to real positions (AC: #1, #3)
  - [x] Replace stub internals — read from GridData structures (keep method names for compat)
  - [x] StructureHpSystem bootstrap from GridData structures instead of pathfinding stubs
  - [x] Structure cells remain walkable for ape path goals
- [x] Task 5: Between-wave restoration hook stub (AC: #2)
  - [x] Add `StructureHpSystem.can_apply_between_wave_restoration() -> bool`
  - [x] Add no-op `apply_between_wave_restoration_stub()` callable from PausePhase entry
  - [x] Emit `RunEvent.STRUCTURES_PLACED` with structure summary payload
- [x] Task 6: RunRoot integration + map refresh (AC: #1, #3)
  - [x] spawn_structures in map_view; run_root calls on load
  - [x] Pathfinding init after structures placed
- [x] Task 7: Tests (AC: #1, #2, #3)
  - [x] `test/structure_placement_test.gd` — deterministic seed, RED soil, unique cells
  - [x] Updated pathfinding + combat_hud tests for placement
  - [x] Full GdUnit4 suite passes

## Dev Notes

(See original story for full dev context — unchanged.)

## Dev Agent Record

### Agent Model Used

Claude (Cursor Agent)

### Debug Log References

- Updated `run_seed_001.json` layout hash after structure cells mark `occupied=true`.
- StructureHpSystem restoration hook test requires `RunManager.start_run()` so grid bootstrap succeeds.

### Completion Notes List

- Added seed-deterministic structure placement via `StructurePlacementLogic` on RED walkable tiles.
- Extended `GridData` with structures array, structure_ref cell indexing, and plant placement guards.
- Wired `RunManager.start_run()` to place structures and emit `STRUCTURES_PLACED`.
- Replaced PathfindingService goal stubs with GridData-backed positions (legacy fallback retained).
- StructureHpSystem now bootstraps from RunManager.grid_data with restoration hook stubs.
- Greybox Forest Core / Root Nest scenes spawn in MapView Entities container.
- Added 7 structure placement tests; full suite green.

### File List

- leaf-me-alone/scripts/data/structure_type.gd (new)
- leaf-me-alone/scripts/systems/structure_placement_logic.gd (new)
- leaf-me-alone/scripts/entities/structure_base.gd (new)
- leaf-me-alone/scenes/entities/structures/forest_core.tscn (new)
- leaf-me-alone/scenes/entities/structures/root_nest.tscn (new)
- leaf-me-alone/test/structure_placement_test.gd (new)
- leaf-me-alone/scripts/data/grid_data.gd (modified)
- leaf-me-alone/autoload/run_manager.gd (modified)
- leaf-me-alone/scripts/data/run_event.gd (modified)
- leaf-me-alone/scripts/systems/pathfinding_service.gd (modified)
- leaf-me-alone/scripts/systems/structure_hp_system.gd (modified)
- leaf-me-alone/scenes/run/map_view.gd (modified)
- leaf-me-alone/scenes/run/run_root.gd (modified)
- leaf-me-alone/test/pathfinding_service_test.gd (modified)
- leaf-me-alone/test/combat_hud_test.gd (modified)
- leaf-me-alone/test/fixtures/run_seed_001.json (modified)
- _bmad-output/implementation-artifacts/5-1-forest-core-and-root-nest-placement.md (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)

## Senior Developer Review (AI)

**Review Outcome:** Approve (after minor fix)

**Findings addressed:**
- Removed unused `StructureTypeRes` import from `pathfinding_service.gd`.

## Change Log

- 2026-07-27: Story created with comprehensive dev context for Epic 5.1
- 2026-07-27: Implemented Forest Core + Root Nest placement, tests, integration (Story 5.1)
