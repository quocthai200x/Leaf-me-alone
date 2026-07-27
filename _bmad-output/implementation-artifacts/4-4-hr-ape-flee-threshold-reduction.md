# Story 4.4: HR Ape — Flee Threshold Reduction

Status: done

## Story

As a player,
I want HR Apes to lower flee thresholds for nearby plants,
So that corporate HR culture accelerates plant desertion.

## Acceptance Criteria

1. **Given** HR Ape within radius of plants **When** dissatisfaction evaluated **Then** flee threshold reduced to 50 for affected plants (FR16, FR30)
2. **Given** HR Ape dies **When** HP reaches 0 **Then** Ð15 awarded via EconomySystem (FR32)
3. **Given** flee triggered with HR modifier active **When** run phase starts **Then** HR comedic sting plays (max once per 5s during mass flee)

## Tasks / Subtasks

- [x] Task 1: HrApeSystem syncs HR modifiers from active HR apes (AC: #1)
- [x] Task 2: HR Ð15 drop via existing APE_KILLED path (AC: #2)
- [x] Task 3: HR sting synced to flee run phase with cooldown (AC: #3)
- [x] Task 4: Tests in test/hr_ape_test.gd
- [x] Task 5: Full GdUnit4 suite passes

## Dev Notes

- Reuse `DissatisfactionSystem.register_hr_modifier()` hook from Story 3.3
- HR modifier applies while ape is PATH or ACT (presence follows grid cell)
- PR behavior deferred to 4.5; Dogecoin UI polish deferred to 4.6

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/hr_ape_system.gd (new)
- leaf-me-alone/scripts/systems/flee_sequence_system.gd (HR sting at run phase)
- leaf-me-alone/scripts/systems/flee_feedback_logic.gd (sting cooldown helper)
- leaf-me-alone/scripts/utils/constants.gd (HR_STING_COOLDOWN_SEC)
- leaf-me-alone/scenes/run/run_root.tscn (HrApeSystem + HrStingPlayer)
- leaf-me-alone/test/hr_ape_test.gd (new)
