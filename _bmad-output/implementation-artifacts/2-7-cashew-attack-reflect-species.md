---
baseline_commit: f28bdee1996ba1b391e2b335f473d3ff2ba3e8e1
---

# Story 2.7: Cashew — Attack Reflect Species

Status: done

## Story

As a player,
I want Cashew to reflect damage to attacking apes,
So that I have an offensive deterrent plant.

## Acceptance Criteria

1. **Given** Cashew placed on Red Soil **When** ape attacks Cashew **Then** reflect damage applied to attacker per species JSON (FR22)
2. Cashew placement cost remains Ð35 from species/economy data
3. Reflect values driven from `data/species/cashew.json`, not hardcoded
4. Reflect API only active during `CombatPhase` (consistent with Peanut abilities in 2.6)
5. Non-Cashew plants return zero reflect damage

## Tasks / Subtasks

- [x] Extend `cashew.json` + fallback with `anacardic_reflect` ability (`reflect_pct`)
- [x] Add `resolve_plant_hit(plant_cell, incoming_damage) -> Dictionary` to PlantAbilitySystem
  - [x] Returns `{ plant_damage_taken, reflect_damage }` using combat defense stats
  - [x] Cashew reflect = `round(incoming_damage * reflect_pct)` from JSON
- [x] Unit tests: cost Ð35, reflect during combat, no reflect outside combat, non-cashew zero reflect
- [x] Full GdUnit4 suite passes with no regressions

## Dev Notes

- Extend PlantAbilitySystem — same pattern as Story 2.6
- Ape entities not implemented — `resolve_plant_hit()` API for Epic 4

## Dev Agent Record

### Agent Model Used

Composer

### Completion Notes List

- Added `anacardic_reflect.reflect_pct: 0.50` to cashew.json and fallback
- Implemented `resolve_plant_hit()` with combat-gated reflect damage
- 5 new unit tests; full suite 30/30 pass
- Code review: approved; fixed empty-cell test to use out-of-bounds cell

### File List

- leaf-me-alone/data/species/cashew.json
- leaf-me-alone/data/fallback/species.json
- leaf-me-alone/scripts/systems/plant_ability_system.gd
- leaf-me-alone/test/cashew_ability_test.gd
- _bmad-output/implementation-artifacts/2-7-cashew-attack-reflect-species.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-07-26: Story 2.7 — Cashew anacardic reflect damage API and tests

## Senior Developer Review (AI)

**Outcome:** Approve  
**Date:** 2026-07-26

### Action Items

- [x] [Low] Use out-of-bounds cell in empty-cell test instead of assuming (0,0) is empty

## Status

done
