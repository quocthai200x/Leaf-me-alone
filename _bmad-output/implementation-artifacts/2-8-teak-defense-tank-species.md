---
baseline_commit: 51ce9e9
---

# Story 2.8: Teak — Defense Tank Species

Status: done

## Tasks / Subtasks

- [x] Add `hardwood_tank` ability to teak.json + fallback
- [x] Extend `resolve_plant_hit()` for Teak damage reduction
- [x] Unit tests + full suite pass (34/34)

## Dev Agent Record

### Completion Notes List

- Teak `hardwood_tank.damage_reduction_pct: 0.30` applied after defense in combat
- 4 new unit tests; code review approved

### File List

- leaf-me-alone/data/species/teak.json
- leaf-me-alone/data/fallback/species.json
- leaf-me-alone/scripts/systems/plant_ability_system.gd
- leaf-me-alone/test/teak_ability_test.gd

## Status

done
