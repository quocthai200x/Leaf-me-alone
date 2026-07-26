# Story 1.8: Tutorial Prompt System and Wave 1 Script

Status: done

## Tasks / Subtasks

- [x] TutorialSystem with non-blocking prompts (place peanut, water, dissatisfaction warning)
- [x] TutorialPrompt UI + pause panel tutorial action buttons
- [x] WaveSpawner wave 1 script: 8× Saw Ape paced spawns
- [x] saw_ape.json + waves.json fallback data
- [x] RunRoot integration: prep tutorial gates combat start
- [x] Godot boot verified

## Dev Agent Record

### Completion Notes

- Peanut placement/water via pause panel buttons emit TUTORIAL_ACTION events
- Prep must complete before wave 1 combat begins
- Dissatisfaction prompt shown at combat start; auto-dismiss after 2nd ape spawn
- Wave 1: 8 saw apes, 2.5s interval, 4s initial delay

### File List

- leaf-me-alone/scripts/systems/tutorial_system.gd
- leaf-me-alone/scripts/systems/wave_spawner.gd
- leaf-me-alone/scenes/ui/tutorial_prompt.gd
- leaf-me-alone/scenes/ui/tutorial_prompt.tscn
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/scenes/run/pause_panel.tscn
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/data/apes/saw_ape.json
- leaf-me-alone/data/fallback/apes.json
- leaf-me-alone/data/fallback/waves.json

## Change Log

- 2026-07-26: Story 1.8 implemented (Epic 1 loop tick)
