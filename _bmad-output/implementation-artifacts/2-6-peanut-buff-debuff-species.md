# Story 2.6: Peanut — Buff/Debuff Species

Status: done

## Story

As a player,
I want Peanut to buff adjacent allies and slow nearby apes,
So that I have a cheap support/defensive option for early waves.

## Acceptance Criteria

1. Adjacent plants receive N-fixation attack/defense buff during combat (FR23)
2. Apes near Peanut are slowed by allelopathy (FR23)
3. Peanut placement cost remains Ð20 from species/economy data
4. Ability values driven from `data/species/peanut.json`, not hardcoded

## Tasks / Subtasks

- [x] Extend SpeciesDef + peanut.json with N-fixation and allelopathy ability data
- [x] PlantAbilitySystem — combat stat buffs + ape slow multiplier API
- [x] Wire to combat (STATE_CHANGED → CombatPhase) and APE_SPAWNED payload
- [x] Unit tests + full suite pass

## Dev Notes

- Reuse GridData plant placement from 2.4; stats from ContentRegistry SpeciesDef
- PlantAbilitySystem computes buffs on demand from grid layout (no TileMap mutation)
- Ape entities not fully implemented — expose `get_ape_move_speed_multiplier(cell)` for Epic 4
- Adjacency = 4-neighbor Manhattan distance 1

## Previous Story Intelligence

- EconomySystem sole wallet mutator; EventBus for cross-system events
- GridData stores plant_species_id, plant_hp, plant_dissatisfaction per cell
- RunRoot children pattern: EconomySystem, PlantPlacementSystem, CareSystem, etc.
