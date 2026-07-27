# Story 4.7: Combat HUD — Structure HP and Wave Banner

Status: done

## Acceptance Criteria

1. Wave banner slides in on combat start with wave number and debut role icons, auto-dismiss 3s
2. Forest Core + 3 Root Nest HP cluster bottom-left
3. Health bars pulse danger below 25% HP
4. Wave percussion hit on Stings bus
5. Pause Phase shows structure HP summary in pause panel header

## Tasks / Subtasks

- [x] Task 1: StructureHpSystem + logic stubs from pathfinding (AC: #2)
- [x] Task 2: Combat HUD structure cluster + danger pulse (AC: #2, #3)
- [x] Task 3: Wave banner slide-in + Stings audio (AC: #1, #4)
- [x] Task 4: Pause panel structure summary (AC: #5)
- [x] Task 5: Tests in test/combat_hud_test.gd
- [x] Task 6: Full GdUnit4 suite passes

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/structure_hp_logic.gd (new)
- leaf-me-alone/scripts/systems/structure_hp_system.gd (new)
- leaf-me-alone/scripts/systems/wave_banner_logic.gd (new)
- leaf-me-alone/scripts/utils/constants.gd (structure HP + Stings bus)
- leaf-me-alone/scenes/run/combat_hud.gd (structure bars, wave banner)
- leaf-me-alone/scenes/run/combat_hud.tscn (UI nodes)
- leaf-me-alone/scenes/run/pause_panel.gd (structure summary)
- leaf-me-alone/scenes/run/pause_panel.tscn (StructureSummary label)
- leaf-me-alone/scenes/run/run_root.gd (banner + structure refresh)
- leaf-me-alone/scenes/run/run_root.tscn (StructureHpSystem)
- leaf-me-alone/test/combat_hud_test.gd (new)
