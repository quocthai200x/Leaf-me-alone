---
title: 'Game Architecture'
project: 'snake-rougelike'
date: '2026-07-26'
author: 'nam'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'

# Engine
engine: 'Godot 4.7.1'
platform: 'Windows PC (Steam)'
mcps:
  - 'GoPeak (HaD0Yun/Gopeak-godot-mcp)'
  - 'Context7 (upstash/context7)'

# Source Documents
gdd: '_bmad-output/planning-artifacts/gdds/gdd-snake-rougelike-2026-07-26/gdd.md'
epics: '_bmad-output/planning-artifacts/gdds/gdd-snake-rougelike-2026-07-26/epics.md'
brief: '_bmad-output/planning-artifacts/briefs/brief-angryplant-2026-07-26/brief.md'
---

# Game Architecture

## Executive Summary

**Leaf Me Alone** architecture targets **Godot 4.7.1** on **Windows PC (Steam)** with a custom 2D top-down tower defense roguelike stack built from scratch.

**Key Architectural Decisions:**

- **Grid as canonical world model** — `GridData` flat array authority + TileMapLayer visual; plants/apes are grid actors
- **RunRoot single-scene run lifecycle** — state machine toggles UI layers; MainMenu separate scene
- **Hybrid EventBus + direct signals** — `RunEvent` enum for cross-system; async flee chains stay on Plant
- **Tier 0 flee sequence** — `await begin_flee()`, wave clear gated on `active_flee_count == 0`
- **CardEffectApplier** — single entry for stat buffs (+40% cap) and soil terraforms

**Project Structure:** Hybrid Godot organization with 4 autoloads, 8 RunRoot systems, and slice-focused `data/` JSON pipeline.

**Implementation Patterns:** 4 novel patterns + 12 consistency rules ensuring AI agent compatibility.

**Ready for:** Godot project bootstrap and E1–E8 vertical slice implementation.

## Document Status

**Status:** Complete — GDS Architecture Workflow finished 2026-07-26.

**Steps Completed:** 9 of 9

---

## Project Context

### Game Overview

**Leaf Me Alone** — A top-down ecosystem tower defense roguelike where the player commands a moody plant army defending a procedurally generated island from corporate apes. Plants fight only if you earn their loyalty; wrong soil, neglect, weather, and PR billboards drive dissatisfaction, and units can flee mid-wave. Between waves, the player enters a pause-phase prep screen to plant, care for, and strategize. Roguelike card picks after waves 2 and 4 add run variance. Survive 5 waves, defeat a random Director boss, earn meta Carbon Credit.

**Codename:** `snake-rougelike` / `leaf-me-alone`  
**Canonical title:** Leaf Me Alone  
**Author:** nam  
**Team:** Solo developer

### Technical Scope

**Platform:** Windows PC (Steam), mouse-first  
**Engine:** Godot 4.x (4.4+ recommended)  
**Language:** GDScript (primary)  
**Genre:** Tower Defense Roguelite with ecosystem management  
**Project Level:** Medium complexity (vertical slice); Medium-High at full release

### Core Systems

Complexity is tagged **Slice** (vertical slice) vs **Full** (EA/1.0). Slice scope: tropical biome, Red Soil clan (3 plants), HR + PR apes, 5 waves + Director placeholder.

| System | Slice | Full | Epic | Description |
|--------|-------|------|------|-------------|
| Flee Sequence + Dissatisfaction | **Tier 0 / High** | High | E2 | Multi-cause mood tracking, animated flee (😤→🏃→whoosh); USP spine |
| Pause Phase + InteractionMode FSM | Medium-High | Medium-High | E1 | Grid edit mode: `IDLE \| PLACE_PLANT \| CARE \| INSPECT` |
| Run State Machine | High | High | E1 | Pause ↔ Combat ↔ CardPick ↔ RunEnd; state-driven UI layers |
| Combat Entity Lifecycle | High | High | E2/E4 | Flee/removal/tile barren/ape reroute integration |
| Ape Behavior System | Medium | High | E4/E12 | Goal priority, role behaviors, HR threshold modifier |
| Pathfinding (AStarGrid2D) | Medium | Medium | E4 | Grid A* with movement cost modifiers |
| Plant Species & Soil | Medium | Medium | E3 | Biology-driven roles, placement validation |
| Wave Spawner | Medium | Medium | E1/E4 | 5-wave scripts, role composition, duration pacing |
| Dogecoin Economy | Medium | Medium | E5 | In-run earn/spend, role-weighted drops |
| CardEffectApplier | Medium | Medium | E6 | Stat buff stacking (+10–20%, max +40%) |
| Grid Mutation API | Low (stub) | Medium-High | E6/E11 | Soil terraform via canonical grid; region scope at full release |
| Procedural Maps | **Low (stub)** | Medium | E11 | Slice: seeded tropical template; full: 5 biomes |
| Weather | **Low (stub)** | Medium | E10 | Slice: one weather type; full: rain/sun/storm/mold |
| Director Boss | Medium | Medium | E8 | 3 Directors, mission types A/B/C |
| Meta Progression | Low (stub) | Medium | E9 | SaveManager interface; Carbon Shop deferred |
| Save/Load | Low | Low | E9 | Local meta save, settings, run seed metadata |
| UI (Control + Theme) | Medium | Medium | E1 | Theme-driven; Pause panel, combat HUD, card modal |

### Architectural Decisions (from Party Mode review)

| Decision | Rationale |
|----------|-----------|
| **Grid as Canonical World Model** | Single grid authority for soil, occupancy, barren, structures; plants/apes are actors on the grid |
| **RunRoot single-scene pattern** | One `RunRoot.tscn`; RunManager states toggle UI layers (Pause, Combat HUD, CardPick modal, RunEnd overlay) — no scene swaps that lose grid state |
| **RunState isolation** | RunManager owns all in-run state (Dogecoin, dissatisfaction, card buffs, terraforms); explicit `reset()` on new run; never leaks to SaveManager |
| **EventBus contract** | Finite `RunEvent` enum for cross-system events; direct signals for entity-local sequences (e.g., flee animation chain) |
| **ContentRegistry pattern** | JSON/Resource loading pattern documented; slice uses simple folder load — full registry at E11 scale |
| **FleeTelemetry** | Per flee: `{ wave, cause, species }`; aggregated on RunEnd for tuning and playtest surveys |
| **SaveManager interface stub** | `get_carbon_credit()`, `add_carbon_credit(n)`, `save()` only for slice; Carbon Shop in E9 |
| **Test seed artifact** | `test_run_seed_001` — mandatory integration test: Pause → Combat → flee → tile barren → ape reroute |

### Technical Requirements

**Performance:**
- 60 FPS sustained at 1080p on mid-range PC (GTX 1060 class)
- Peak load: ~40 plants + 30 apes during combat
- UI response within 100 ms for interactive actions
- Combat systems (spawner + pathfinding + dissatisfaction) under ~8 ms combined at peak

**Platform:**
- Windows PC export (Steam target)
- Mouse-only input for v1.0 (click select/place, drag pan map)
- 1920×1080 design baseline, scalable Control UI
- English-only UI with `tr()` for future localization

**Persistence:**
- Local file save (`user://save/meta.json`) — Carbon Credit, unlocks, settings
- No cloud backend in v1.0
- Run seed stored in save metadata for debug replay

**Content Pipeline:**
- JSON or `.tres` Resource files for cards, waves, species, ape roles
- Balance numbers in data files, not magic numbers in scripts
- Content loaded once at run start; no mid-combat parsing

### Complexity Drivers

**High Complexity (slice-critical):**
- Flee sequence as Tier 0 USP — must land before other systems matter
- Run state machine as central coordination spine
- Combat-phase entity lifecycle (flee crosses dissatisfaction, tiles, pathfinding, SFX, telemetry)
- Pause Phase as grid edit mode — half the game, not bolt-on UI

**High Complexity (full release):**
- Ape behavior composition (9 roles, goal priority, tile locks, concrete roads)
- Grid mutation at region scope (soil terraform cards)
- Data-driven content for 16 plants, 9 apes, cards, waves, 5 biomes

**Novel Concepts (no standard patterns):**
- Plants desert mid-combat with visible flee feedback
- Biology-driven 4-role soil system (not generic tower archetypes)
- Corporate ape role behaviors (HR flee threshold, PR dissatisfaction zones)
- Permanent in-run soil terraforming via card picks
- Seven Deadly Sins extreme buff/tradeoff framework (post-slice)

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Flee feels punishing | Player frustration, bad reviews | Prototype early; FleeTelemetry from day one; tutorial + HR telegraph |
| Performance at peak wave | Frame drops break TD readability | Object pooling, batch dissatisfaction updates, avoid per-frame allocations |
| Pause loop soft-lock | Run unplayable | State machine with explicit transitions; `test_run_seed_001` integration test |
| Scope creep (solo dev) | Delayed slice | Strict slice boundary: 1 biome, 3 plants, 2 apes; stub weather/maps/meta |
| Unresolved design notes | Architecture rework | Flag TBD items (mold weather, Director kits, mutation paths) as deferred |
| Dual economy confusion | Save corruption, currency bugs | RunState isolation; separate save paths; explicit reset on new run |
| EventBus overuse | Debug nightmare | Finite RunEvent enum; direct signals for entity-local sequences |

---

## Engine & Framework

### Selected Engine

**Godot 4.7.1** (stable, July 2026)

**Rationale:** GDD-specified engine; best fit for 2D top-down TD with custom grid mechanics, solo GDScript development, free/open-source, and Windows Steam export. Verified current stable release at [godotengine.org/download/archive/4.7.1-stable/](https://godotengine.org/download/archive/4.7.1-stable/).

### Project Initialization

Start from scratch — no starter template. Existing TD templates (e.g., Outpost Assault) assume lane/path-based design incompatible with free-placement island grid architecture.

```bash
# Create project via Godot Project Manager
# Project path: leaf-me-alone/
# Renderer: Forward Plus (default) or Compatibility for older GPU testing
# Version control: Git, plain-text .tscn/.tres only
```

Bootstrap order:
1. Create Godot 4.7.1 project at `leaf-me-alone/`
2. Configure autoloads: EventBus, RunManager, SaveManager
3. Create `RunRoot.tscn` with grid + UI layer stack
4. Add Windows Desktop export preset

### Engine-Provided Architecture

| Component | Solution | Notes |
| --------- | -------- | ----- |
| Rendering | 2D CanvasItem / TileMapLayer | Top-down island view |
| Physics | StaticBody2D / Area2D | Minimal for slice; plants are grid actors, not physics bodies |
| Audio | AudioStreamPlayer + buses | Flee whoosh SFX priority |
| Input | InputMap + mouse events | Mouse-only v1.0 |
| Pathfinding | AStarGrid2D | Grid-based ape movement with cost modifiers |
| UI | Control + Theme | Pause panel, combat HUD, card modal |
| Scene Management | .tscn + signals | RunRoot single-scene pattern |
| Save/Load | FileAccess + `user://` | Meta progression local save |
| Export | Windows Desktop preset | Steam target platform |

### AI Tooling (MCP Servers)

| MCP | Repo | Install | Purpose |
| --- | ---- | ------- | ------- |
| **GoPeak** | [HaD0Yun/Gopeak-godot-mcp](https://github.com/HaD0Yun/Gopeak-godot-mcp) | `npx -y gopeak` | Scene editing, LSP diagnostics, DAP debugging, runtime inspection (~95+ tools) |
| **Context7** | [upstash/context7](https://github.com/upstash/context7) | `npx -y @upstash/context7-mcp` | Current Godot 4.7 API documentation lookup |

**GoPeak Cursor config:**

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["-y", "gopeak"],
      "env": {
        "GODOT_PATH": "C:/path/to/Godot_v4.7.1-stable_win64.exe",
        "GOPEAK_TOOL_PROFILE": "compact"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Remaining Architectural Decisions

_Decisions 1–4 confirmed by nam; Decisions 5–12 per architect recommendation; Party Mode Rounds 3–5 amendments applied (2026-07-26)._

---

## Architectural Decisions

### Decision Summary

| Category | Decision | Version | Rationale |
| -------- | -------- | ------- | --------- |
| State Management | State Machine in `RunManager` + `RunState` Resource | — | Transitions in RunManager; data in RunState; `can_transition_to()` guards |
| Grid Data Model | `GridData` flat array + TileMapLayer visual | Godot 4.7.1 | Single Resource with packed cell data; render layer syncs from authority |
| Event Communication | Hybrid EventBus + direct signals + `FleeEventData` | — | Typed cross-system payloads; entity-local flee chains stay on Plant |
| Autoload Boundaries | 4 autoloads: EventBus, RunManager, SaveManager, ContentRegistry | — | Lean globals; gameplay systems under RunRoot |
| Save System | Local JSON at `user://save/meta.json` | — | Offline meta persistence; no cloud in v1.0 |
| Content Loading | `ContentRegistry.load_all() -> bool` + fallback data | — | Fail loud at boot; embedded fallback for slice |
| Ape Pooling + Pathfinding | Object pool + incremental `AStarGrid2D` | Godot 4.7.1 | Pool size 35; update pathfinding per cell on flee, not full rebuild |
| Flee Sequence | Animated chain → `FleeEventData` → EventBus | — | Tier 0 USP; sets `depleted` flag on tile |
| InteractionMode FSM | `IDLE \| PLACE_PLANT \| CARE \| INSPECT` | — | Single input router; INSPECT shared in Pause + Combat |
| RNG Seeding | `master_seed` → derived RNG streams | — | Reproducible map, card, and wave rolls |
| Economy Type | Dogecoin as `int` only | — | Whole-number satire UI; no fractional currency |
| UI Framework | Control nodes + Godot Theme | — | DESIGN.md tokens; MainMenu separate scene |
| Test Framework | GdUnit4 + `tests/fixtures/run_seed_001.json` | latest | Golden fixture for integration tests |
| Audio | Engine-native AudioStreamPlayer + buses | Godot 4.7.1 | FMOD deferred |
| Steam Integration | Stub interface, deferred post-slice | — | FR-74/FR-75 acceptable as stubs |

### State Management

**Approach:** State Machine in `RunManager` autoload + `RunState` Resource (data/logic split)

**Scene boundaries:**
- `main_menu.tscn` — separate scene (Carbon Credit header, PLAY, settings)
- `run_root.tscn` — entire run lifecycle; state machine toggles UI layers only

**States:**

```
MainMenu ──(PLAY)──► RunStart ──► PausePhase ◄──► CombatPhase
                                      ▲                │
                                      │         (waves 2 & 4)
                                      └── CardPickPhase
RunEnd ──► MainMenu
```

**Transition rules:**
- `CombatPhase → CardPickPhase` only after waves 2 or 4 clear
- `CardPickPhase → PausePhase` always (never back to Combat without new wave)
- `RunManager.can_transition_to(to_state) -> bool` — UI disables actions when false
- Transitions emit `RunEvent.STATE_CHANGED` via EventBus
- `RunManager.reset()` callable **only** from `MainMenu` and `RunEnd` states
- No mid-combat pause in MVP

**RunState Resource owns:**
- `master_seed: int` and derived `map_rng`, `card_rng`, `wave_rng` (`RandomNumberGenerator`)
- `dogecoin: int` (integer only)
- `wave_index: int`
- `flee_telemetry: Array[FleeEventData]`
- Card buffs, soil terraforms (in-run only)

**WaveSpawner owns:** wave duration, spawn script, active ape count — not RunManager.

### Grid Data Model

**Approach:** Single `GridData` Resource with flat packed cell storage + `TileMapLayer` (visual only)

**Storage:** One `GridData` Resource containing width, height, and flat array of cell structs — **not** per-cell Resource instances.

**Cell schema (packed struct within GridData):**

```gdscript
# Conceptual cell fields (stored in flat array)
soil_type: SoilType       # RED, SAND, ROCK, MOLD — ecological only
occupied: bool             # plant present on tile
depleted: bool              # barren/non-replantable (flee, Greed Sin)
structure_ref: int         # -1 = none; else index into structures array
concrete_overlay: bool     # Glue Ape road / factory tile — movement modifier
movement_cost: float        # synced to AStarGrid2D
```

**Rules:**
- `depleted` is a flag on top of `soil_type` — not a soil type value
- Concrete is an overlay/modifier, not soil replacement
- Known structures use enum constants; `structure_ref` indexes `GridData.structures[]`
- All placement, flee, and card terraforming mutate `GridData` first
- TileMapLayer refreshes from `GridData` — never edit tile data independently
- Plants and apes reference `Vector2i` grid coords

### Event Communication

**Approach:** Hybrid — EventBus for cross-system, direct signals for entity-local

**RunEvent enum (EventBus):**

```gdscript
enum RunEvent {
    STATE_CHANGED,
    WAVE_STARTED,
    WAVE_CLEARED,
    PLANT_FLED,
    APE_KILLED,
    CARD_PICKED,
    RUN_WON,
    RUN_LOST,
}
```

**FleeEventData (typed payload for PLANT_FLED):**

```gdscript
class_name FleeEventData
extends Resource

@export var wave: int
@export var cause: String      # "hr", "care", "soil", "weather"
@export var species: String    # "peanut", "teak", etc.
@export var grid_pos: Vector2i
```

**Direct signal boundary:** flee animation chain (`flee_started` → `flee_completed`) stays on Plant node; emits `RunEvent.PLANT_FLED` with `FleeEventData` only after tile update completes.

### Autoload Boundaries

| Autoload | Owns | Does NOT own |
|----------|------|--------------|
| **EventBus** | `RunEvent` signal hub | Game state |
| **RunManager** | State machine, `RunState`, transitions, `can_transition_to()`, `reset()` | Wave timer, meta save, threshold math |
| **SaveManager** | `user://save/meta.json` | In-run state |
| **ContentRegistry** | `load_all() -> bool`; JSON/Resource defs | Runtime mutations |

**RunRoot scene nodes (not autoloads):** WaveSpawner, DissatisfactionSystem, EconomySystem, CardSystem, GridRenderer, ApePool, InputRouter

**Ownership rule:** `DissatisfactionSystem` sole owner of threshold math; HR Ape emits `modifier_applied(radius)` only.

### Data Persistence

**Save System:** Local JSON files

- **Path:** `user://save/meta.json`
- **Contents:** Carbon Credit total, clan unlocks, settings, achievement flags
- **Slice stub:** `get_carbon_credit()`, `add_carbon_credit(n)`, `save()` only
- **Run seed:** `RunState.master_seed` displayed on RunEnd screen
- **Never write to `res://`**

### Asset & Content Loading

**Strategy:** Load once at run start; fail loud with fallback

| Asset Type | Load Timing | Format |
|------------|-------------|--------|
| Species, apes, waves, cards | Run start via `ContentRegistry.load_all()` | JSON in `data/` |
| Card definitions | Preload at RunStart | JSON |
| Card art | Lazy (unless total < 500KB) | `.png` in `assets/` |
| Plant/ape scenes | Preload at run start | `.tscn` |
| UI Theme | Project load | `.tres` in `themes/` |
| Audio | Lazy load on first play | `.ogg` in `assets/audio/` |
| Map template | Run start from `map_rng` | `GridData` from biome template |

**ContentRegistry failure:** `push_error()` + load embedded `data/fallback/` (3 species, 2 apes minimum); never enter run with empty registry.

### Ape Pooling & Pathfinding

**Pooling:** `ApePool` node under RunRoot — pre-instantiate pool size 35; spawn/despawn via pool, never `instantiate()` mid-wave

**Pathfinding:** `AStarGrid2D` synced from `GridData.movement_cost`

**Incremental updates:** On flee or tile change, update affected cell weight only — do not rebuild entire grid

**Goal priority:** Forest Core > nearest Root Nest > highest-value extract tile

**Cost modifiers:** Mangrove/Lichen +cost; concrete overlay −50% cost

### Flee Sequence Architecture

**Pattern:** Tier 0 — animated sequence, not instant removal

```
Dissatisfaction threshold reached (DissatisfactionSystem)
  → Plant emits flee_started (direct signal)
  → 😤 emoji → 🏃 animation → whoosh SFX
  → Plant reaches map back edge
  → GridData: occupied = false, depleted = true
  → Incremental AStarGrid2D cell update
  → Plant.queue_free()
  → Plant emits flee_completed (direct signal)
  → EventBus.emit(PLANT_FLED, FleeEventData)
  → ApePool reroutes affected apes
  → RunState.flee_telemetry.append(data)
```

### InteractionMode FSM

**Modes:** `IDLE | PLACE_PLANT | CARE | INSPECT`

- **InputRouter** node under RunRoot — single click handler, routes by mode + run state
- `INSPECT` available in both PausePhase and CombatPhase (read dissatisfaction HUD)
- `PLACE_PLANT` and `CARE` locked during CombatPhase
- Pause Phase = grid edit mode with dim overlay + right panel

### UI Framework

**Approach:** Control-based UI with Godot Theme mapped to DESIGN.md tokens

- No hardcoded hex in scripts when theme token exists
- RunRoot layers: combat HUD, pause panel, card modal, run end overlay
- MainMenu is separate scene — max two navigation levels within run states

### Test Framework

**Framework:** GdUnit4

**Deliverables:**
- `tests/fixtures/run_seed_001.json` — golden run seed with expected state checkpoints
- **Unit tests:** dissatisfaction math, card modifier stacking, Dogecoin int earn/spend, RNG reproducibility
- **Integration test:** Pause → Combat → flee → depleted tile → ape reroute
- **State transition test:** all paths through `can_transition_to()` matrix never soft-lock

### Audio Architecture

**Approach:** Engine-native Godot AudioStreamPlayer + audio buses

| Bus | Purpose |
|-----|---------|
| Master | Global volume |
| Music | Lo-fi prep / combat escalation |
| SFX | Flee whoosh (priority polish), UI clicks |
| Ambient | Forest rain loop |

FMOD/Wwise deferred — not needed for slice.

### Architecture Decision Records

**ADR-001: Grid as Canonical World Model**  
All spatial game state lives in `GridData` flat array. Plants, apes, and structures are actors referencing grid coords. TileMapLayer is render-only. `depleted` and `concrete_overlay` are flags, not soil types.

**ADR-002: RunRoot Single-Scene Pattern**  
One scene (`run_root.tscn`) for entire run lifecycle. State machine toggles UI layers. MainMenu is a separate scene. No scene swaps during a run that lose grid state.

**ADR-003: RunState Isolation**  
`RunState` Resource holds all in-run data. `RunManager` handles transitions only. `reset()` callable only from MainMenu and RunEnd. SaveManager never sees Dogecoin or dissatisfaction values. `master_seed` drives derived RNG streams.

**ADR-004: Hybrid Event Communication**  
Finite `RunEvent` enum on EventBus for cross-system. Typed `FleeEventData` for payloads. Direct signals for entity-local sequences. Document boundary in every system script header.

**ADR-005: Fail Loud at Boot**  
ContentRegistry returns bool; malformed JSON never enters mid-run. Fallback embedded data for slice dev continuity.

---

## Cross-cutting Concerns

These patterns apply to ALL systems and must be followed by every implementation.

### Error Handling

**Strategy:** Early return + Godot native error functions (no exceptions in GDScript)

| Level | Handler | Player-visible? | Example |
|-------|---------|-----------------|---------|
| Critical (boot) | `push_error()` + fallback | No | ContentRegistry JSON malformed |
| Recoverable (runtime) | Return `false` + UI toast | Yes | Plant on depleted tile, insufficient Dogecoin |
| Invariant violation | `push_warning()` + ignore | No | Double-click during blocked transition |

Errors never pause the game in MVP. Critical failures occur at boot, not mid-combat.

**Example:**

```gdscript
func try_place_plant(cell: Vector2i, species_id: String) -> bool:
    if not grid.can_plant(cell):
        ui.show_toast(tr("CANNOT_PLANT_HERE"))
        return false
    if run_state.dogecoin < cost:
        ui.show_toast(tr("INSUFFICIENT_DOGECOIN"))
        return false
    # ... place plant
    return true
```

### Logging

**Format:** Godot native (`print` / `push_warning` / `push_error`)  
**Destination:** Output panel (dev only); no file logging in slice

**Log on:** state transitions, wave start/clear, flee events, ContentRegistry load result  
**Never log in:** `_process`, `_physics_process`, A* pathfinding hot paths

**Example:**

```gdscript
func transition_to(new_state: RunStateEnum) -> void:
    if not can_transition_to(new_state):
        push_warning("Blocked transition: %s -> %s" % [_state, new_state])
        return
    print("[RunManager] %s -> %s" % [_state, new_state])
    _state = new_state
    EventBus.emit_run_event(RunEvent.STATE_CHANGED, {"from": _state, "to": new_state})
```

### Configuration

**Approach:** Three-tier — constants script, JSON data, player settings file

| Tier | Location | Mutable at runtime? |
|------|----------|---------------------|
| Constants | `scripts/utils/constants.gd` | No |
| Balance | `data/*.json` via ContentRegistry | No (read-only after load) |
| Settings | `user://save/meta.json` | Yes (SaveManager) |

Balance numbers tagged `[ASSUMPTION]` in GDD live in JSON, never in gameplay scripts.

### Event System

**Pattern:** Hybrid EventBus (ADR-004)

**Cross-cutting rule:** Every system script file header must document:
- RunEvent values emitted
- RunEvent values listened to
- Direct signals used (entity-local only)

### Debug Tools

**Activation:** `OS.is_debug_build()` — F3 toggles debug overlay

| Tool | Purpose | Release build |
|------|---------|---------------|
| Run seed display | RunEnd screen (FR-6) | Yes |
| Seed input field | Reproducible bug reports | No |
| State HUD | RunManager state + transition matrix | No |
| Flee telemetry dump | Live `RunState.flee_telemetry` | No |
| Skip-to-wave | Debug console command | No |

---

## Project Structure

### Organization Pattern

**Pattern:** Hybrid (Godot type-based root + feature grouping within)

**Rationale:** Godot idiomatic layout; species scripts co-locate with scenes; planning artifacts stay outside Godot project tree. **This document is authoritative for structure** — sync `project-context.md` when Godot project is bootstrapped.

### Directory Structure

```
leaf-me-alone/                      # Godot project root
├── project.godot
├── export_presets.cfg
├── .gitignore                      # Ignore .godot/; commit .tscn, .gd, data/, assets/
│
├── autoload/                       # Singleton scripts ONLY (project.godot entries)
│   ├── event_bus.gd
│   ├── run_manager.gd
│   ├── save_manager.gd
│   └── content_registry.gd
│
├── addons/
│   └── gdUnit4/                    # Test framework plugin
│
├── scenes/
│   ├── main/
│   │   └── main_menu.tscn          # Slice: menu only (settings as sub-panel)
│   ├── run/
│   │   ├── run_root.tscn           # Run lifecycle host (ADR-002)
│   │   └── grid_renderer.tscn
│   ├── ui/
│   │   ├── run/                    # Run-specific UI layers
│   │   │   ├── pause_panel.tscn
│   │   │   ├── combat_hud.tscn
│   │   │   ├── card_pick_modal.tscn
│   │   │   └── run_end_overlay.tscn
│   │   └── components/             # Reusable Control components
│   │       ├── btn_primary.tscn
│   │       ├── resource_chip.tscn
│   │       └── dissatisfaction_indicator.tscn
│   ├── entities/
│   │   ├── plants/
│   │   │   ├── plant_base.gd       # Shared base (in scripts/entities/ if preferred)
│   │   │   ├── plant_cashew.tscn
│   │   │   ├── plant_cashew.gd
│   │   │   ├── plant_teak.tscn
│   │   │   ├── plant_teak.gd
│   │   │   ├── plant_peanut.tscn
│   │   │   └── plant_peanut.gd
│   │   ├── apes/
│   │   │   ├── ape_hr.tscn
│   │   │   ├── ape_hr.gd
│   │   │   ├── ape_pr.tscn
│   │   │   └── ape_pr.gd
│   │   └── structures/
│   │       ├── forest_core.tscn
│   │       ├── root_nest.tscn
│   │       └── pr_billboard.tscn
│   └── debug/
│       └── debug_overlay.tscn      # Loaded only when OS.is_debug_build()
│
├── scripts/
│   ├── data/                       # Resources, defs, enums (NOT autoloads)
│   │   ├── run_state.gd
│   │   ├── run_state_enum.gd
│   │   ├── run_event.gd
│   │   ├── grid_data.gd
│   │   ├── flee_event_data.gd
│   │   ├── species_def.gd
│   │   ├── ape_role_def.gd
│   │   ├── wave_def.gd
│   │   └── card_def.gd
│   ├── systems/                    # Gameplay systems (nodes under RunRoot)
│   │   ├── wave_spawner.gd
│   │   ├── dissatisfaction_system.gd
│   │   ├── economy_system.gd
│   │   ├── card_system.gd
│   │   ├── ape_pool.gd
│   │   └── pathfinding_service.gd
│   ├── entities/                   # Shared entity bases ONLY (3+ scene reuse)
│   │   ├── plant_base.gd
│   │   ├── ape_base.gd
│   │   └── structure_base.gd
│   ├── input/
│   │   └── input_router.gd         # Child of RunRoot, NOT autoload
│   └── utils/
│       ├── constants.gd
│       └── object_pool.gd
│
├── resources/                      # .tres only — Theme, biome templates (NOT balance JSON)
│   └── biomes/
│       └── tropical_template.tres
│
├── data/                           # JSON source of truth for balance/content
│   ├── species/
│   │   ├── cashew.json
│   │   ├── teak.json
│   │   └── peanut.json
│   ├── apes/
│   │   ├── hr_ape.json
│   │   └── pr_ape.json
│   ├── waves/
│   │   └── slice_waves.json
│   ├── cards/
│   │   ├── stat_cards.json
│   │   └── soil_cards.json
│   └── fallback/                   # ContentRegistry failure minimum
│       ├── species.json
│       └── apes.json
│
├── assets/
│   ├── art/
│   │   ├── plants/
│   │   ├── apes/
│   │   ├── tiles/
│   │   └── ui/
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   └── ambient/
│   └── fonts/
│
├── themes/
│   └── leaf_me_alone_theme.tres
│
└── test/                           # GdUnit4 convention
    ├── fixtures/
    │   └── run_seed_001.json
    ├── dissatisfaction_test.gd
    ├── card_stacking_test.gd
    ├── dogecoin_test.gd
    └── run_flow_test.gd
```

Planning artifacts remain in `_bmad-output/` — never inside `leaf-me-alone/`.

### RunRoot Scene Tree Order

Children of `run_root.tscn` (order matters for draw/input):

```
RunRoot
├── GridRenderer          # TileMapLayer visual sync
├── Entities              # Plants, structures container
├── ApePool               # Pooled ape instances
├── InputRouter           # InteractionMode FSM
├── UI                    # CanvasLayer stack (pause, combat, card, run_end)
└── DebugOverlay          # Conditional — debug builds only
```

### System Location Mapping

| System | Location | Responsibility |
| ------ | -------- | -------------- |
| EventBus | `autoload/event_bus.gd` | RunEvent signal hub |
| RunManager | `autoload/run_manager.gd` | State machine, transitions |
| RunState | `scripts/data/run_state.gd` | In-run data Resource (held by RunManager) |
| SaveManager | `autoload/save_manager.gd` | Meta JSON persistence |
| ContentRegistry | `autoload/content_registry.gd` | Boot-time JSON load + fallback |
| GridData | `scripts/data/grid_data.gd` | Canonical world model |
| GridRenderer | `scenes/run/grid_renderer.tscn` | TileMapLayer visual sync |
| WaveSpawner | `scripts/systems/wave_spawner.gd` | Wave timer, spawn scripts |
| DissatisfactionSystem | `scripts/systems/dissatisfaction_system.gd` | Threshold math, flee triggers |
| EconomySystem | `scripts/systems/economy_system.gd` | Dogecoin earn/spend (int) |
| CardSystem | `scripts/systems/card_system.gd` | Card pick, effect application |
| ApePool | `scripts/systems/ape_pool.gd` | Object pool + spawn/despawn |
| PathfindingService | `scripts/systems/pathfinding_service.gd` | AStarGrid2D incremental updates |
| InputRouter | `scripts/input/input_router.gd` | InteractionMode routing |
| Debug overlay | `scenes/debug/debug_overlay.tscn` | F3 HUD (debug builds only) |
| MainMenu | `scenes/main/main_menu.tscn` | Separate scene (ADR-002) |

### Naming Conventions

#### Files

| Type | Convention | Example |
|------|------------|---------|
| Scripts | `snake_case.gd` | `wave_spawner.gd` |
| Scenes | `snake_case.tscn` matching root node | `plant_cashew.tscn` |
| Resources | `snake_case.tres` | `tropical_template.tres` |
| JSON data | `snake_case.json` | `slice_waves.json` |
| Tests | `*_test.gd` in `test/` | `dissatisfaction_test.gd` |
| Sprites | `{entity}_{state}.png` | `ape_hr_walk.png` |
| SFX | `{action}_{variant}.ogg` | `flee_whoosh.ogg` |

#### Code Elements

| Element | Convention | Example |
| ------- | ---------- | ------- |
| Class names | PascalCase | `GridData`, `FleeEventData` |
| Functions | snake_case | `can_transition_to()`, `try_place_plant()` |
| Variables | snake_case | `run_state`, `grid_pos` |
| Constants | UPPER_SNAKE | `MAX_CARD_STACK`, `APE_POOL_SIZE` |
| Signals | snake_case | `flee_started`, `flee_completed` |
| RunEvent enum | UPPER_SNAKE | `PLANT_FLED`, `WAVE_CLEARED` |
| Groups | plural snake_case | `"plants"`, `"apes"`, `"structures"` |

### Architectural Boundaries

1. **Autoloads never hold entity node references** — use signals and RunState data
2. **Systems under RunRoot never call `change_scene()`** — RunManager owns scene transitions
3. **Plants/apes mutate grid via GridData API only** — never edit TileMapLayer directly
4. **UI emits intent; systems validate and execute** — no game logic in Control scripts
5. **JSON in `data/` is read-only after ContentRegistry load** — runtime changes go to RunState/GridData
6. **Species scripts co-locate with `.tscn`**; shared bases in `scripts/entities/` when reused 3+ times
7. **No imports from `_bmad-output/`** into Godot project
8. **JSON primary for balance; `resources/` for Theme and biome `.tres` templates only**
9. **Commit source + assets; ignore `.godot/`** in version control
10. **`game-architecture.md` overrides `project-context.md` on structure** until bootstrap sync

---

## Implementation Patterns

These patterns ensure consistent implementation across all AI agents.

### Novel Patterns

#### Flee Sequence Pattern

**Purpose:** Tier 0 USP — animated plant desertion mid-combat, not instant removal.

**Components:**
- `DissatisfactionSystem` — detects threshold breach, tracks `active_flee_count`
- `Plant` — owns async animation via `begin_flee()`
- `GridData` — sets `occupied=false`, `depleted=true` on completion
- `PathfindingService` — incremental cell update after tile change
- `EventBus` — emits `PLANT_FLED` with `FleeEventData` after sequence completes

**Data Flow:**
```
DissatisfactionSystem.trigger_flee(plant)
  → active_flee_count += 1
  → await plant.begin_flee()              # async — animation first
  → grid_data.set_depleted(cell)
  → pathfinding_service.update_cell(cell)
  → EventBus.emit(PLANT_FLED, flee_data)
  → RunState.flee_telemetry.append(flee_data)
  → active_flee_count -= 1
```

**Example:**
```gdscript
# plant_base.gd
func begin_flee() -> void:
    flee_started.emit()
    await _play_flee_animation()  # 😤 → 🏃 → whoosh SFX
    _grid_data.set_depleted(_grid_pos)
    flee_completed.emit()
    EventBus.emit_plant_fled(_build_flee_event_data())
```

**Edge cases:**
- Wave clear gated on `active_flee_count == 0` — no CardPick until flees finish
- Multiple simultaneous flees: independent per-plant; grid updates per-cell
- ApePool reroutes on `PLANT_FLED`, not on `flee_started`

---

#### Dissatisfaction Accumulator Pattern

**Purpose:** Multi-cause mood tracking with role-based threshold modifiers.

**Components:**
- `DissatisfactionSystem` — sole owner of threshold math
- `Plant` — stores current dissatisfaction value
- HR Ape — emits `modifier_applied(radius)`; never mutates threshold directly

**Example:**
```gdscript
func get_flee_threshold(plant: PlantBase, modifiers: Array) -> int:
    var threshold := Constants.STANDARD_FLEE_THRESHOLD  # 100
    for mod in modifiers:
        if mod.type == "hr_radius" and mod.covers(plant.grid_pos):
            threshold = Constants.HR_FLEE_THRESHOLD  # 50
    return threshold
```

---

#### Grid Edit Mode Pattern

**Purpose:** Pause Phase as grid interaction FSM, not bolt-on UI.

**Modes:**

| Mode | PausePhase | CombatPhase |
|------|------------|-------------|
| IDLE | ✓ | ✓ |
| PLACE_PLANT | ✓ | ✗ |
| CARE | ✓ | ✗ |
| INSPECT | ✓ | ✓ |

**Example:**
```gdscript
func _handle_click(cell: Vector2i) -> void:
    match [_mode, RunManager.state]:
        [InteractionMode.PLACE_PLANT, RunStateEnum.PausePhase]:
            EconomySystem.try_place_plant(cell, _selected_species)
        [InteractionMode.INSPECT, _]:
            UI.show_plant_inspect(cell)
        _:
            if OS.is_debug_build():
                push_warning("Unhandled input: mode=%s state=%s" % [_mode, RunManager.state])
```

---

#### CardEffectApplier Pattern

**Purpose:** Single entry point for between-wave card effects — stat buffs and soil terraforms.

**Components:**
- `CardSystem` — presents 3 options from `card_rng`, handles pick UI
- `CardEffectApplier` — applies selected card effect
- `RunState` — stores active stat buffs (enforces +40% cap per GDD A-15)
- `GridData` — receives soil terraform mutations

**CardPick flow:**
```
CombatPhase clears (wave 2 or 4)
  → RunManager.transition_to(CardPickPhase)
  → CardSystem.show_pick(card_rng)
  → player selects card
  → CardEffectApplier.apply(card_def)
  → RunManager.transition_to(PausePhase)
```

**Example:**
```gdscript
func apply(card: CardDef) -> void:
    match card.type:
        "stat":
            RunState.add_stat_buff(card.stat, card.value)  # enforces MAX_CARD_STACK 0.40
        "soil":
            GridData.terraform(card.target_cell, card.new_soil_type)
```

---

### Communication Patterns

**Pattern:** Hybrid EventBus + direct signals (ADR-004)

**Rules:**
- Cross-system: `EventBus.emit_run_event(RunEvent.X, payload)`
- Entity-local: direct signals on Plant/Ape nodes
- UI intent: Control signals to systems (`place_requested(cell, species_id)`)

**Mandatory system script header:**
```gdscript
## Events emitted: WAVE_STARTED, WAVE_CLEARED
## Events listened: STATE_CHANGED, PLANT_FLED
## Direct signals: none
```

---

### Entity Patterns

**Apes:** Object pool — `ApePool.acquire(role_id) -> ApeBase`; minimum FSM: `SPAWN → PATH → ACT → DEAD`

**Plants:** Grid placement — `GridData.place_plant(cell, species_id) -> PlantBase`

**Example:**
```gdscript
func spawn_ape(role_id: String, spawn_cell: Vector2i) -> ApeBase:
    var ape := _pool.acquire()
    ape.setup(ContentRegistry.get_ape(role_id), spawn_cell)
    return ape
```

---

### State Patterns

**Run-level:** RunManager state machine with `can_transition_to()` guards

**CardPick transitions:** `CombatPhase → CardPickPhase → PausePhase` (waves 2 & 4 only)

**Example:**
```gdscript
func can_transition_to(target: RunStateEnum) -> bool:
    match [_state, target]:
        [RunStateEnum.CombatPhase, RunStateEnum.CardPickPhase]:
            return _wave_index in [2, 4] and _wave_cleared
        [RunStateEnum.CardPickPhase, RunStateEnum.PausePhase]:
            return _card_applied
        _:
            return _transition_table.get([_state, target], false)
```

---

### Data Patterns

**Access:** ContentRegistry (read-only defs) + RunState (runtime) + GridData (spatial)

**Economy:** All Dogecoin via `EconomySystem` — never mutate `run_state.dogecoin` outside it

**Example:**
```gdscript
func try_place_plant(cell: Vector2i, species_id: String) -> bool:
    var cost: int = ContentRegistry.get_species(species_id).plant_cost
    if not EconomySystem.try_spend(cost):
        ui.show_toast(tr("INSUFFICIENT_DOGECOIN"))
        return false
    return GridData.place_plant(cell, species_id)
```

---

### Consistency Rules

| Pattern | Convention | Enforcement |
| ------- | ---------- | ----------- |
| Event emission | RunEvent enum on EventBus only | Script header + review |
| Grid mutation | GridData API methods only | No TileMapLayer edits in gameplay |
| Currency | `int` Dogecoin; spend via `EconomySystem.try_spend()` | Type + single wallet |
| Card effects | `CardEffectApplier.apply()` only | No direct stat mutation from UI |
| Stat stacking | Max +40% per stat enforced in applier | GDD A-15 |
| Threshold math | DissatisfactionSystem only | HR emits modifier, not threshold |
| Flee animation | `await begin_flee()` on Plant | No cross-node callback chains |
| Wave clear | Wait for `active_flee_count == 0` | WaveSpawner gate |
| Pool acquire | `ApePool.acquire/release` | No mid-wave instantiate |
| Ape states | `ApeState` enum with documented transitions | `SPAWN → PATH → ACT → DEAD` |
| Test naming | `*_test.gd` in `test/` | GdUnit4 convention |
| Script headers | Events emitted/listened documented | Mandatory on system scripts |

---

## Architecture Validation

### Validation Summary

| Check | Result | Notes |
|-------|--------|-------|
| Decision Compatibility | PASS | No conflicts |
| GDD Coverage (slice) | PASS | E9–E13 intentionally deferred |
| Pattern Completeness | PASS | 4 novel + 12 consistency rules |
| Epic Mapping | PASS | E1–E8 mapped; E9+ deferred |
| Document Completeness | PASS | All mandatory sections present |

### Coverage Report

**Systems Covered:** 14/14 slice-critical  
**Patterns Defined:** 4 novel + 12 consistency rules  
**Decisions Made:** 14 + 5 ADRs  
**Engine Version Verified:** Godot 4.7.1 (2026-07-14)

### Epic to Architecture Mapping

| Epic | Location | Status |
|------|----------|--------|
| E1 Core loop | RunManager, RunRoot, InputRouter | Slice |
| E2 Flee | DissatisfactionSystem, Flee Sequence | Slice |
| E3 Plants | `scenes/entities/plants/`, `data/species/` | Slice |
| E4 Apes | ApePool, `data/apes/` | Slice |
| E5 Economy | EconomySystem | Slice |
| E6 Cards | CardSystem, CardEffectApplier | Slice |
| E7 Win/loss | GridData structures, RunManager | Slice |
| E8 Boss | WaveSpawner | Slice (boss stub) |
| E9 Meta | SaveManager stub | Post-slice |
| E10 Weather | WaveSpawner hook | Post-slice |
| E11 Biomes | ContentRegistry expansion | Post-slice |
| E12 Full apes | ApePool + data expansion | Post-slice |
| E13 Deadly Sins | CardEffectApplier extension | Post-slice |
| E14 Polish | Audio buses, debug tools | Post-slice |

### Issues Resolved (via Party Mode)

- GridData flat storage vs per-cell Resources
- State flow: Combat → CardPick → Pause
- Flee `await` + wave-clear gate on `active_flee_count`
- CardEffectApplier with +40% stat cap (GDD A-15)
- EconomySystem single wallet; project-context sync note

### Validation Date

2026-07-26

---

## Development Environment

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Godot Engine | 4.7.1 stable | Game engine |
| Node.js | 18+ | MCP servers (GoPeak, Context7) |
| Git | latest | Version control |
| GdUnit4 | latest (via addon) | Test framework |

### AI Tooling (MCP Servers)

| MCP Server | Purpose | Install |
|------------|---------|---------|
| **GoPeak** | Scene editing, LSP diagnostics, DAP debugging, runtime inspection | `npx -y gopeak` |
| **Context7** | Current Godot 4.7 API documentation lookup | `npx -y @upstash/context7-mcp` |

**Cursor MCP config** (set `GODOT_PATH` to your install):

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["-y", "gopeak"],
      "env": {
        "GODOT_PATH": "C:/path/to/Godot_v4.7.1-stable_win64.exe",
        "GOPEAK_TOOL_PROFILE": "compact"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Setup Commands

```bash
# 1. Create Godot 4.7.1 project at leaf-me-alone/
#    Project Manager → New → Renderer: Forward Plus
#    Enable Git, plain-text .tscn/.tres

# 2. Register autoloads in project.godot:
#    EventBus, RunManager, SaveManager, ContentRegistry

# 3. Install GdUnit4 addon → addons/gdUnit4/

# 4. Create folder structure per Project Structure section

# 5. Add Windows Desktop export preset
```

### First Steps

1. Bootstrap `leaf-me-alone/` Godot project with autoloads and empty `run_root.tscn`
2. Implement `GridData` + `GridRenderer` with tropical template from seed
3. Wire RunManager state machine: PausePhase ↔ CombatPhase (E1 milestone)
4. Configure GoPeak + Context7 MCPs in Cursor for AI-assisted development
5. Add `test/fixtures/run_seed_001.json` and first GdUnit4 dissatisfaction test

---

_Generated by BMAD GDS Game Architecture Workflow v1.0_  
_Date: 2026-07-26_  
_For: nam_
