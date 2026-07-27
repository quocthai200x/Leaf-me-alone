---
baseline_commit: 31304b8198b125db976a15d193a556dd0732025
---

# Story 6.4: CardPickPhase State Integration

Status: review

## Story

As a developer,
I want CardPick to insert correctly between Combat and Pause,
So that the run loop never skips or double-triggers picks.

## Acceptance Criteria

1. CombatPhase → CardPickPhase → PausePhase (never Combat without new wave)
2. CardPickPhase only after waves 2 and 4
3. run_flow_test extended or card-specific integration test passes

## Tasks / Subtasks

- [x] Block Combat→Pause on waves 2/4 (must go through CardPick)
- [x] Block CardPick→Combat direct transition
- [x] RunManager.get_previous_state() + complete_card_pick guard
- [x] test/card_pick_flow_test.gd — full waves 1–4 loop

## Dev Agent Record

### File List

- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/test/card_pick_flow_test.gd (new)

## Senior Developer Review (AI)

**Review Outcome:** Approve

## Change Log

- 2026-07-28: Story created and implemented
