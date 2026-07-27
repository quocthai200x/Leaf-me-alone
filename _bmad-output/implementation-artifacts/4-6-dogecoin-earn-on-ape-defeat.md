# Story 4.6: Dogecoin Earn on Ape Defeat

Status: done

## Acceptance Criteria

1. Role-weighted Dogecoin on ape defeat during CombatPhase
2. +Ð float animation on kill in combat HUD
3. Combat HUD Dogecoin chip top-right updates
4. Wallet never negative — integration test in dogecoin_test.gd

## Tasks / Subtasks

- [x] Task 1: Combat-phase guard on APE_KILLED earn (AC: #1)
- [x] Task 2: Dogecoin chip + refresh on DOGECOIN_CHANGED (AC: #3)
- [x] Task 3: +Ð float popup on positive delta in combat (AC: #2)
- [x] Task 4: test/dogecoin_test.gd integration tests (AC: #4)
- [x] Task 5: Full GdUnit4 suite passes

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/dogecoin_float_logic.gd (new)
- leaf-me-alone/scripts/systems/economy_system.gd (combat-phase APE_KILLED guard)
- leaf-me-alone/scenes/run/combat_hud.gd (Dogecoin chip + float)
- leaf-me-alone/scenes/run/combat_hud.tscn (DogecoinChip panel)
- leaf-me-alone/test/dogecoin_test.gd (new)
