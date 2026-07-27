---
baseline_commit: 9dd42eecfef6b6b4e00a7626a68d853dd8b110f8
---

# Story 4.1: ApePool and PathfindingService

Status: done

<!-- Ultimate context engine analysis completed - comprehensive developer guide created -->

## Story

As a developer,
I want pooled apes with AStarGrid2D pathfinding,
so that combat scales to 30 apes without per-frame allocation spikes.

## Acceptance Criteria

1. **Given** CombatPhase active **When** apes spawn **Then** ApePool acquires from pool of 35 — no mid-wave `instantiate()` (FR28 foundation)
2. **Given** an active ape **When** pathfinding runs **Then** goal priority is Forest Core → nearest Root Nest → highest-value extract tile (FR28)
3. **Given** a grid cell changes (flee/depleted tile) **When** `PLANT_FLED` fires **Then** PathfindingService updates that cell incrementally in AStarGrid2D (not full grid rebuild)
4. **Given** 30 active apes **When** peak combat scenario runs **Then** profiling baseline targets 60 FPS (NFR1) — verify no per-frame allocations in hot path

## Tasks / Subtasks

- [x] Task 1: Generic object pool utility (AC: #1)
  - [x] Create `scripts/utils/object_pool.gd` — pre-warm, acquire, release, active count
  - [x] Add `GameConstants.APE_POOL_SIZE := 35`
- [x] Task 2: ApeBase entity with FSM (AC: #1, #2)
  - [x] Create `scripts/entities/ape_base.gd` — states `SPAWN → PATH → ACT → DEAD`
  - [x] Create greybox `scenes/entities/ape_base.tscn` (ColorRect or simple sprite placeholder)
  - [x] Grid position tracking, path following via `_process`, speed from `ApeRoleDef` × spawn payload `move_speed_multiplier`
- [x] Task 3: ApePool system (AC: #1)
  - [x] Create `scripts/systems/ape_pool.gd` — pre-warm 35 apes at run start
  - [x] Listen to `EventBus.run_event` for `APE_SPAWNED` → acquire, configure role, assign path goal
  - [x] `release(ape)` on death/despawn; never `instantiate()` during CombatPhase
  - [x] Add `ApePool` node to `run_root.tscn` (sibling of WaveSpawner)
  - [x] Add `Entities` Node2D container under RunRoot for active ape visuals
- [x] Task 4: PathfindingService — full AStarGrid2D (AC: #2, #3)
  - [x] Replace blocked-cell dict stub with `AStarGrid2D` synced from `GridData.movement_cost`
  - [x] `initialize_from_grid(grid: GridData)` on run start / grid ready
  - [x] `find_path(from: Vector2i, to: Vector2i) -> PackedVector2Array` (renamed from `get_path` — conflicts with `Node.get_path()`)
  - [x] `update_cell(cell: Vector2i)` — incremental weight update (depleted = impassable / cost 99)
  - [x] `select_goal(from: Vector2i) -> Vector2i` — goal priority with Epic 5 stubs
  - [x] Keep `is_cell_blocked()` for backward compat with `flee_sequence_test.gd`
  - [x] On `PLANT_FLED`, call `update_cell` only; ApePool owns reroute on same event
- [x] Task 5: Epic 5 goal stubs (AC: #2)
  - [x] Add placeholder goal cells in PathfindingService: center-bottom Forest Core stub `(width/2, height-1)`, three Root Nest stubs at fixed offsets
  - [x] Extract-tile fallback: highest `movement_cost`-inverse occupied plant cell, else center grid
  - [x] Document stubs clearly — Epic 5 replaces with real Structure nodes
- [x] Task 6: Integration wiring (AC: #1, #2, #3)
  - [x] Wire PathfindingService init when RunManager provides grid_data (run start / CombatPhase entry)
  - [x] ApePool reroutes all PATH-state apes on `PLANT_FLED` (not on flee_started)
  - [x] Render apes in MapView coordinate space (use existing grid-to-world helpers from GridRenderer)
- [x] Task 7: Tests (AC: #1, #2, #3, #4)
  - [x] `test/ape_pool_test.gd` — acquire/release, pool size cap, no instantiate mid-wave
  - [x] `test/pathfinding_service_test.gd` — A* path exists, incremental cell block after flee, goal selection order
  - [x] Update `test/flee_sequence_test.gd` if API changes (keep backward compat)
  - [x] Run full GdUnit4 suite — zero regressions

## Dev Notes

### Developer Context — Critical Guardrails

**Extend, do NOT replace:** `pathfinding_service.gd` exists as Story 3.5 stub. Extend it with AStarGrid2D while preserving `update_cell()`, `is_cell_blocked()`, `clear_blocked_cells()` signatures used by flee tests.

**Event contract (WaveSpawner → ApePool):** `APE_SPAWNED` payload keys: `wave`, `ape_id`, `index`, `total`, `spawn_cell`, `move_speed_multiplier`. ApePool must consume this — WaveSpawner stays unchanged.

**Reroute timing:** Architecture mandates reroute on `PLANT_FLED`, NOT `flee_started`. Flee sequence sets depleted tile first, then emits event.

**Structures are Epic 5:** Forest Core / Root Nests do not exist yet. Use configurable stub goal positions derived from grid dimensions. Do NOT implement structure HP or damage in this story.

**Out of scope:** Saw extraction (4.3), HR modifier application (4.4), PR billboards (4.5), Dogecoin drops (4.6), wave scripts 2–5 / burst timing (4.2), combat HUD structure HP (4.7).

### Architecture Compliance

[Source: `_bmad-output/game-architecture.md` § Ape Pooling & Pathfinding]

| Requirement | Implementation |
|-------------|----------------|
| Pool size 35 | `GameConstants.APE_POOL_SIZE` |
| No mid-wave instantiate | Object pool acquire/release only |
| AStarGrid2D | Synced from `GridData.movement_cost` |
| Incremental updates | Single cell on flee, not full rebuild |
| Goal priority | Forest Core > Root Nest > extract tile |
| Ape FSM | `SPAWN → PATH → ACT → DEAD` |
| ApePool location | RunRoot child node |

### File Structure Requirements

**NEW files:**
- `leaf-me-alone/scripts/utils/object_pool.gd`
- `leaf-me-alone/scripts/entities/ape_base.gd`
- `leaf-me-alone/scripts/systems/ape_pool.gd`
- `leaf-me-alone/scenes/entities/ape_base.tscn`
- `leaf-me-alone/test/ape_pool_test.gd`
- `leaf-me-alone/test/pathfinding_service_test.gd`

**UPDATE files:**
- `leaf-me-alone/scripts/systems/pathfinding_service.gd` — AStarGrid2D implementation
- `leaf-me-alone/scripts/utils/constants.gd` — `APE_POOL_SIZE`
- `leaf-me-alone/scenes/run/run_root.tscn` — ApePool + Entities nodes
- `leaf-me-alone/scenes/run/run_root.gd` — init pathfinding on combat if needed

### Technical Requirements

**AStarGrid2D setup (Godot 4.x):**
```gdscript
var _astar := AStarGrid2D.new()
_astar.region = Rect2i(0, 0, grid.width, grid.height)
_astar.cell_size = Vector2(1, 1)
_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
# Set per-cell weight from GridData; depleted/blocked = solid
_astar.update()
```

**Movement cost mapping:** Use `GridData` cell `movement_cost` directly. ROCK = 99.0 (impassable). Depleted tiles → solid or cost 99. `concrete_overlay` exists in schema but no mutators yet — ignore for now.

**Ape movement:** Move toward next path waypoint each frame. When waypoint reached, advance index. On goal reached → transition to ACT state (idle at goal — extraction behavior is Story 4.3).

**Peanut slow:** Already computed in WaveSpawner payload as `move_speed_multiplier`. Apply in ApeBase speed calc.

### Testing Requirements

- Follow GdUnit4 patterns from `test/flee_sequence_test.gd`, `test/run_flow_test.gd`
- `before_test()`: `RunManager.enter_main_menu()`, `ContentRegistry.load_all()`
- Use golden fixture `test/fixtures/run_seed_001.json` for deterministic grid in pathfinding tests
- Integration: spawn ape via `APE_SPAWNED` event → verify ape node active in pool → flee plant → verify path recalculated

### Previous Story Intelligence (Epic 3.7)

- EventBus + group patterns established; systems join groups (`pathfinding_service`, `plant_ability_system`)
- Flee pipeline complete: DissatisfactionSystem → FleeSequenceSystem → `set_depleted_after_flee` → `PLANT_FLED`
- Pathfinding stub test in `flee_sequence_test.gd` must keep passing
- Audio/combat polish in separate systems — do not couple ApePool to audio

### Git Intelligence

Recent commits follow story-per-commit pattern: `Story X.Y: <description>.`
Files co-locate with scenes; systems in `scripts/systems/`; tests in `test/`.

### Project Context Rules

- Godot 4.x APIs only; signals + EventBus over direct cross-system refs
- Pool apes — no per-frame allocations in combat hot path
- Load ape data via ContentRegistry, not hardcoded stats
- Balance numbers in constants/data, not magic numbers in scripts
- Plain-text `.tscn` only

### References

- [Source: `_bmad-output/planning-artifacts/epics.md` — Story 4.1]
- [Source: `_bmad-output/game-architecture.md` — Ape Pooling & Pathfinding, Flee Sequence]
- [Source: `_bmad-output/project-context.md` — Performance Rules, Code Organization]
- [Source: `leaf-me-alone/scripts/systems/pathfinding_service.gd` — existing stub]
- [Source: `leaf-me-alone/scripts/systems/wave_spawner.gd` — APE_SPAWNED contract]

## Dev Agent Record

### Agent Model Used

Claude (Cursor Agent)

### Debug Log References

- Renamed `PathfindingService.get_path()` → `find_path()` because `Node.get_path()` signature conflict caused compile errors.
- AStarGrid2D requires `update()` before per-cell `set_point_solid` / `set_point_weight_scale` calls.

### Completion Notes List

- Implemented generic `ObjectPool` with pre-warm, acquire/release, and active/available counts.
- Added `ApeBase` FSM (SPAWN→PATH→ACT→DEAD) with grid path following and peanut slow via `move_speed_multiplier`.
- Added `ApePool` listening to `APE_SPAWNED`, pre-warming 35 apes, rerouting on `PLANT_FLED`.
- Extended `PathfindingService` with full AStarGrid2D, incremental `update_cell`, Epic 5 goal stubs, and `select_goal` priority chain.
- Wired pathfinding init in `run_root.gd`; added `ApePool` node and `Entities` container under `MapView`.
- Added 8 new GdUnit4 tests; full suite passes (71 tests, 0 failures).

### File List

- leaf-me-alone/scripts/utils/object_pool.gd (new)
- leaf-me-alone/scripts/entities/ape_base.gd (new)
- leaf-me-alone/scenes/entities/ape_base.tscn (new)
- leaf-me-alone/scripts/systems/ape_pool.gd (new)
- leaf-me-alone/scripts/systems/pathfinding_service.gd (modified)
- leaf-me-alone/scripts/utils/constants.gd (modified)
- leaf-me-alone/scenes/run/run_root.tscn (modified)
- leaf-me-alone/scenes/run/run_root.gd (modified)
- leaf-me-alone/scenes/run/map_view.tscn (modified)
- leaf-me-alone/test/ape_pool_test.gd (new)
- leaf-me-alone/test/pathfinding_service_test.gd (new)

## Change Log

- 2026-07-27: Story created with comprehensive dev context for Epic 4.1
- 2026-07-27: Implemented ApePool, ApeBase, ObjectPool, AStarGrid2D PathfindingService, integration wiring, and tests (Story 4.1)
