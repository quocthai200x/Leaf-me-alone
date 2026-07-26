# Story 1.5: Main Menu and Run Start Flow

Status: done

## Acceptance Criteria

1. Main Menu (`main_menu.tscn`) → PLAY loads RunRoot and begins wave 1 — **done**
2. Epic 1 menu: PLAY + QUIT only — **done**
3. Loading overlay: biome + quip "Generating island… HR not included." — **done**
4. Dogecoin resets to 0 at run start — **done**

## Tasks / Subtasks

- [x] Task 1: Create Main Menu scene and script (AC: #1, #2)
- [x] Task 2: Run loading overlay and PLAY flow (AC: #1, #3)
- [x] Task 3: Refactor RunRoot for menu-driven start (AC: #1, #4)
- [x] Task 4: QUIT and boot verification (AC: #2)

## Dev Agent Record

### Completion Notes

- Added `main_menu.tscn` + `main_menu.gd` with PLAY/QUIT, loading overlay, ContentRegistry gate
- Added `RunManager.enter_main_menu()` for forced state recovery on menu load
- Refactored `run_root.gd` to use `RunManager.grid_data`; wave 1 via `begin_combat_wave()`
- Code review fixes: content gate before start_run, dogecoin abort, combat failure returns to menu
- Godot 4.7.1 headless boot verified

### File List

- leaf-me-alone/scenes/main/main_menu.tscn
- leaf-me-alone/scenes/main/main_menu.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/project.godot

## Change Log

- 2026-07-26: Story created (Epic 1 automated loop)
- 2026-07-26: Implemented + code review fixes applied

## Senior Developer Review (AI)

**Outcome:** Approve (after fixes)

**Action Items:** All resolved — ContentRegistry gate, enter_main_menu(), dogecoin abort, combat failure menu return
