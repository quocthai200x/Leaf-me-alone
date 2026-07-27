# Story 4.3: Saw Ape Worker Behavior

Status: done

## Story

As a player,
I want Saw Apes to extract and destroy tiles and structures,
so that worker apes threaten my island infrastructure.

## Acceptance Criteria

1. **Given** Saw Ape in ACT state at goal **When** extraction tick fires **Then** plant HP reduced or tile marked depleted (FR29)
2. **Given** Cashew plant at extract target **When** saw extracts **Then** reflect damage applied to ape via existing `resolve_plant_hit`
3. **Given** Saw Ape dies **When** HP reaches 0 **Then** Ð5 awarded via EconomySystem (FR32)
4. **Given** tile depleted by extraction **When** complete **Then** pathfinding incremental update via `PLANT_FLED` event

## Tasks / Subtasks

- [x] Task 1: Extraction constants + grid helper (AC: #1)
- [x] Task 2: SawExtractionLogic + SawApeSystem (AC: #1, #2, #4)
- [x] Task 3: ApeBase take_damage + ApePool.kill_ape (AC: #3)
- [x] Task 4: EconomySystem APE_KILLED handler for saw drop (AC: #3)
- [x] Task 5: Tests in test/saw_ape_test.gd (AC: #1–#3)
- [x] Task 6: Full GdUnit4 suite passes

## Dev Notes

- Structure HP deferred to Epic 5 — skip structure stub goals for damage
- HR/PR behavior is stories 4.4/4.5
- Full Dogecoin UI polish is story 4.6 — only earn API here
- Reuse `PlantAbilitySystem.resolve_plant_hit` for cashew/teak

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/saw_extraction_logic.gd (new)
- leaf-me-alone/scripts/systems/saw_ape_system.gd (new)
- leaf-me-alone/scripts/data/grid_data.gd (set_depleted_after_extraction)
- leaf-me-alone/scripts/entities/ape_base.gd (take_damage, _request_death)
- leaf-me-alone/scripts/systems/ape_pool.gd (kill_ape)
- leaf-me-alone/scripts/systems/economy_system.gd (APE_KILLED handler)
- leaf-me-alone/scripts/utils/constants.gd (SAW_EXTRACT_*, APE_DOGECOIN_DROPS)
- leaf-me-alone/scenes/run/run_root.tscn (SawApeSystem node)
- leaf-me-alone/test/saw_ape_test.gd (new)
