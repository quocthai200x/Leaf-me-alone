---
baseline_commit: 1b39d67
---

# Story 3.3: Flee Threshold and HR Modifier Hook

Status: done

## Tasks / Subtasks

- [x] `DissatisfactionThreshold` pure threshold math (100/75/50)
- [x] HR modifier hook via `register_hr_modifier()`
- [x] `trigger_flee()` emits `FLEE_TRIGGERED` + `active_flee_count`
- [x] Peanut marked `dissatisfaction_sensitive`
- [x] Threshold tests in `dissatisfaction_test.gd` — 51/51 pass

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/dissatisfaction_threshold.gd
- leaf-me-alone/scripts/systems/dissatisfaction_system.gd
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/data/species/peanut.json
- leaf-me-alone/data/fallback/species.json
- leaf-me-alone/test/dissatisfaction_test.gd

## Status

done
