---
baseline_commit: 3b44322
---

# Story 3.4: Flee Sequence Pattern (Tier 0 USP)

Status: done

## Tasks / Subtasks

- [x] `FleeSequenceSystem` async 😤→🏃 animation on grid
- [x] Whoosh SFX hook on SFX bus (loads `assets/audio/flee_whoosh.wav` when present)
- [x] `active_flee_count` + wave-end gating while flees active
- [x] Plant removed from combat; `PLANT_FLED` with `FleeEventData`
- [x] 53/53 tests pass

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/flee_sequence_system.gd
- leaf-me-alone/scripts/data/flee_event_data.gd
- leaf-me-alone/scripts/data/grid_data.gd
- leaf-me-alone/scripts/systems/grid_renderer.gd
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scenes/run/map_view.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/test/flee_sequence_test.gd

## Status

done
