# Story 4.5: PR Ape — Billboard Dissatisfaction AoE

Status: done

## Story

As a player,
I want PR Apes to deploy billboards that increase dissatisfaction nearby,
So that corporate propaganda pressures my ecosystem.

## Acceptance Criteria

1. **Given** PR Ape active in combat **When** billboard deployed **Then** dissatisfaction increases in AoE during Combat Phase (FR15, FR31)
2. **Given** billboard active **When** rendered **Then** diegetic in-world prop with dissatisfaction tint (UX-DR33)
3. **Given** PR Ape dies **When** HP reaches 0 **Then** Ð12 awarded via EconomySystem (FR32)

## Tasks / Subtasks

- [x] Task 1: PR billboard constants + pure AoE logic (AC: #1)
- [x] Task 2: PrApeSystem deploy + dissatisfaction sync (AC: #1)
- [x] Task 3: Billboard visual on map Entities (AC: #2)
- [x] Task 4: Tests in test/pr_ape_test.gd (AC: #1, #3)
- [x] Task 5: Full GdUnit4 suite passes

## Dev Agent Record

### File List

- leaf-me-alone/scripts/systems/pr_billboard_logic.gd (new)
- leaf-me-alone/scripts/systems/pr_ape_system.gd (new)
- leaf-me-alone/scripts/entities/pr_billboard.gd (new)
- leaf-me-alone/scripts/systems/dissatisfaction_system.gd (billboard registry + tick)
- leaf-me-alone/scripts/utils/constants.gd (PR_BILLBOARD_*)
- leaf-me-alone/scenes/run/run_root.tscn (PrApeSystem)
- leaf-me-alone/test/pr_ape_test.gd (new)
