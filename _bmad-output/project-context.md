---
project_name: 'leaf-me-alone'
user_name: 'Flower'
date: '2026-07-26'
sections_completed:
  - technology_stack
  - engine_rules
  - performance_rules
  - organization_rules
  - testing_rules
  - platform_rules
  - anti_patterns
status: complete
rule_count: 47
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing game code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

| Layer | Value |
|-------|-------|
| **Codename** | `leaf-me-alone` |
| **Canonical title** | Leaf Me Alone |
| **Engine** | Godot **4.x** (4.4+ recommended) `[ASSUMPTION: GDD A-11]` |
| **Language** | GDScript (primary); avoid C# unless project already uses it |
| **Platform** | Windows PC (Steam), mouse-first |
| **Resolution** | 1920×1080 design baseline; scalable Control UI |
| **Scene format** | Plain-text `.tscn` / `.tres` — never binary scenes |
| **Content data** | JSON or `.tres` Resource files for cards, waves, species, ape roles |
| **Save** | Local file (meta Carbon Credit + settings); no cloud backend in v1 |
| **Authoritative design docs** | GDD, PRD, `EXPERIENCE.md`, `DESIGN.md` under `_bmad-output/planning-artifacts/` |

**Pre-code state:** No Godot project exists yet. First implementation task is project bootstrap — do not invent mechanics outside GDD/PRD.

---

## Critical Implementation Rules

### Engine-Specific Rules

- Use **Godot 4.x APIs only** — never Godot 3 syntax (`KinematicBody2D` → `CharacterBody2D`, signal connection syntax, etc.).
- Prefer **signals + autoload EventBus** over direct node references across systems (run, wave, plant, ape, card, weather, economy).
- **Run state machine** is the spine: `MainMenu → RunStart → PausePhase ↔ CombatPhase → CardPick (W2/W4) → RunEnd`. All UI and gameplay systems subscribe to state transitions — do not hardcode scene jumps.
- **Pause Phase only between waves** for MVP — no mid-combat pause (GDD loop, EXPERIENCE.md).
- UI is **Control-based** with a Godot Theme mapped to `DESIGN.md` tokens (colors, typography, spacing, component styles). Do not hardcode hex values in scripts when a theme token exists.
- On conflict between mockups and specs, **`EXPERIENCE.md` + `DESIGN.md` win** over HTML mockups.
- Use `_ready()` for node setup, `_process()`/`_physics_process()` only when per-frame work is required; dissatisfaction/flee logic should be event-driven where possible.
- **Scene instancing:** Plants, apes, and UI panels are instanced scenes; map tiles are tilemap or grid data — not one scene per tile.
- **Autoloads (minimum):** `EventBus`, `RunManager`, `SaveManager`, `ContentRegistry` (loads JSON/Resource data). Keep autoload count lean.
- **Groups:** Use Godot groups (`"plants"`, `"apes"`, `"structures"`) for batch queries — avoid `get_tree().get_nodes_in_group()` in hot paths every frame.
- Dissatisfaction flee is a **sequence** (😤 indicator → 🏃 animation → whoosh SFX → remove from combat), not an instant `queue_free()`.

### Performance Rules

- **Target:** 60 FPS sustained at 1080p on mid-range GPU (GTX 1060 class) with ~40 plants + 30 apes active `[GDD A-07]`.
- **Frame budget:** ~16.6 ms; combat wave spawner + pathfinding + dissatisfaction ticks must stay under 8 ms combined at peak.
- **Pool apes** — spawn/despawn via object pool; do not instantiate new scenes per ape every wave tick.
- **Avoid per-frame allocations** in combat — no `Array.append()` in `_process` for dissatisfaction; batch updates on timer or signal.
- **UI feedback budget:** Interactive UI actions respond within **100 ms** `[PRD NFR-6]`.
- **Dissatisfaction indicators** must remain visible during combat — never hide mood HUD behind overlays.
- Map pan (mouse drag) only when map exceeds viewport `[GDD A-05]`; use camera transform, not reparenting nodes.
- Load content data once at run start from `ContentRegistry`; do not parse JSON mid-combat.

### Code Organization Rules

```
leaf-me-alone/                  # Godot project root (to be created)
├── project.godot
├── autoload/                   # EventBus, RunManager, SaveManager, ContentRegistry
├── scenes/
│   ├── main/                   # MainMenu, CarbonShop, Settings
│   ├── run/                    # RunRoot, MapView, CombatHUD, PausePanel, CardPick, RunEnd
│   ├── entities/               # Plant, Ape, Structure (ForestCore, RootNest)
│   └── ui/                     # Reusable Control components (buttons, chips, panels)
├── scripts/
│   ├── systems/                # WaveSpawner, DissatisfactionSystem, EconomySystem, CardSystem
│   ├── data/                   # Resource classes, JSON loaders
│   └── utils/                  # Grid helpers, pooling, math
├── resources/                  # .tres species, card, wave definitions
├── data/                       # JSON content (cards, waves, balance tables)
├── assets/                     # Art, audio, fonts (imported)
└── themes/                     # Godot Theme from DESIGN.md tokens
```

- **Naming:** `snake_case` for files/folders; `PascalCase` for class names (`PlantCashew`, `ApeHR`); scene files match root node (`plant_cashew.tscn`).
- **Scripts co-locate** with scenes unless shared across 3+ scenes (then move to `scripts/systems/`).
- Balance numbers tagged `[ASSUMPTION]` in GDD/PRD are defaults — store in `data/` JSON, not magic numbers in scripts.
- Planning artifacts stay in `_bmad-output/` — never mix design docs into the Godot project tree.

### Testing Rules

- No test framework exists yet. When added, prefer **GdUnit4** or Godot's built-in `GUT`.
- **Unit test** pure logic: dissatisfaction threshold math, card effect stacking (+10–20% per card, max +40% stacked `[GDD A-15]`), Dogecoin earn/spend, run seed reproducibility.
- **Integration test** state transitions: Pause → Combat → CardPick → Pause loop must never soft-lock `[GDD success metric]`.
- **Manual playtest checklist** for vertical slice: flee moment visible, HR threshold reduction, PR billboard AoE, run seed on Run End.
- Save/load: meta progression must survive 100 load cycles without corruption `[GDD technical metric]`.
- Debug: expose **run seed on Run End** `[FR-6]` and support seed input for reproducible bug reports.

### Platform & Build Rules

- **Primary platform:** Windows PC via Steam; export preset `Windows Desktop`.
- **Input:** Mouse-only for v1 — left-click select/place, drag to pan map. No gamepad, no touch, no mobile export.
- **No platform `#ifdef` blocks** until a second platform is scoped — keep code PC-native.
- **English-only UI** for EA `[EXPERIENCE.md ASSUMPTION]`; use `tr()` for strings anyway to avoid refactor pain later.
- **Local save path:** `user://save/meta.json` — never write to `res://`.
- Steam integration deferred until post-slice; stub achievements/settings screens are acceptable `[FR-74, FR-75]`.

### Critical Don't-Miss Rules

**Scope — do NOT implement in v1/MVP:**
- In-run shop, plant sell/refund, difficulty selector, endless mode, multiplayer
- Mid-combat pause, gamepad/mobile support, Green Ape protest mechanics (post-MVP)
- 7 Deadly Sins, full 9-ape roster, multi-biome (slice = tropical + Red Soil + HR/PR only)

**Game logic gotchas:**
- **Dual economy:** Dogecoin resets each run; Carbon Credit persists meta — never mix currencies or save paths.
- **Loss conditions:** Forest Core HP = 0 **OR** all 3 Root Nests destroyed — both must be checked.
- **Card picks** only after waves **2 and 4** — not every wave.
- **Plants cannot be sold** once placed `[GDD A-10]`; flee vacates tile as barren/depleted, not reusable.
- **HR Ape** lowers flee threshold (50 vs 100), not just adds dissatisfaction — implement as threshold modifier.
- **Stat cards** buff same-clan plants only; soil cards terraform permanently for remainder of run.
- **Wave durations** fixed by wave number `[ASSUMPTION: 5/6/7/8/10 min]` — no dynamic rubber-banding `[GDD A-08]`.
- **Run length:** exactly 5 combat phases; wave 5 includes Director boss.

**Architecture anti-patterns:**
- Do not couple plant behavior directly to UI nodes — use signals through EventBus.
- Do not store run state in autoloads that survive scene changes without explicit reset on new run.
- Do not hardcode species/ape stats in scripts — use `data/` + `ContentRegistry`.
- Do not use `@export` for balance numbers that designers will tune — use Resource/JSON.

**UX non-negotiables:**
- Flee feedback (emoji progression + whoosh SFX) is a **priority polish item**, not optional fluff.
- Carbon Credit balance visible in Main Menu header at all times.
- Max **two navigation levels** from any run state `[EXPERIENCE.md IA]`.

---

## Usage Guidelines

**For AI Agents:**

- Read this file before implementing any game code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- GDD/PRD/EXPERIENCE/DESIGN override this file on design questions; this file overrides agent defaults on implementation questions
- Update this file if new patterns emerge during development

**For Humans:**

- Keep this file lean and focused on agent needs
- Update when Godot project is bootstrapped or technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

Last Updated: 2026-07-26
