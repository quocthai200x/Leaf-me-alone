# Story 1.5: Main Menu and Run Start Flow

Status: done

## Tasks / Subtasks

- [x] Task 1: Main Menu scene (PLAY + QUIT only)
- [x] Task 2: Loading overlay with biome + quip
- [x] Task 3: RunRoot refactored for menu-driven start
- [x] Task 4: Godot boot verified — Main Menu loads clean

## Dev Agent Record

### Completion Notes

- Main scene: `main_menu.tscn`
- PLAY → loading overlay → `RunManager.start_run(randi())` → RunRoot → wave 1
- Dogecoin reset via `init_from_seed()` (verified in main_menu.gd)
- Godot `--quit-after 1` passes with no errors

### File List

- leaf-me-alone/scenes/main/main_menu.gd
- leaf-me-alone/scenes/main/main_menu.tscn
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/project.godot

## Change Log

- 2026-07-26: Story 1.5 implemented (Epic 1 loop tick)
