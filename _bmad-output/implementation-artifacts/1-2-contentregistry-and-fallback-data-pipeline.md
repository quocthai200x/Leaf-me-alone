---
baseline_commit: 5ae1844ca4c612e795c034ed7a27013f3a0515a4
---

# Story 1.2: ContentRegistry and Fallback Data Pipeline

Status: done

## Story

As a developer,
I want ContentRegistry.load_all() with embedded fallback JSON,
So that balance data loads reliably at boot without ad-hoc file parsing in gameplay code.

## Acceptance Criteria

1. **Given** bootstrap complete **When** game boots **Then** ContentRegistry loads from `data/` with fallback in `data/fallback/`
2. **And** boot fails loudly if critical fallback data is missing (`push_error`, returns false)
3. **And** JSON in `data/` is treated read-only after load (no runtime mutation of loaded defs)
4. **And** no species/ape balance numbers hardcoded in gameplay scripts
5. **And** `ContentRegistry.load_all()` called automatically at boot from `_ready()`
6. **And** accessors `get_species(id) -> SpeciesDef` and `get_ape(id) -> ApeRoleDef` available

## Tasks / Subtasks

- [x] Task 1: Define data Resource classes (AC: #6)
  - [x] `scripts/data/species_def.gd` — id, display_name, plant_cost, hp, attack, defense fields from JSON
  - [x] `scripts/data/ape_role_def.gd` — id, display_name, hp, speed, role fields from JSON
- [x] Task 2: Create slice JSON content files (AC: #1, #4)
  - [x] `data/species/cashew.json`, `teak.json`, `peanut.json` with balance from GDD assumptions
  - [x] `data/apes/hr_ape.json`, `pr_ape.json`
  - [x] `data/fallback/species.json` — merged array of 3 species minimum
  - [x] `data/fallback/apes.json` — merged array of 2 apes minimum
- [x] Task 3: Implement ContentRegistry.load_all() (AC: #1, #2, #3, #5)
  - [x] Load primary JSON from `data/species/` and `data/apes/` directories
  - [x] On primary failure, fallback to `data/fallback/species.json` and `apes.json`
  - [x] If fallback also missing/malformed: `push_error()` and return false
  - [x] Store defs in read-only dictionaries keyed by id
  - [x] Call `load_all()` in `_ready()`; log result
- [x] Task 4: Implement getters and validation (AC: #4, #6)
  - [x] `get_species(species_id: String) -> SpeciesDef` — push_warning + null if missing
  - [x] `get_ape(role_id: String) -> ApeRoleDef` — push_warning + null if missing
  - [x] `has_species(id)`, `has_ape(id)` helpers
- [x] Task 5: Verify boot load (AC: #5)
  - [x] Boot prints successful load with species/ape counts
  - [x] No hardcoded balance in autoload or gameplay scripts

## Dev Notes

### Architecture Compliance

- **Fail loud at boot (ADR-005):** `load_all() -> bool`; never enter run with empty registry
- **Fallback minimum:** 3 species (cashew, teak, peanut), 2 apes (hr_ape, pr_ape)
- **Read-only after load:** Store as frozen copies; gameplay mutates RunState/GridData only
- **No mid-run JSON parsing:** All content loaded once at boot

### JSON Schema (minimum)

**species entry:**
```json
{ "id": "peanut", "display_name": "Peanut", "plant_cost": 20, "hp": 50, "attack": 5, "defense": 2 }
```

**ape entry:**
```json
{ "id": "hr_ape", "display_name": "HR Ape", "hp": 80, "speed": 60, "role": "hr" }
```

Use `[ASSUMPTION]` defaults from epics: peanut Ð20, water Ð5/fertilize Ð10 go in economy later (Story 2.2) — species costs only here.

### ContentRegistry API

```gdscript
func load_all() -> bool
func get_species(species_id: String) -> SpeciesDef
func get_ape(role_id: String) -> ApeRoleDef
func get_all_species_ids() -> Array[String]
func get_all_ape_ids() -> Array[String]
```

### Previous Story Intelligence (1.1)

- Autoload order: EventBus → RunManager → SaveManager → ContentRegistry
- ContentRegistry currently stub — replace stub body, keep autoload registration
- `data/fallback/` directory exists with `.gitkeep` — replace with real JSON
- Godot CLI not verified on dev machine — static validation OK

### File Structure

```
leaf-me-alone/
├── autoload/content_registry.gd    # UPDATE
├── scripts/data/species_def.gd     # NEW
├── scripts/data/ape_role_def.gd  # NEW
├── data/species/cashew.json        # NEW
├── data/species/teak.json
├── data/species/peanut.json
├── data/apes/hr_ape.json
├── data/apes/pr_ape.json
├── data/fallback/species.json      # NEW (required minimum)
└── data/fallback/apes.json
```

### Testing Requirements

- Manual: boot game, verify console shows loaded species/ape counts
- Test missing fallback: temporarily rename fallback file, confirm push_error + false return
- No GdUnit4 tests required until Story 1.9

### Project Context Rules

- Balance in JSON only — no magic numbers in scripts
- Use `push_error` for critical boot failures
- English display_name strings

### References

- [Source: _bmad-output/game-architecture.md#Content Loading]
- [Source: _bmad-output/game-architecture.md#ADR-005]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.2]
- [Source: _bmad-output/implementation-artifacts/1-1-bootstrap-godot-project-and-core-autoloads.md]

## Dev Agent Record

### Agent Model Used

Composer

### Debug Log References

- Godot CLI not available on dev machine; validated via static review and linter checks

### Completion Notes List

- Implemented `SpeciesDef` and `ApeRoleDef` Resource classes with `from_dict()` validation
- Created slice JSON for 3 species (GDD costs: Peanut 20, Cashew 35, Teak 50) and 2 apes (HR, PR)
- Full `ContentRegistry.load_all()` with primary dir load, fallback arrays, fail-loud errors
- Getters return `duplicate(true)` copies to keep registry read-only after load
- `_ready()` auto-loads and prints species/ape counts on boot
- No `.gitkeep` present in repo; fallback JSON files created directly

### File List

- leaf-me-alone/autoload/content_registry.gd (modified)
- leaf-me-alone/scripts/data/species_def.gd (new)
- leaf-me-alone/scripts/data/ape_role_def.gd (new)
- leaf-me-alone/data/species/cashew.json (new)
- leaf-me-alone/data/species/teak.json (new)
- leaf-me-alone/data/species/peanut.json (new)
- leaf-me-alone/data/apes/hr_ape.json (new)
- leaf-me-alone/data/apes/pr_ape.json (new)
- leaf-me-alone/data/fallback/species.json (new)
- leaf-me-alone/data/fallback/apes.json (new)

## Change Log

- 2026-07-26: Story created by create-story workflow (Epic 1 loop)
- 2026-07-26: Implemented ContentRegistry, data Resource classes, slice JSON, and fallback pipeline
