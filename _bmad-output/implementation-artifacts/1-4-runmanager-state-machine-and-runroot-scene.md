# Story 1.4: RunManager State Machine and RunRoot Scene

Status: done

## Acceptance Criteria

1. RunRoot.tscn hosts run lifecycle — **done**
2. Combat timer expires → CombatPhase → PausePhase — **done**
3. `can_transition_to()` blocks invalid transitions — **done**
4. Wave duration hook by wave number (5/6/7/8/10 min; debug seconds) — **done**
5. Exactly five combat phases enforced — **done**
6. `reset()` only from MainMenu/RunEnd — **done**

## Tasks / Subtasks

- [x] Task 1: Full RunManager transition matrix
- [x] Task 2: Wave duration constants + combat timer hook
- [x] Task 3: RunRoot.tscn with GridRenderer + status UI
- [x] Task 4: CardPick stub auto-complete (waves 2 & 4)
- [x] Task 5: Godot boot verified

## Dev Agent Record

### Completion Notes

- Main scene switched to `run_root.tscn`
- Debug wave durations: 3–6 seconds for fast testing
- Godot boot: MainMenu→RunStart→PausePhase→CombatPhase wave 1

### File List

- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/project.godot

## Change Log

- 2026-07-26: Story 1.4 implemented (Epic 1 loop tick)
