# Story 1.6: Greybox Pause Panel and Combat HUD Shells

Status: done

## Tasks / Subtasks

- [x] Task 1: Pause panel shell scene (AC: #1)
- [x] Task 2: Map dim overlay (AC: #2)
- [x] Task 3: Combat HUD shell (AC: #3)
- [x] Task 4: RunRoot phase UI wiring (AC: #1–#3)

## Dev Agent Record

### Completion Notes

- Added `pause_panel.tscn` — right 35% (672px) greybox with Catalog, Care, Weather, Dogecoin placeholders
- Added `combat_hud.tscn` — top-center wave timer (Wave N/5 — M:SS)
- Map dim overlay at 60% opacity on left map area during PausePhase
- RunRoot toggles UI via `_apply_phase_ui()` on STATE_CHANGED
- Godot 4.7.1 headless boot verified

### File List

- leaf-me-alone/scenes/run/pause_panel.tscn
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/scenes/run/combat_hud.tscn
- leaf-me-alone/scenes/run/combat_hud.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/run_root.gd

## Change Log

- 2026-07-26: Story created (Epic 1 loop)
- 2026-07-26: Greybox pause/combat UI shells implemented

## Senior Developer Review (AI)

**Outcome:** Approve — shells meet AC; phase visibility wired correctly
