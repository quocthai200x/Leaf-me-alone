---
baseline_commit: 8cde4a91f7d5f8bd4605e0092a7ffbfd81d7b98a
---

# Story 2.3: InteractionMode FSM — Place and Care Modes

Status: review

## Story

As a player,
I want to select a plant species and enter placement or care mode,
So that mouse input routes correctly during Pause Phase.

## Acceptance Criteria

1. **Given** PausePhase active **When** player selects species **Then** InputRouter enters PLACE_PLANT mode
2. **When** player selects care action **Then** InputRouter enters CARE mode
3. **And** right-click cancels placement mode (UX-DR19)
4. **And** PLACE_PLANT/CARE locked during CombatPhase
5. **And** UI emits intent via EventBus; no game logic in Control scripts

## Tasks / Subtasks

- [x] Task 1: UI_INTENT event + InputRouter FSM (AC: #1–4)
- [x] Task 2: Pause panel intent emission (AC: #5)
- [x] Task 3: Tests — 13/13 pass

## Dev Agent Record

### Completion Notes

- UI_INTENT event; InputRouter FSM with species selection, care mode, right-click cancel, combat reset
- Pause panel emits intents only; tutorial TUTORIAL_ACTION preserved

### File List

- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/scripts/input/input_router.gd
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/test/input_router_fsm_test.gd
- _bmad-output/implementation-artifacts/2-3-interactionmode-fsm-place-and-care-modes.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Senior Developer Review (AI)

**Review Outcome:** Approve — all ACs met.

### Action Items

- [x] All ACs satisfied
