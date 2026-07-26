# Story 1.8: Tutorial Prompt System and Wave 1 Script

Status: done

## Dev Agent Record

### Completion Notes

- TutorialSystem: non-blocking prompts for Peanut placement (Ð20), watering, dissatisfaction warning
- WaveSpawner: wave 1 script spawns 8× Saw Ape at 2.5s intervals (4s initial delay)
- Pause panel tutorial stub buttons emit TUTORIAL_ACTION until Epic 2 real placement
- Wave 1 combat gated until prep tutorial complete; waves 2+ auto-continue
- Added saw_ape to content data and waves.json fallback

### File List

- leaf-me-alone/scripts/systems/tutorial_system.gd
- leaf-me-alone/scripts/systems/wave_spawner.gd
- leaf-me-alone/scenes/ui/tutorial_prompt.tscn
- leaf-me-alone/scenes/ui/tutorial_prompt.gd
- leaf-me-alone/data/apes/saw_ape.json
- leaf-me-alone/data/fallback/waves.json
- leaf-me-alone/data/fallback/apes.json
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/scenes/run/pause_panel.tscn
