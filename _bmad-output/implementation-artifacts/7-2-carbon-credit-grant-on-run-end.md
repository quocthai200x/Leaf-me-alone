---
baseline_commit: 688e7b4
---

# Story 7.2: Carbon Credit Grant on Run End

Status: done

## Story

As a player,
I want Carbon Credit awarded based on run outcome,
So that wins feel more rewarding than losses.

## Acceptance Criteria

1. Win grants 100–150 CC; loss grants min(20 + waves_cleared × 15, 80) (FR55)
2. Replaces CC preview-only display — grant via SaveManager on RunEnd
3. CC earned animation on RunEnd (UX-DR16)
4. CC chip uses CC label + carbon-credit color #6BCBAA (UX-DR9)

## Tasks / Subtasks

- [x] Task 1: Grant CC in RunManager on run end (AC: #1, #2)
- [x] Task 2: Update RunEnd overlay (AC: #2, #3, #4)
- [x] Task 3: Tests (AC: #1)
- [x] Task 4: Full regression suite (154 tests pass)

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Action Items:** None blocking

## Dev Agent Record

### Completion Notes List

- CC granted once in `declare_run_win`/`declare_run_loss` via SaveManager
- Overlay shows animated "CC +N" with carbon-credit color
- Win: 125 CC; loss: min(20 + waves×15, 80)

### File List

- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/scripts/data/run_state.gd
- leaf-me-alone/scripts/systems/run_end_logic.gd
- leaf-me-alone/scenes/run/run_end_overlay.gd
- leaf-me-alone/themes/leaf_me_alone_theme.tres
- leaf-me-alone/test/run_end_test.gd
- _bmad-output/implementation-artifacts/7-2-carbon-credit-grant-on-run-end.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
