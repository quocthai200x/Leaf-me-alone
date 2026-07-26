# Story 1.7: Map Pan and InputRouter Foundation

Status: done

## Tasks / Subtasks

- [x] Task 1: MapView container with 3x scaled grid (512→1536px width, exceeds viewport)
- [x] Task 2: InputRouter child of RunRoot in IDLE mode
- [x] Task 3: Click+drag pan with bounds clamp; pause panel narrows visible map to 1248px
- [x] Task 4: Godot headless boot verified

## Dev Agent Record

### Completion Notes

- `MapView` wraps GridRenderer at 3x scale; pan enabled when map exceeds visible area
- `InputRouter` under RunRoot routes IDLE drag-to-pan on map region (excludes pause panel column)
- `InteractionMode` enum stub for Epic 2 placement/care modes
- Visible map width: 1248px (pause) / 1920px (combat)

### File List

- leaf-me-alone/scenes/run/map_view.tscn
- leaf-me-alone/scenes/run/map_view.gd
- leaf-me-alone/scripts/input/input_router.gd
- leaf-me-alone/scripts/input/interaction_mode.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/run_root.gd

## Change Log

- 2026-07-26: Map pan and InputRouter foundation (Epic 1 loop)
