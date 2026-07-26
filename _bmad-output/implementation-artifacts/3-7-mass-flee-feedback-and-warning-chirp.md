---
baseline_commit: 47a3a7c
---

# Story 3.7: Mass Flee Feedback and Warning Chirp

Status: done

## Acceptance Criteria

- Warning chirp on Combat bus when dissatisfaction crosses tease/warning threshold (≥50)
- Screen-edge flee-color vignette (200ms) on mass flee (2+ active) or HR-triggered flee
- Optional resignation toast on first flee per wave

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/flee_feedback_logic.gd
- leaf-me-alone/scripts/systems/flee_feedback_system.gd
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scenes/run/combat_hud.gd
- leaf-me-alone/scenes/run/combat_hud.tscn
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/default_bus_layout.tres
- leaf-me-alone/test/flee_feedback_test.gd

## Status

done
