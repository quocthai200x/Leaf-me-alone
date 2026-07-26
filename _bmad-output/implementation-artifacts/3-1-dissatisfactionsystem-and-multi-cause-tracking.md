---
baseline_commit: 74b016193fe9450c842396ff375e3cd789703d71
---

# Story 3.1: DissatisfactionSystem and Multi-Cause Tracking

Status: done

## Story

As a player,
I want dissatisfaction to rise from soil, neighbors, missed care, and weather,
so that plant mood reflects ecosystem stewardship decisions.

## Acceptance Criteria

1. **Given** DissatisfactionSystem active on RunRoot
   **When** plant on incompatible soil
   **Then** dissatisfaction increases (FR7)

2. **When** hostile allelopathic neighbor affects plant
   **Then** dissatisfaction increases (FR8)

3. **When** Pause ends without required care applied
   **Then** dissatisfaction increases +25 per unaddressed cause (FR9)

4. **When** weather mismatches species preference
   **Then** dissatisfaction increases (FR10, FR67)

## Tasks / Subtasks

- [x] Task 1: Pure cause-evaluation logic (AC: #1, #2, #4)
  - [x] Add `DissatisfactionCauseLogic` RefCounted with soil, allelopathy, weather checks
  - [x] Extend `SpeciesDef` + species JSON with `preferred_soil`, `weather_preference`
  - [x] Add dissatisfaction rate constants to `GameConstants`
- [x] Task 2: DissatisfactionSystem node on RunRoot (AC: #1–#4)
  - [x] Create `dissatisfaction_system.gd`; wire to RunRoot scene
  - [x] Track per-plant care during Pause; apply +25/cause on Pause→Combat
  - [x] Apply environmental deltas during Combat on interval (batch, not per-frame)
  - [x] Emit `DISSATISFACTION_UPDATED` for GridRenderer indicator refresh
- [x] Task 3: Run weather stub for cause evaluation (AC: #4)
  - [x] Add `current_weather` to `RunState`; assign at run start from seed
- [x] Task 4: Tests and verification (AC: #1–#4)
  - [x] `test/dissatisfaction_test.gd` — soil, allelopathy, missed care, weather
  - [x] Full GdUnit4 suite passes (43/43); Godot headless boot clean

## Dev Notes

### Architecture Compliance

- `DissatisfactionSystem` is sole owner of dissatisfaction accumulation in Epic 3; flee threshold math deferred to Story 3.3.
- Event-driven updates via EventBus; no direct UI coupling.
- Batch combat ticks — no per-frame allocations in `_process`.

### Cause Rules (MVP slice)

| Cause | Detection | Delta |
|-------|-----------|-------|
| Soil mismatch | `grid.get_soil_type(pos) != species.preferred_soil` | +10 per combat tick |
| Allelopathy | Adjacent peanut neighbor on non-peanut plant | +10 per combat tick |
| Missed care | Plant not watered/fertilized during Pause | +25 per unaddressed cause at Pause→Combat |
| Weather mismatch | `run_state.current_weather != species.weather_preference` | +10 per combat tick |

## Dev Agent Record

### Agent Model Used

Composer

### Completion Notes List

- `DissatisfactionCauseLogic` pure evaluator for all four cause types
- `DissatisfactionSystem` on RunRoot tracks pause care and applies combat-interval environmental deltas
- Cashew `weather_preference: tropical_rain` enables mismatch vs default `tropical_sun` run weather
- 5 new unit tests; full suite 43/43 pass; headless boot verified

### Senior Developer Review (AI)

**Outcome:** Approve  
**Date:** 2026-07-26

No blocking issues. Architecture patterns followed (EventBus, batch ticks, data-driven species prefs).

### File List

- _bmad-output/implementation-artifacts/3-1-dissatisfactionsystem-and-multi-cause-tracking.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- leaf-me-alone/scripts/systems/dissatisfaction_cause_logic.gd
- leaf-me-alone/scripts/systems/dissatisfaction_system.gd
- leaf-me-alone/test/dissatisfaction_test.gd
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scripts/data/species_def.gd
- leaf-me-alone/scripts/data/run_state.gd
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/data/species/peanut.json
- leaf-me-alone/data/species/cashew.json
- leaf-me-alone/data/species/teak.json
- leaf-me-alone/data/fallback/species.json
- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/scenes/run/map_view.gd

## Change Log

- 2026-07-26: Story 3.1 implemented — multi-cause dissatisfaction tracking system

## Status

done
