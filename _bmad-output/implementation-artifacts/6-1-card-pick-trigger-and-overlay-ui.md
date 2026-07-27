---
baseline_commit: 56874c23a42734d78ea4e4100d26926a018209a3
---

# Story 6.1: Card Pick Trigger and Overlay UI

Status: review

<!-- Ultimate context engine analysis completed - comprehensive developer guide created -->

## Story

As a player,
I want a card pick overlay after waves 2 and 4,
So that roguelike variance shapes my run build.

## Acceptance Criteria

1. **Given** wave 2 or wave 4 clears **When** CardPickPhase begins **Then** overlay blocks map input until selection (FR39, FR71, UX-DR6)
2. **And** three panel-card columns displayed (max 320px each)
3. **And** instant click-to-commit — no undo (UX-DR6)
4. **And** UI feedback within 100ms (NFR6)

## Tasks / Subtasks

- [x] Task 1: CardPick overlay scene shell (AC: #1, #2)
  - [x] Create `scenes/run/card_pick_overlay.tscn` + `card_pick_overlay.gd` — full-screen scrim, centered heading, three card columns max 320px
  - [x] Panel-card styling: top accent stripe (stat=blue `#74B9FF`, soil=purple `#A29BFE` per UX-DR14)
  - [x] Hover expands effect summary on card panel
- [x] Task 2: Stub card options for UI-only slice (AC: #2, #3)
  - [x] Create `scripts/systems/card_pick_stub_data.gd` — deterministic 3-option pool from run seed + wave (no CardEffectApplier yet — Story 6.2)
  - [x] Click card → emit `RunEvent.CARD_PICKED` with `{card_id, card_type, wave_index}` → `RunManager.complete_card_pick()`
- [x] Task 3: RunRoot phase wiring (AC: #1, UX-DR34)
  - [x] Replace `_complete_card_pick_stub()` auto-skip with overlay show/hide
  - [x] CardPickPhase: hide Pause/Combat HUD; show overlay; stop WaveSpawner; combat frozen
  - [x] Add CardPickOverlay instance to `run_root.tscn` above map layers
- [x] Task 4: Input blocking (AC: #1)
  - [x] Overlay scrim `mouse_filter = STOP` blocks map clicks
  - [x] InputRouter: block pan/edit during CardPickPhase (not just PausePhase)
- [x] Task 5: Tests (AC: #1–#4)
  - [x] `test/card_pick_overlay_test.gd` — wave 2 timer expiry → CardPickPhase; card select → PausePhase + CARD_PICKED emitted
  - [x] InputRouter ignores UI intents during CardPickPhase
  - [x] Full GdUnit4 suite passes (130/130)

## Dev Notes

(See create-story analysis — unchanged.)

## Dev Agent Record

### Agent Model Used

Claude (Cursor Agent)

### Debug Log References

- Card pick overlay must be scene-instantiated in tests (`%CardsRow` unique names require `.tscn`).
- Wave 2 card pick tests require PausePhase between `begin_combat_wave()` calls.

### Completion Notes List

- Added full-screen CardPick overlay with scrim, three panel-cards (320px max), accent stripes, hover detail.
- Stub card pool via `CardPickStubData` (2 stat + 1 soil, seed-shuffled).
- Replaced RunRoot auto-skip stub with overlay show on CardPickPhase; emits CARD_PICKED on commit.
- InputRouter blocks map pan/edit during CardPickPhase.
- 4 new overlay tests + 1 input router test; full suite green.

### File List

- leaf-me-alone/scenes/run/card_pick_overlay.tscn (new)
- leaf-me-alone/scenes/run/card_pick_overlay.gd (new)
- leaf-me-alone/scripts/systems/card_pick_stub_data.gd (new)
- leaf-me-alone/scenes/run/run_root.tscn (modified)
- leaf-me-alone/scenes/run/run_root.gd (modified)
- leaf-me-alone/scripts/input/input_router.gd (modified)
- leaf-me-alone/test/card_pick_overlay_test.gd (new)
- leaf-me-alone/test/input_router_fsm_test.gd (modified)
- _bmad-output/implementation-artifacts/6-1-card-pick-trigger-and-overlay-ui.md (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Action Items:**

- [x] [Low] Scene-based overlay tests must instantiate `.tscn` not script-only node — fixed in test file.

**Notes:** PausePhase still auto-advances to next combat via existing `_handle_pause_entry` deferred start; full CardPick→Pause loop timing is Story 6.4 scope (pre-existing stub behavior preserved).

## Change Log

- 2026-07-27: Story created with comprehensive dev context for Epic 6.1
- 2026-07-27: Implemented card pick overlay UI, stub data, RunRoot wiring, tests (Story 6.1)
- 2026-07-27: Code review approved
