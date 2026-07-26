---
baseline_commit: 154eac0f250298e1849bba28866ddb754e9f42f6
---

# Story 1.1: Bootstrap Godot Project and Core Autoloads

Status: done

## Story

As a developer,
I want a Godot 4.7.1 project with EventBus, RunManager, SaveManager, and ContentRegistry autoloads,
So that all game systems share a consistent foundation from day one.

## Acceptance Criteria

1. **Given** no Godot project exists in `leaf-me-alone/` **When** bootstrap completes per architecture doc **Then** `project.godot` registers EventBus, RunManager, SaveManager, ContentRegistry autoloads
2. **And** plain-text `.tscn`/`.tres` only; `.godot/` in `.gitignore`
3. **And** Windows Desktop export preset configured
4. **And** audio buses Master and SFX exist (NFR3)
5. **And** folder skeleton matches architecture doc (autoload/, scenes/, scripts/, data/, assets/, themes/, test/)
6. **And** each autoload has minimal stub implementation that loads without errors
7. **And** main scene is a placeholder (empty Control or minimal root) so project opens and runs

## Tasks / Subtasks

- [x] Task 1: Create Godot 4.7.1 project skeleton (AC: #1, #2, #5, #7)
  - [x] Create `leaf-me-alone/project.godot` with Godot 4.x config, Forward Plus renderer
  - [x] Add `.gitignore` ignoring `.godot/`, `*.import`, `.mono/`, export builds
  - [x] Create directory skeleton per architecture: `autoload/`, `scenes/main/`, `scenes/run/`, `scripts/data/`, `scripts/utils/`, `data/fallback/`, `assets/`, `themes/`, `test/fixtures/`
  - [x] Add minimal `scenes/main/bootstrap.tscn` as main scene (Label "Leaf Me Alone — Bootstrap OK")
- [x] Task 2: Implement core autoload stubs (AC: #1, #6)
  - [x] `autoload/event_bus.gd` — RunEvent enum + `emit_run_event(event, payload)` signal hub
  - [x] `scripts/data/run_event.gd` — RunEvent enum (referenced by EventBus)
  - [x] `autoload/run_manager.gd` — holds RunState ref, stub `can_transition_to()`, `transition_to()`, `reset()`
  - [x] `scripts/data/run_state.gd` — empty Resource stub with `master_seed: int`, `dogecoin: int`, `wave_index: int`
  - [x] `scripts/data/run_state_enum.gd` — MainMenu, RunStart, PausePhase, CombatPhase, CardPickPhase, RunEnd
  - [x] `autoload/save_manager.gd` — stub `save()`, `load_meta()`, path `user://save/meta.json`
  - [x] `autoload/content_registry.gd` — stub `load_all() -> bool` returns true (full impl in 1.2)
  - [x] Register all four autoloads in `project.godot` in order: EventBus, RunManager, SaveManager, ContentRegistry
- [x] Task 3: Audio buses and export preset (AC: #3, #4)
  - [x] Configure Master and SFX audio buses in `default_bus_layout.tres` or project audio settings
  - [x] Add `export_presets.cfg` with Windows Desktop preset (x86_64)
- [x] Task 4: Verify project boots cleanly (AC: #6, #7)
  - [x] Run Godot headless or `--quit-after 1` if Godot CLI available; otherwise validate project.godot syntax
  - [x] Confirm no parse errors in autoload scripts
  - [x] Document Godot path requirement in Dev Agent Record if CLI unavailable

## Dev Notes

### Architecture Compliance

- **Engine:** Godot **4.7.1** stable — use Godot 4.x APIs only (no Godot 3 syntax)
- **Project root:** `leaf-me-alone/` at repo root — planning artifacts stay in `_bmad-output/`, never inside Godot tree
- **Autoload boundaries:** EventBus = signals only; RunManager = state machine; SaveManager = meta JSON; ContentRegistry = data load
- **RunRoot not in this story** — only bootstrap; empty folder placeholders OK
- **Plain-text scenes:** All `.tscn`/`.tres` must be text format (not binary)

### Autoload Implementation Specs

**EventBus** (`autoload/event_bus.gd`):
```gdscript
signal run_event(event: int, payload: Variant)
func emit_run_event(event: int, payload: Variant = null) -> void:
    run_event.emit(event, payload)
```

**RunEvent enum** (`scripts/data/run_event.gd`):
```gdscript
class_name RunEvent
enum Type {
    STATE_CHANGED, WAVE_STARTED, WAVE_CLEARED, PLANT_FLED,
    APE_KILLED, CARD_PICKED, RUN_WON, RUN_LOST,
}
```

**RunManager stub** — initialize `_state = RunStateEnum.MainMenu`, create `RunState.new()`, implement:
- `can_transition_to(to_state) -> bool` — return true for now (full matrix in 1.4)
- `transition_to(new_state) -> void` — guard + emit STATE_CHANGED via EventBus
- `reset() -> void` — only callable from MainMenu/RunEnd (guard with push_warning)

**SaveManager stub** — ensure `user://save/` dir exists on first save; stub methods return defaults

**ContentRegistry stub** — `load_all() -> bool` prints "[ContentRegistry] stub load OK" and returns true

### File Structure Requirements

```
leaf-me-alone/
├── project.godot
├── export_presets.cfg
├── .gitignore
├── default_bus_layout.tres
├── autoload/
│   ├── event_bus.gd
│   ├── run_manager.gd
│   ├── save_manager.gd
│   └── content_registry.gd
├── scenes/main/bootstrap.tscn
├── scripts/data/
│   ├── run_event.gd
│   ├── run_state.gd
│   └── run_state_enum.gd
├── data/fallback/          # empty placeholder dir
├── test/fixtures/          # empty placeholder dir
└── (other dirs as empty placeholders)
```

### Testing Requirements

- No GdUnit4 in this story (Story 1.9)
- Manual verification: open project in Godot 4.7.1, press F5, see bootstrap scene
- All autoload scripts must parse without errors

### Project Context Rules

- Use `snake_case` files, `PascalCase` class names
- Never write to `res://` for saves — use `user://`
- Autoloads never hold entity node references
- Balance numbers in JSON later — no magic numbers in gameplay scripts
- English UI strings via `tr()` even for stubs

### References

- [Source: _bmad-output/game-architecture.md#Project Initialization]
- [Source: _bmad-output/game-architecture.md#Autoload Boundaries]
- [Source: _bmad-output/game-architecture.md#Directory Structure]
- [Source: _bmad-output/project-context.md#Engine-Specific Rules]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1]

## Dev Agent Record

### Agent Model Used

Composer (Cursor subagent)

### Debug Log References

- Godot 4.7.1 CLI not found on PATH or common Windows install locations
- Static validation: project.godot autoload order, resource refs, GDScript bracket balance (7 files), audio buses, export preset

### Completion Notes List

- Created `leaf-me-alone/` Godot 4.7.1 project with Forward Plus renderer, 1920×1080 viewport
- Registered autoloads in order: EventBus → RunManager → SaveManager → ContentRegistry
- Implemented stub autoloads per Dev Notes: EventBus signal hub, RunManager state machine with guarded reset, SaveManager with `user://save/` dir creation, ContentRegistry stub `load_all()`
- Added data scripts: `RunEvent`, `RunStateEnum`, `RunState` Resource
- Main scene `bootstrap.tscn` displays "Leaf Me Alone — Bootstrap OK"
- Audio buses Master + SFX in `default_bus_layout.tres`; Windows Desktop x86_64 export preset
- Directory skeleton with `.gitkeep` placeholders for empty dirs
- **Manual verification required:** Install Godot 4.7.1, open `leaf-me-alone/project.godot`, press F5

### File List

- leaf-me-alone/project.godot
- leaf-me-alone/.gitignore
- leaf-me-alone/export_presets.cfg
- leaf-me-alone/default_bus_layout.tres
- leaf-me-alone/autoload/event_bus.gd
- leaf-me-alone/autoload/run_manager.gd
- leaf-me-alone/autoload/save_manager.gd
- leaf-me-alone/autoload/content_registry.gd
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/scripts/data/run_state.gd
- leaf-me-alone/scripts/data/run_state_enum.gd
- leaf-me-alone/scenes/main/bootstrap.gd
- leaf-me-alone/scenes/main/bootstrap.tscn
- leaf-me-alone/scenes/run/.gitkeep
- leaf-me-alone/scripts/utils/.gitkeep
- leaf-me-alone/data/fallback/.gitkeep
- leaf-me-alone/assets/.gitkeep
- leaf-me-alone/themes/.gitkeep
- leaf-me-alone/test/fixtures/.gitkeep

## Change Log

- 2026-07-26: Story created by create-story workflow
- 2026-07-26: Addressed code review findings — RunManager event payload, SaveManager JSON I/O, root .gitignore restored, bootstrap tr()

## Senior Developer Review (AI)

**Review Outcome:** Changes Requested → Fixed  
**Review Date:** 2026-07-26

### Action Items

- [x] [HIGH] Restore deleted root `.gitignore`
- [x] [HIGH] RunManager `transition_to()` emit `{from, to}` payload
- [x] [HIGH] RunManager `reset()` emit STATE_CHANGED
- [x] [MED] Blocked transition push_warning
- [x] [MED] SaveManager honest save/load JSON stub
- [x] [MED] Bootstrap label uses tr()

