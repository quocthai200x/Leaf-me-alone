---
stepsCompleted: [1, 2, 3, 4]
status: complete
validated: 2026-07-26
inputDocuments:
  - _bmad-output/planning-artifacts/gdds/gdd-snake-rougelike-2026-07-26/gdd.md
  - _bmad-output/planning-artifacts/prds/prd-snake-rougelike-2026-07-26/prd.md
  - _bmad-output/game-architecture.md
  - _bmad-output/planning-artifacts/ux-designs/ux-snake-rougelike-2026-07-26/EXPERIENCE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-snake-rougelike-2026-07-26/DESIGN.md
  - _bmad-output/project-context.md
---

# snake-rougelike - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for snake-rougelike (Leaf Me Alone), decomposing the requirements from the GDD, UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: The player can start a new run from Main Menu that loads a procedurally generated tropical map and begins wave 1.
FR2: The system transitions automatically from Combat Phase end to Pause Phase before the next wave, except after wave 5 resolution.
FR3: Each Combat Phase lasts a fixed duration by wave number [ASSUMPTION: 5/6/7/8/10 min for waves 1–5].
FR4: The player can complete exactly five Combat Phases per run; no endless mode in v1.
FR5: The system presents a Run End summary showing win/loss, waves cleared, and Carbon Credit earned preview.
FR6: The system displays the run seed on Run End for reproducibility/debug.
FR7: The system increases a plant's dissatisfaction when it is on incompatible soil for its species.
FR8: The system increases dissatisfaction when hostile allelopathic neighbors affect a plant.
FR9: The system increases dissatisfaction each Pause Phase when required care (water/fertilize) was not applied [ASSUMPTION: +25 per unaddressed cause per Pause].
FR10: The system increases dissatisfaction when weather mismatches species preference.
FR11: The player can observe each plant's dissatisfaction state during Combat Phase via per-plant visual indicators (approaching flee vs fleeing).
FR12: The system triggers flee when dissatisfaction reaches the flee threshold [ASSUMPTION: 100 standard, 75 sensitive species, 50 when HR Ape in radius].
FR13: On flee, the plant is removed from active combat with flee feedback per PRD §6 Aesthetic (audio/visual).
FR14: After flee, the vacated tile remains occupied until depleted/barren [ASSUMPTION: GDD A-10].
FR15: PR Ape billboards increase dissatisfaction in their area of effect during Combat Phase.
FR16: HR Ape presence lowers flee threshold for affected plants within its radius.
FR17: The player can view a plant catalog during Pause Phase showing species available for the current run (based on CC unlocks).
FR18: The player can place a plant on a buildable soil tile by selecting species and target tile, spending Dogecoin at species-specific cost [ASSUMPTION: Peanut 20, Cashew 35, Teak 50].
FR19: The system rejects placement on non-buildable or occupied tiles.
FR20: The player can spend Dogecoin during Pause to water a plant, reducing dissatisfaction.
FR21: The player can spend Dogecoin during Pause to fertilize a plant, restoring HP and reducing dissatisfaction.
FR22: Cashew (Attack) reflects damage to attacking apes on hit [ASSUMPTION: GDD species table].
FR23: Peanut (Buff/Debuff) provides adjacent N-fixation buff and allelopathic slow to nearby apes [ASSUMPTION: GDD species table].
FR24: Teak (Defense) absorbs high damage as a tank unit [ASSUMPTION: GDD species table].
FR25: MVP slice includes exactly three Red Soil species: Cashew, Teak, Peanut.
FR26: The system spawns apes according to the vertical-slice wave script per addendum [ASSUMPTION: see addendum wave table].
FR27: The system spawns apes on a fixed interval with periodic burst groups [ASSUMPTION: every 15s, burst every 60s per GDD A-14].
FR28: Apes path using tile-grid navigation toward Forest Core, then nearest Root Nest, then highest-value extract tile when structures are unreachable.
FR29: Saw Ape (Worker) performs extraction/destruction behavior on target tiles and structures.
FR30: HR Ape applies flee-threshold reduction to plants in radius (FR16).
FR31: PR Ape deploys billboards that increase dissatisfaction in AoE (FR15).
FR32: The system drops Dogecoin on ape death with role-weighted amounts [ASSUMPTION: Saw 5, HR 15, PR 12].
FR33: Ape HP scales by wave number [ASSUMPTION: ×1.0 / ×1.2 / ×1.4 / ×1.6 / ×2.0 for waves 1–5].
FR34: The player can view current Dogecoin balance during Pause Phase.
FR35: The system awards Dogecoin to the player when apes are defeated in Combat Phase.
FR36: The system deducts Dogecoin when the player places plants or performs care actions.
FR37: The system prevents spending below zero Dogecoin; insufficient funds block the action.
FR38: Dogecoin balance resets to zero at run start; no carry-over between runs.
FR39: The system presents a Card Pick overlay after wave 2 and after wave 4 completion, before the next Pause Phase.
FR40: The player can select exactly 1 of 3 displayed cards per pick event (maximum 2 picks per run).
FR41: Stat cards increase ATK, DEF, grow speed, or dissatisfaction resist by 10–20% for same-clan plants [ASSUMPTION: max +40% stacked per stat per run].
FR42: Soil cards permanently change one tile or small region to a different soil type for the remainder of the run.
FR43: The MVP slice card pool excludes Sin cards and risk cards; Red-clan Deadly Sin cards deferred post-slice per GDD D-009 [NON-GOAL for MVP].
FR44: Selected card effects persist for the remainder of the current run only.
FR45: Each run includes one Forest Core and three Root Nests placed per procedural map rules.
FR46: Apes can damage Forest Core and Root Nests during Combat Phase.
FR47: The system declares run loss immediately when Forest Core HP reaches zero.
FR48: The system declares run loss immediately when all three Root Nests are destroyed.
FR49: The system declares run win when the player completes wave 5 Combat Phase and defeats the wave-5 Director boss.
FR50: Root Nests enable plant spawning and resource restoration between waves.
FR51: The system spawns a Director boss during wave 5 alongside the standard wave script.
FR52: MVP slice Director implements mission type B: triggers a mass dissatisfaction spike during the encounter [ASSUMPTION: +30 dissatisfaction to all plants within 5-tile radius for 10 s, once per encounter].
FR53: Defeating the Director is required for run win (FR49).
FR54: Director defeat awards bonus Dogecoin [ASSUMPTION: 50].
FR55: The system awards Carbon Credit at Run End based on outcome: win grants more than loss [ASSUMPTION: win 100–150 CC; loss = min(20 + (waves_cleared × 15), 80)].
FR56: The player can access Carbon Shop from Main Menu before starting a run.
FR57: The player can spend CC in Carbon Shop to permanently unlock plant clans [ASSUMPTION: first clan unlock costs 200 CC].
FR58: All unlocked plant species are available free to plant each run; no per-run unlock fee.
FR59: The system persists CC balance and unlock state locally across sessions.
FR60: MVP Carbon Shop stub accepts if CC balance displays on Run End and at least one clan unlock purchase works; full catalog UI deferred [ASSUMPTION: E9 stub per GDD epics].
FR61: The system generates a unique map layout at run start from the tropical biome template.
FR62: MVP slice maps use Red Soil as the default/only soil type except tiles modified by soil cards.
FR63: The player can pan the map view when content exceeds viewport [ASSUMPTION: mouse drag pan].
FR64: The system stores the run seed in save metadata for reproduction.
FR65: The system applies at least one weather state per run that affects plant dissatisfaction per species preference rules.
FR66: The player can view current/upcoming weather information during Pause Phase.
FR67: Weather mismatch contributes to dissatisfaction increase (FR10).
FR68: Main Menu provides PLAY action that starts a new run.
FR69: Pause Phase surfaces plant catalog, care actions, weather readout, and Dogecoin balance alongside the map view.
FR70: Combat Phase displays active TD gameplay with per-plant dissatisfaction indicators.
FR71: Card Pick overlay appears after waves 2 and 4 (FR39).
FR72: Run End screen displays outcome, CC preview, and run seed (FR5, FR6).
FR73: Carbon Shop screen accessible pre-run for clan unlocks (may stub per FR60).
FR74: Settings screen stub provides audio volume controls [v2 — full settings deferred].
FR75: Achievements screen stub displays locked achievement list; CC claim logic post-slice (E14).
FR76: During wave 1, the system presents guided prompts covering plant placement, watering/fertilizing, and dissatisfaction feedback.
FR77: Wave 1 uses a tutorial-scoped spawn script (8× Saw Ape) with pacing that allows teaching before pressure peaks [ASSUMPTION: GDD wave 1 script].

### NonFunctional Requirements

NFR1: The game sustains 60 FPS at 1920×1080 on mid-range PC hardware (GTX 1060 / RX 580 equivalent) during peak load [ASSUMPTION: 40 active plants + 30 apes, measured over 3-minute combat segment].
NFR2: Windows PC primary; mouse-first input for placement and UI.
NFR3: Godot 4.x engine per GDD technical specification [ASSUMPTION: Architecture specifies Godot 4.7.1].
NFR4: Local save for CC total, unlocks, and settings survives 100 load/save cycles without corruption or soft-lock in the Pause → Combat → Card → Pause loop.
NFR5: Run seed enables reproducible map generation for debug and playtest reporting.
NFR6: UI actions (plant placement, card pick confirm) provide feedback within 100 ms of input under NFR-1 load conditions [ASSUMPTION].
NFR7: Accessibility not in MVP scope; no WCAG target for v1 [v2 — out of MVP].

### Additional Requirements

- **Starter template:** Bootstrap Godot 4.7.1 project from scratch at `leaf-me-alone/` — no starter template (lane-based TD templates incompatible with free-placement island grid). This is Epic 1 Story 1.
- **Autoloads:** Configure exactly 4 autoloads — EventBus, RunManager, SaveManager, ContentRegistry — lean globals; gameplay systems live under RunRoot.
- **RunRoot single-scene pattern:** Entire run lifecycle in `run_root.tscn`; RunManager toggles UI layers (Pause, Combat HUD, CardPick modal, RunEnd overlay) — no scene swaps that lose grid state.
- **MainMenu separate scene:** `main_menu.tscn` separate from RunRoot; RunManager.reset() callable only from MainMenu and RunEnd states.
- **Grid canonical model:** GridData flat array Resource is authority; TileMapLayer visual syncs via GridRenderer — plants/apes mutate grid via GridData API only, never edit TileMapLayer directly.
- **Run state machine:** States MainMenu → RunStart → PausePhase ↔ CombatPhase → CardPickPhase (waves 2 & 4 only) → RunEnd; `can_transition_to()` guards; no mid-combat pause in MVP.
- **Event communication:** Hybrid EventBus (RunEvent enum) + direct entity signals + typed FleeEventData payloads.
- **Save system:** Local JSON at `user://save/meta.json` for CC balance, unlock state, settings; no cloud in v1.
- **Content loading:** ContentRegistry.load_all() at boot with embedded fallback data in `data/fallback/`; fail loud on missing critical content.
- **Ape pooling:** Object pool size 35; no mid-wave instantiate — acquire/release via ApePool.
- **Pathfinding:** AStarGrid2D with incremental per-cell updates on flee/tile change, not full grid rebuild.
- **Flee sequence (Tier 0):** Async `await plant.begin_flee()` chain; wave clear gated on `active_flee_count == 0`; GridData sets depleted flag on completion.
- **InteractionMode FSM:** InputRouter child of RunRoot implements IDLE | PLACE_PLANT | CARE | INSPECT — single input router, not autoload.
- **RNG seeding:** master_seed derives separate streams for map, cards, and wave rolls for reproducibility.
- **Economy type:** Dogecoin stored as int only — no fractional currency.
- **CardEffectApplier:** Single entry point for stat buff stacking (+10–20%, max +40% cap per stat) and soil terraforms.
- **UI architecture:** Control nodes + Godot Theme mapped to DESIGN.md tokens; UI emits intent, systems validate — no game logic in Control scripts.
- **Data pipeline:** JSON in `data/` is read-only after ContentRegistry load; runtime changes go to RunState/GridData; balance numbers not hardcoded in scripts.
- **Test framework:** GdUnit4 with golden fixture `test/fixtures/run_seed_001.json`; unit tests for dissatisfaction math, card stacking, Dogecoin, run flow integration.
- **Export:** Windows Desktop export preset for Steam target.
- **Version control:** Plain-text `.tscn`/`.tres` only; commit source + assets; ignore `.godot/`; planning artifacts never inside Godot project tree.
- **Debug tools:** F3 debug overlay in debug builds only (state HUD, flee telemetry, skip-to-wave, seed input); run seed display on RunEnd in release builds.
- **Audio:** Engine-native AudioStreamPlayer + buses; flee whoosh SFX is priority polish; FMOD deferred.
- **Steam integration:** Stub interface deferred post-slice; FR74/FR75 acceptable as stubs.
- **Naming conventions:** snake_case files, PascalCase classes, UPPER_SNAKE constants/RunEvent enum, plural snake_case groups.
- **Architectural boundaries:** Autoloads never hold entity node references; systems under RunRoot never call change_scene(); species scripts co-locate with .tscn scenes.

### UX Design Requirements

UX-DR1: Implement Godot Theme (`themes/leaf_me_alone_theme.tres`) mapping all DESIGN.md color tokens — primary, surface, dogecoin, carbon-credit, dissatisfaction, flee, soil types (red/sand/rock/mold), concrete, barren, card accents (stat/soil/risk).
UX-DR2: Implement typography semantic roles in Godot Theme — display, heading, body, label, numeric (JetBrains Mono for counters/timers), meme (sparing use only for achievement/satire popups).
UX-DR3: Main Menu hub — PLAY, Carbon Shop, Achievements, Settings, Quit; persistent Carbon Credit balance header using `{colors.carbon-credit}`; max two navigation levels from any state.
UX-DR4: Pause Phase layout — map occupies left ~65%; pause panel docked right ~35% (min 380px, max 480px); map dim overlay at 60% during prep; panel sections stack Dogecoin → Weather → Plant catalog → Care actions.
UX-DR5: Combat HUD — corner-anchored chips inside hud-margin safe zone; Dogecoin top-right, wave timer top-center, Forest Core + 3 Root Nest HP bottom-left; never cover Forest Core or active flee paths.
UX-DR6: Card Pick overlay — full-screen scrim; three panel-card columns centered (max 320px each); combat frozen, map input blocked until selection; instant click-to-commit (no undo).
UX-DR7: Reusable btn_primary component — 44px min height, rounded.md, primary/primary-hover colors, 100ms scale bounce on click.
UX-DR8: Reusable btn_secondary component — surface-alt background, 2px border, for Back/Options/stub screens.
UX-DR9: Reusable resource_chip component — Dogecoin always shows Ð icon + numeric font; Carbon Credit always shows CC label; animate tick on change, no slot-machine exaggeration.
UX-DR10: Plant catalog cell — 72px size, species portrait, Dogecoin cost, role icon (ATK/DEF/Buff/Debuff); selected state shows secondary-color ring; click enters placement mode.
UX-DR11: Care action row — Water/Fertilize buttons with cost; disabled + tooltip when insufficient Dogecoin; deduct on confirm.
UX-DR12: dissatisfaction_indicator component — in-world emoji float (😤 unhappy / 🏃 fleeing) above plant; optional meter bar under emoji at >50% dissatisfaction; never hide behind inspect panel.
UX-DR13: Structure HP chip cluster — Forest Core + 3 Root Nest icons; health bar pulses danger color below 25% HP; click pans map to structure [ASSUMPTION].
UX-DR14: Card pick tile — panel-card with top accent stripe by type (stat=blue, soil=purple); hover expands effect summary; clan icon on stat cards.
UX-DR15: Wave banner — heading typography + wave number; slides in at combat start, auto-dismiss 3s; shows incoming ape role icons when new roles debut.
UX-DR16: Run End summary — win/loss headline, waves cleared, CC earned animation, run seed in numeric font; single Continue focus; no nested navigation.
UX-DR17: Tutorial callout — warning-color pointer arrow + body text; non-blocking; dismisses when player completes prompted action.
UX-DR18: Dissatisfaction state never relies on color alone — emoji + meter shape always paired per accessibility floor.
UX-DR19: Map interaction — click+drag pans when content exceeds viewport; placement mode shows ghost preview on hover; invalid tiles red-outlined with brief tooltip ("Wrong soil" / "Occupied" / "Need Ð20"); right-click cancels placement mode.
UX-DR20: Flee feedback UI — 😤→🏃 emoji progression in-world; screen-edge flee-color vignette 200ms on mass flee/HR moment; optional resignation toast ("Teak has resigned effective immediately"); Tom & Jerry whoosh SFX (priority polish).
UX-DR21: Pause Phase state — apes absent; combat HUD hidden except structure HP summary in panel header; map pans to Forest Core on entry [ASSUMPTION].
UX-DR22: Carbon Shop UX — locked clan rows muted with CC shortfall tooltip; post-purchase unlock animation; balance updates immediately; no purchase dialog for unaffordable items.
UX-DR23: Settings stub — functional audio volume slider; Achievements stub — read-only locked achievement entries.
UX-DR24: Panel elevation style — hard offset shadow (0 8px 0 rgba(0,0,0,0.25)); thick 2–3px border outlines on all panels; sticker/chunky UI depth, not Material blur.
UX-DR25: Responsive layout — 1920×1080 design baseline; min supported 1280×720 with Pause panel narrowing to 320px min and vertical catalog scroll; ultrawide extends map, panel stays fixed width.
UX-DR26: Interactive hit targets ≥ 44×44px on all clickable elements (commercial PC baseline).
UX-DR27: Text contrast — text on surface-panel ≥ 7:1; muted text reserved for non-critical labels only.
UX-DR28: Game feel juice — plant placed soft pop + scale bounce; water/fertilize sparkle particles; ape kill Dogecoin float; dissatisfaction threshold 😤 pop + warning chirp; card selected flip + accent flash; wave start banner + percussion; core hit light screen shake + danger flash; run win confetti [ASSUMPTION].
UX-DR29: Director encounter W5 — boss banner with satirical copy; mass dissatisfaction spike telegraphed 2s before effect triggers.
UX-DR30: Run loading state — biome name + seed generation quip ("Generating island… HR not included.") [ASSUMPTION].
UX-DR31: Voice and microcopy per EXPERIENCE.md — satirical tooltips (Dogecoin, Carbon Shop), plain tutorial instructions, Run End win/loss copy; tagline only on title screen and Run End flavor, not repeated in HUD.
UX-DR32: Soil type color-coding on map tile tints consistent with DESIGN.md soil tokens for biology readability.
UX-DR33: PR billboard AoE rendered as diegetic in-world corporate billboard prop with dissatisfaction tint.
UX-DR34: Card Pick replaces Pause layer; Run End replaces all layers — no nested modals.
UX-DR35: Non-critical HUD never hides during combat — flee system requires constant mood visibility.

### FR Coverage Map

FR1: Epic 1 — Start new run from Main Menu with procedural tropical map
FR2: Epic 1 — Auto-transition Combat → Pause between waves
FR3: Epic 1 — Fixed combat duration per wave number
FR4: Epic 1 — Exactly five combat phases per run
FR5: Epic 5 — Run End summary with win/loss and CC preview
FR6: Epic 5 — Run seed displayed on Run End
FR7: Epic 3 — Dissatisfaction from incompatible soil
FR8: Epic 3 — Dissatisfaction from allelopathic neighbors
FR9: Epic 3 — Dissatisfaction from missed care each Pause
FR10: Epic 3 — Dissatisfaction from weather mismatch
FR11: Epic 3 — Per-plant dissatisfaction indicators in combat
FR12: Epic 3 — Flee at dissatisfaction threshold
FR13: Epic 3 — Flee feedback audio/visual
FR14: Epic 3 — Vacated tile remains depleted/barren
FR15: Epic 4 — PR billboard AoE dissatisfaction
FR16: Epic 4 — HR Ape lowers flee threshold in radius
FR17: Epic 2 — Plant catalog in Pause Phase
FR18: Epic 2 — Place plant on buildable tile for Dogecoin
FR19: Epic 2 — Reject invalid placement
FR20: Epic 2 — Water plant during Pause
FR21: Epic 2 — Fertilize plant during Pause
FR22: Epic 2 — Cashew reflect damage behavior
FR23: Epic 2 — Peanut buff/debuff behavior
FR24: Epic 2 — Teak tank behavior
FR25: Epic 2 — Three Red Soil species in slice
FR26: Epic 4 — Ape spawn per wave script
FR27: Epic 4 — Fixed interval + burst spawn groups
FR28: Epic 4 — A* pathing toward structures
FR29: Epic 4 — Saw Ape extraction/destruction
FR30: Epic 4 — HR flee-threshold reduction
FR31: Epic 4 — PR billboard deployment
FR32: Epic 4 — Role-weighted Dogecoin drops
FR33: Epic 4 — Ape HP scales by wave
FR34: Epic 2 — Dogecoin balance visible in Pause
FR35: Epic 4 — Dogecoin awarded on ape defeat
FR36: Epic 2 — Dogecoin deducted on spend
FR37: Epic 2 — Insufficient funds block action
FR38: Epic 2 — Dogecoin resets each run
FR39: Epic 6 — Card Pick after waves 2 and 4
FR40: Epic 6 — Select 1 of 3 cards per pick
FR41: Epic 6 — Stat card buffs same-clan plants (+40% cap)
FR42: Epic 6 — Soil card terraforms tile for run
FR43: Epic 6 — No Sin/risk cards in MVP pool
FR44: Epic 6 — Card effects persist for current run only
FR45: Epic 5 — Forest Core + 3 Root Nests on map
FR46: Epic 5 — Apes damage structures
FR47: Epic 5 — Loss when Forest Core HP = 0
FR48: Epic 5 — Loss when all Root Nests destroyed
FR49: Epic 5 — Win on wave 5 + Director defeat
FR50: Epic 5 — Root Nests enable between-wave restoration
FR51: Epic 5 — Director spawns wave 5
FR52: Epic 5 — Director mission type B dissatisfaction spike
FR53: Epic 5 — Director defeat required for win
FR54: Epic 5 — Director defeat bonus Dogecoin
FR55: Epic 7 — CC awarded at Run End by outcome
FR56: Epic 7 — Carbon Shop accessible from Main Menu
FR57: Epic 7 — Spend CC to unlock plant clans
FR58: Epic 7 — Unlocked species free to plant each run
FR59: Epic 7 — CC balance and unlocks persist locally
FR60: Epic 7 — Carbon Shop stub (CC display + one unlock)
FR61: Epic 1 — Unique map from tropical template
FR62: Epic 1 — Red Soil default in slice
FR63: Epic 1 — Mouse drag map pan
FR64: Epic 1 — Run seed stored in save metadata
FR65: Epic 3 — At least one weather state affects dissatisfaction
FR66: Epic 3 — Weather readout in Pause Phase
FR67: Epic 3 — Weather mismatch increases dissatisfaction
FR68: Epic 1 — Main Menu PLAY action
FR69: Epic 1, 2 — Pause panel surfaces catalog/care/weather/Ð
FR70: Epic 1, 3, 4 — Combat HUD with dissatisfaction indicators
FR71: Epic 6 — Card Pick overlay timing
FR72: Epic 5, 7 — Run End outcome, CC preview, seed
FR73: Epic 7 — Carbon Shop pre-run screen
FR74: Epic 7 — Settings audio volume stub
FR75: Epic 7 — Achievements locked list stub
FR76: Epic 1 — Wave 1 guided tutorial prompts
FR77: Epic 1 — Wave 1 tutorial spawn script (8× Saw)

## Epic List

### Epic 1: Launch & Run Loop Foundation
Players can open the game, start a seeded tropical run, and complete at least one Pause ↔ Combat wave cycle with greybox UI and wave-1 tutorial guidance.
**FRs covered:** FR1, FR2, FR3, FR4, FR61, FR62, FR63, FR64, FR68, FR69 (shell), FR76, FR77
**NFRs covered:** NFR2, NFR3, NFR5, NFR6 (partial)
**UX-DRs phased here:** UX-DR4 (greybox shell), UX-DR7–8 (basic buttons), UX-DR17, UX-DR19 (pan), UX-DR25–26, UX-DR30–31
**Epic 1 DoD (Party Mode):** PLAY → map → pause panel placeholder → combat timer → pause again. No full theme, no Carbon Shop, no CardPick shell.

### Epic 2: Plant Defenders — Placement, Care & Species
Players spend Dogecoin to place Cashew, Teak, and Peanut on valid Red Soil tiles and water/fertilize during Pause to maintain their defensive line.
**FRs covered:** FR17, FR18, FR19, FR20, FR21, FR22, FR23, FR24, FR25, FR34, FR36, FR37, FR38
**UX-DRs phased here:** UX-DR1–2 (theme foundation), UX-DR9–11, UX-DR19 (placement), UX-DR28 (plant/care juice), UX-DR32
**Party notes:** Tutorial plant is Peanut (Ð20). Tease dissatisfaction (😤) but no flee yet. Economy defaults: water Ð5, fertilize Ð10 in `data/economy.json`.

### Epic 3: Dissatisfaction, Weather & Flee
Players experience plants reacting to soil mismatch, neglected care, and weather — culminating in the signature 😤→🏃 flee sequence with priority whoosh SFX.
**FRs covered:** FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR65, FR66, FR67, FR70 (indicators)
**NFRs covered:** NFR1 (partial — flee perf)
**UX-DRs phased here:** UX-DR12, UX-DR18, UX-DR20, UX-DR35
**Party notes:** No hardcoded flee vignette. First real flee typically wave 2+. E14-S5 flee whoosh is P0 for slice.

### Epic 4: Corporate Ape Assault
Players defend against Saw, HR, and PR apes that spawn in waves, path toward structures, drop Dogecoin on defeat, and apply role-specific pressure.
**FRs covered:** FR15, FR16, FR26, FR27, FR28, FR29, FR30, FR31, FR32, FR33, FR35
**NFRs covered:** NFR1 (peak load profiling)
**UX-DRs phased here:** UX-DR5, UX-DR13, UX-DR15, UX-DR28 (Ð float, wave banner), UX-DR33
**Party notes:** HR flee sting syncs to 🏃 animation (max once per 5s during mass flee). Wave clear waits for `active_flee_count == 0`.

### Epic 5: Sacred Structures, Boss & Run Outcomes
Players protect Forest Core and Root Nests, survive the wave-5 Director's mass dissatisfaction spike, defeat the boss to win, and see Run End summary with CC preview and run seed.
**FRs covered:** FR5, FR6, FR45, FR46, FR47, FR48, FR49, FR50, FR51, FR52, FR53, FR54, FR72
**UX-DRs phased here:** UX-DR16, UX-DR29, UX-DR28 (core hit shake; confetti optional off by default)
**Party notes:** CC grant logic in Epic 7; Epic 5 shows CC preview only on RunEnd. Confetti `show_confetti=false` by default. Optional loss trombone P3.

### Epic 6: Roguelike Card Picks
After waves 2 and 4, players choose 1 of 3 cards to buff same-clan plant stats or permanently terraform a single soil tile for the remainder of the run.
**FRs covered:** FR39, FR40, FR41, FR42, FR43, FR44, FR71
**NFRs covered:** NFR6 (card pick responsiveness)
**UX-DRs phased here:** UX-DR6, UX-DR14, UX-DR28 (card flip), UX-DR34
**Party notes:** Stat cards before soil cards in story order. Soil terraform single tile only (no region scope).

### Epic 7: Meta Persistence & Menu Hub
Players earn Carbon Credit from run outcomes, persist unlocks locally, and spend CC in Carbon Shop to unlock plant clans; Settings and Achievements stubs complete the menu hub.
**FRs covered:** FR55, FR56, FR57, FR58, FR59, FR60, FR73, FR74, FR75
**NFRs covered:** NFR4 (100 load/save cycles)
**UX-DRs phased here:** UX-DR3, UX-DR9 (CC chip), UX-DR22–23, UX-DR24, UX-DR27, UX-DR31 (Run End copy)

### Post-MVP Epics (Deferred)
- **E10 Full Weather** — rain/sun/storm/mold roster
- **E11 Biome Expansion** — 5 biomes, 16 plants
- **E12 Full Ape Roster** — 9 roles, Green Ape, Director kits A/C
- **E13 Deadly Sins & Mutations** — Sin cards, mutation paths
- **E14 Polish Pass** — full achievements, music layers, remaining SFX

## Party Mode Decisions (2026-07-26)

Consolidated from 7 Party Mode rounds; approved on [C]:

| Decision | Resolution |
|----------|------------|
| Epic count | 7 (merged original Epic 5 + 7) |
| Epic 1 scope | Thin greybox; ContentRegistry in bootstrap; GdUnit4 in Epic 1 |
| Main Menu Epic 1 | PLAY + QUIT only; Shop/Settings/Achievements in Epic 7 |
| Flee vignette | No fake code path; tease 😤 in Epic 2, real flee Epic 3 |
| Tutorial plant | Peanut Ð20 per EXPERIENCE.md |
| Care costs | water Ð5, fertilize Ð10 `[PARTY ASSUMPTION]` in data/economy.json |
| Tutorial wave 1 | Non-blocking prompts; teaches placement + care + 😤 warning, not flee |
| UX-DR phasing | Spread across epics; no mockup parity required in Epic 1 |
| Audio buses | Master/SFX in Epic 1; whoosh Epic 3; HR sting Epic 4 |
| Confetti | Optional, off by default; not slice-required |

---

## Epic 1: Launch & Run Loop Foundation

Players can open the game, start a seeded tropical run, and complete at least one Pause ↔ Combat wave cycle with greybox UI and wave-1 tutorial guidance.

### Story 1.1: Bootstrap Godot Project and Core Autoloads

As a developer,
I want a Godot 4.7.1 project with EventBus, RunManager, SaveManager, and ContentRegistry autoloads,
So that all game systems share a consistent foundation from day one.

**Acceptance Criteria:**

**Given** no Godot project exists in `leaf-me-alone/`
**When** bootstrap completes per architecture doc
**Then** `project.godot` registers EventBus, RunManager, SaveManager, ContentRegistry autoloads
**And** plain-text `.tscn`/`.tres` only; `.godot/` in `.gitignore`
**And** Windows Desktop export preset configured
**And** audio buses Master and SFX exist (NFR3)

### Story 1.2: ContentRegistry and Fallback Data Pipeline

As a developer,
I want ContentRegistry.load_all() with embedded fallback JSON,
So that balance data loads reliably at boot without ad-hoc file parsing in gameplay code.

**Acceptance Criteria:**

**Given** bootstrap complete
**When** game boots
**Then** ContentRegistry loads from `data/` with fallback in `data/fallback/`
**And** boot fails loudly if critical fallback data is missing
**And** JSON in `data/` is treated read-only after load
**And** no species/ape balance numbers hardcoded in scripts

### Story 1.3: GridData, GridRenderer, and Seeded Tropical Map

As a player,
I want a procedurally generated tropical island when I start a run,
So that each run feels unique and reproducible via seed.

**Acceptance Criteria:**

**Given** a run starts with `master_seed`
**When** RunStart executes
**Then** GridData generates Red Soil tropical layout from seeded template (FR61, FR62)
**And** GridRenderer syncs TileMapLayer visual from GridData authority only
**And** run seed stored in RunState and save metadata (FR64, NFR5)
**And** plants/apes never mutate TileMapLayer directly

### Story 1.4: RunManager State Machine and RunRoot Scene

As a player,
I want automatic transitions between Pause and Combat phases,
So that the core TD loop works without scene swaps that lose grid state.

**Acceptance Criteria:**

**Given** RunRoot.tscn is the run lifecycle host
**When** combat timer expires
**Then** RunManager transitions CombatPhase → PausePhase (FR2)
**And** `can_transition_to()` blocks invalid transitions
**And** no mid-combat pause in MVP
**And** wave duration hook supports fixed durations by wave number (FR3)
**And** run enforces exactly five combat phases (FR4)
**And** RunManager.reset() callable only from MainMenu and RunEnd states

### Story 1.5: Main Menu and Run Start Flow

As a player,
I want to click PLAY on the Main Menu to start a new run,
So that I can jump into the game quickly.

**Acceptance Criteria:**

**Given** Main Menu displayed (`main_menu.tscn`)
**When** player clicks PLAY
**Then** game loads RunRoot and begins wave 1 (FR1, FR68)
**And** Epic 1 menu shows PLAY and QUIT only (Shop deferred to Epic 7)
**And** run loading displays biome name and quip "Generating island… HR not included." (UX-DR30)
**And** Dogecoin balance resets to zero at run start (FR38)

### Story 1.6: Greybox Pause Panel and Combat HUD Shells

As a player,
I want visible Pause and Combat UI layers during a run,
So that I always know which phase I am in.

**Acceptance Criteria:**

**Given** a run is active
**When** PausePhase is active
**Then** greybox right panel (~35% width) shows placeholder sections for catalog, care, weather, Dogecoin (FR69 shell)
**And** map dim overlay at 60% during prep (UX-DR4 greybox)
**When** CombatPhase is active
**Then** wave timer displays top-center (FR70 shell)
**And** functional VBoxContainer layout is acceptable — full DESIGN.md theme not required in Epic 1

### Story 1.7: Map Pan and InputRouter Foundation

As a player,
I want to drag the map when it exceeds the viewport,
So that I can view the full island during prep and combat.

**Acceptance Criteria:**

**Given** map content exceeds viewport
**When** player click+drags on map
**Then** camera pans smoothly (FR63, UX-DR19)
**And** InputRouter is child of RunRoot (not autoload) in IDLE interaction mode
**And** interactive hit targets are ≥ 44×44px (UX-DR26)

### Story 1.8: Tutorial Prompt System and Wave 1 Script

As a new player,
I want guided non-blocking prompts during wave 1,
So that I learn placement and care before pressure peaks.

**Acceptance Criteria:**

**Given** wave 1 starts
**When** tutorial sequence runs
**Then** prompts guide Peanut placement, watering, and dissatisfaction warning (FR76)
**And** wave 1 spawns 8× Saw Ape with tutorial pacing (FR77)
**And** prompts are non-blocking and dismiss on completed action (UX-DR17)
**And** copy uses plain instructions per EXPERIENCE.md — no flee in wave 1 tutorial
**And** tutorial plant is Peanut at Ð20 cost

### Story 1.9: GdUnit4 Integration and Run Flow Test

As a developer,
I want an automated test for Pause ↔ Combat transitions,
So that the core loop never soft-locks across future epics.

**Acceptance Criteria:**

**Given** GdUnit4 addon in `addons/gdUnit4/`
**When** `test/run_flow_test.gd` executes
**Then** PLAY → Combat timer → Pause transition passes without error
**And** `test/fixtures/run_seed_001.json` golden fixture exists
**And** test verifies RunManager.state == PAUSE_PHASE after combat ends

---

## Epic 2: Plant Defenders — Placement, Care & Species

Players spend Dogecoin to place Cashew, Teak, and Peanut on valid Red Soil tiles and water/fertilize during Pause to maintain their defensive line.

### Story 2.1: Godot Theme Foundation and Economy Data

As a player,
I want UI styled with Leaf Me Alone design tokens and economy values loaded from data,
So that the game looks cohesive and balance is tunable without code changes.

**Acceptance Criteria:**

**Given** DESIGN.md tokens defined
**When** theme loads
**Then** `themes/leaf_me_alone_theme.tres` maps primary color tokens and typography roles (UX-DR1, UX-DR2)
**And** `data/economy.json` defines water Ð5, fertilize Ð10, species placement costs (Peanut 20, Cashew 35, Teak 50)
**And** ContentRegistry exposes economy and species defs at runtime

### Story 2.2: EconomySystem and Dogecoin Wallet

As a player,
I want a Dogecoin balance that tracks spending and resets each run,
So that I make meaningful earn-vs-spend decisions during Pause.

**Acceptance Criteria:**

**Given** a new run starts
**When** EconomySystem initializes
**Then** Dogecoin balance is 0 (FR38)
**And** Dogecoin stored as int only — no fractional currency
**When** player spends on plant or care
**Then** balance deducts atomically (FR36)
**And** spending below zero is blocked (FR37)
**And** Dogecoin chip visible in Pause panel (FR34, UX-DR9)

### Story 2.3: InteractionMode FSM — Place and Care Modes

As a player,
I want to select a plant species and enter placement or care mode,
So that mouse input routes correctly during Pause Phase.

**Acceptance Criteria:**

**Given** PausePhase active
**When** player selects species from catalog
**Then** InputRouter enters PLACE_PLANT mode
**When** player selects care target
**Then** InputRouter enters CARE mode
**And** right-click cancels placement mode (UX-DR19)
**And** UI emits intent; EconomySystem validates spend — no game logic in Control scripts

### Story 2.4: Plant Catalog and Placement Validation

As a player,
I want to view available species and place them on valid Red Soil tiles,
So that I build my defensive line during Pause.

**Acceptance Criteria:**

**Given** PausePhase with unlocked species (Red clan default for slice)
**When** player opens plant catalog
**Then** catalog shows Cashew, Teak, Peanut with Ð cost and role icons (FR17, FR25, UX-DR10)
**When** player selects species and clicks valid buildable tile
**Then** plant is placed and Dogecoin deducted at species cost (FR18)
**And** placement rejected on non-buildable or occupied tiles (FR19)
**And** ghost preview on hover; invalid tiles red-outlined with tooltip (UX-DR19)
**And** plant placed soft pop SFX + scale bounce (UX-DR28)

### Story 2.5: Water and Fertilize Care Actions

As a player,
I want to water and fertilize plants during Pause,
So that I can reduce dissatisfaction and restore HP before the next wave.

**Acceptance Criteria:**

**Given** PausePhase with plants on map
**When** player selects plant and clicks Water or Fertilize
**Then** Dogecoin deducted per `data/economy.json` (FR20, FR21)
**And** insufficient funds disable button with tooltip (UX-DR11)
**And** sparkle particles play on care confirm (UX-DR28)
**And** UI feedback within 100ms of click (NFR6)

### Story 2.6: Peanut — Buff/Debuff Species

As a player,
I want Peanut to buff adjacent allies and slow nearby apes,
So that I have a cheap support/defensive option for early waves.

**Acceptance Criteria:**

**Given** Peanut placed on Red Soil
**When** combat runs
**Then** adjacent plants receive N-fixation buff (FR23)
**And** non-peanut neighbors affected by allelopathic slow on apes (FR23)
**And** Peanut costs Ð20 per placement data

### Story 2.7: Cashew — Attack Reflect Species

As a player,
I want Cashew to reflect damage to attacking apes,
So that I have an offensive deterrent plant.

**Acceptance Criteria:**

**Given** Cashew placed on Red Soil
**When** ape attacks Cashew
**Then** reflect damage applied to attacker per species JSON (FR22)
**And** Cashew costs Ð35 per placement data

### Story 2.8: Teak — Defense Tank Species

As a player,
I want Teak to absorb high damage as a tank,
So that I can block ape advance toward structures.

**Acceptance Criteria:**

**Given** Teak placed on Red Soil
**When** apes attack Teak
**Then** Teak absorbs damage per species JSON tank stats (FR24)
**And** Teak costs Ð50 per placement data

### Story 2.9: Dissatisfaction Tease (Pre-Flee Indicator)

As a player,
I want to see dissatisfaction building on neglected plants before flee exists,
So that I understand the emotional stakes of care during Epic 2.

**Acceptance Criteria:**

**Given** plant with rising dissatisfaction causes (missed care, wrong soil)
**When** dissatisfaction crosses warning threshold
**Then** 😤 emoji appears above plant (tease only — no flee trigger yet)
**And** optional meter bar at >50% dissatisfaction (UX-DR12 partial)
**And** no flee sequence executes until Epic 3
**And** emoji + meter paired — never color alone (UX-DR18)

---

## Epic 3: Dissatisfaction, Weather & Flee

Players experience plants reacting to soil mismatch, neglected care, and weather — culminating in the signature 😤→🏃 flee sequence with priority whoosh SFX.

### Story 3.1: DissatisfactionSystem and Multi-Cause Tracking

As a player,
I want dissatisfaction to rise from soil, neighbors, missed care, and weather,
So that plant mood reflects ecosystem stewardship decisions.

**Acceptance Criteria:**

**Given** DissatisfactionSystem active on RunRoot
**When** plant on incompatible soil
**Then** dissatisfaction increases (FR7)
**When** hostile allelopathic neighbor affects plant
**Then** dissatisfaction increases (FR8)
**When** Pause ends without required care applied
**Then** dissatisfaction increases +25 per unaddressed cause (FR9)
**When** weather mismatches species preference
**Then** dissatisfaction increases (FR10, FR67)

### Story 3.2: Dissatisfaction Indicators in Combat HUD

As a player,
I want per-plant dissatisfaction visible during combat,
So that I can react to mood before plants flee.

**Acceptance Criteria:**

**Given** CombatPhase active with plants on map
**When** dissatisfaction rises
**Then** per-plant 😤 indicator visible in-world (FR11, FR70, UX-DR12)
**And** meter tint uses dissatisfaction color token (UX-DR18)
**And** indicators never hidden behind inspect-only panels (UX-DR35)

### Story 3.3: Flee Threshold and HR Modifier Hook

As a player,
I want flee to trigger at species-specific thresholds modified by HR Ape presence,
So that corporate pressure accelerates desertion.

**Acceptance Criteria:**

**Given** plant dissatisfaction at threshold (100 standard, 75 sensitive)
**When** threshold reached
**Then** flee triggers (FR12)
**And** HR radius modifier lowers threshold to 50 when HR present (FR16) — hook ready for Epic 4 integration
**And** threshold math unit-tested in `test/dissatisfaction_test.gd`

### Story 3.4: Flee Sequence Pattern (Tier 0 USP)

As a player,
I want plants to flee with animated 😤→🏃 feedback and whoosh SFX,
So that desertion feels like the signature clip-worthy moment.

**Acceptance Criteria:**

**Given** flee triggered
**When** `plant.begin_flee()` executes
**Then** async sequence plays 😤→🏃 animation (FR13, UX-DR20)
**And** Tom & Jerry whoosh SFX on Combat bus (E14-S5 P0 priority)
**And** `active_flee_count` increments during sequence; wave clear gated until zero
**And** plant removed from combat after sequence completes
**And** EventBus emits PLANT_FLED with FleeEventData

### Story 3.5: Depleted Tile State After Flee

As a player,
I want vacated tiles to remain depleted after flee,
So that losing a plant has lasting map consequences.

**Acceptance Criteria:**

**Given** flee sequence completes
**When** plant removed
**Then** GridData sets tile occupied/depleted per GDD A-10 (FR14)
**And** PathfindingService incremental cell update fires
**And** tile not reusable for new placement in same run

### Story 3.6: Weather Stub — Single Weather Type

As a player,
I want at least one weather state affecting dissatisfaction with a Pause readout,
So that prep phase includes environmental planning.

**Acceptance Criteria:**

**Given** run active
**When** weather assigned at run start
**Then** at least one weather state affects dissatisfaction per species rules (FR65)
**And** Pause panel shows current/upcoming weather (FR66, UX-DR4 weather section)
**And** mismatch icon on affected species in catalog when applicable

### Story 3.7: Mass Flee Feedback and Warning Chirp

As a player,
I want audio-visual feedback when multiple plants approach flee,
So that flee crises are readable before they cascade.

**Acceptance Criteria:**

**Given** dissatisfaction crosses warning threshold
**When** indicator updates
**Then** warning chirp plays on Combat bus (UX-DR28)
**When** mass flee or HR-triggered flee occurs
**Then** screen-edge flee-color vignette 200ms (UX-DR20)
**And** optional resignation toast on first flee per wave (UX-O-04 assumption)

---

## Epic 4: Corporate Ape Assault

Players defend against Saw, HR, and PR apes that spawn in waves, path toward structures, drop Dogecoin on defeat, and apply role-specific pressure.

### Story 4.1: ApePool and PathfindingService

As a developer,
I want pooled apes with AStarGrid2D pathfinding,
So that combat scales to 30 apes without per-frame allocation spikes.

**Acceptance Criteria:**

**Given** CombatPhase active
**When** apes spawn
**Then** ApePool acquires from pool of 35 — no mid-wave instantiate
**And** apes path toward Forest Core → nearest Root Nest → extract tile priority (FR28)
**And** pathfinding updates incrementally on grid cell changes (flee/depleted tiles)
**And** peak scenario targets 60 FPS with 30 apes (NFR1 profiling baseline)

### Story 4.2: WaveSpawner — Interval, Bursts, and Wave Scripts

As a player,
I want apes to spawn on a fixed interval with periodic bursts per wave script,
So that combat pacing escalates across five waves.

**Acceptance Criteria:**

**Given** CombatPhase for wave N
**When** wave runs
**Then** apes spawn every 15s with burst every 60s (FR27)
**And** vertical-slice wave script from `data/waves/slice_waves.json` (FR26)
**And** ape HP scales ×1.0/×1.2/×1.4/×1.6/×2.0 for waves 1–5 (FR33)
**And** wave clear waits for `active_flee_count == 0`

### Story 4.3: Saw Ape Worker Behavior

As a player,
I want Saw Apes to extract and destroy tiles and structures,
So that worker apes threaten my island infrastructure.

**Acceptance Criteria:**

**Given** Saw Ape reaches target
**When** extraction behavior executes
**Then** tile/soil integrity or structure HP reduced (FR29)
**And** Saw drops Ð5 on death (FR32)

### Story 4.4: HR Ape — Flee Threshold Reduction

As a player,
I want HR Apes to lower flee thresholds for nearby plants,
So that corporate HR culture accelerates plant desertion.

**Acceptance Criteria:**

**Given** HR Ape within radius of plants
**When** dissatisfaction evaluated
**Then** flee threshold reduced to 50 for affected plants (FR16, FR30)
**And** HR drops Ð15 on death (FR32)
**When** flee triggered with HR modifier active
**Then** HR comedic sting plays synced to 🏃 animation (max once per 5s during mass flee)

### Story 4.5: PR Ape — Billboard Dissatisfaction AoE

As a player,
I want PR Apes to deploy billboards that increase dissatisfaction nearby,
So that corporate propaganda pressures my ecosystem.

**Acceptance Criteria:**

**Given** PR Ape active in combat
**When** billboard deployed
**Then** dissatisfaction increases in AoE during Combat Phase (FR15, FR31)
**And** billboard rendered as diegetic in-world prop with dissatisfaction tint (UX-DR33)
**And** PR drops Ð12 on death (FR32)

### Story 4.6: Dogecoin Earn on Ape Defeat

As a player,
I want Dogecoin when apes are defeated in combat,
So that I can fund planting and care in the next Pause.

**Acceptance Criteria:**

**Given** CombatPhase active
**When** ape defeated
**Then** Dogecoin awarded with role-weighted amount (FR35, FR32)
**And** +Ð float animation on kill (UX-DR28)
**And** combat HUD Dogecoin chip top-right updates (UX-DR5)
**And** Dogecoin never goes negative across earn/spend loop (FR37) — integration test in `test/dogecoin_test.gd`

### Story 4.7: Combat HUD — Structure HP and Wave Banner

As a player,
I want structure HP and wave start feedback during combat,
So that I can track objectives and incoming threats.

**Acceptance Criteria:**

**Given** CombatPhase active
**When** combat starts
**Then** wave banner slides in with wave number and new role icons, auto-dismiss 3s (UX-DR15)
**And** Forest Core + 3 Root Nest HP cluster bottom-left (UX-DR13)
**And** health bar pulses danger below 25% HP
**And** wave percussion hit on banner (Stings bus)
**And** HUD never covers Forest Core or active flee paths (UX-DR5)
**And** Pause Phase hides combat HUD except structure HP summary in panel header (UX-DR21)

As a player,
I want waves 2 and beyond to introduce HR and PR apes,
So that signature comedy roles appear after the tutorial wave.

**Acceptance Criteria:**

**Given** wave 2 or later
**When** wave script executes
**Then** HR and/or PR apes included per slice_waves.json
**And** first HR flee interaction observable in playtest (GDD success metric)
**And** wave banner telegraphs new role icons on debut

---

## Epic 5: Sacred Structures, Boss & Run Outcomes

Players protect Forest Core and Root Nests, survive the wave-5 Director's mass dissatisfaction spike, defeat the boss to win, and see Run End summary with CC preview and run seed.

### Story 5.1: Forest Core and Root Nest Placement

As a player,
I want Forest Core and three Root Nests on each generated map,
So that I have clear objectives to defend.

**Acceptance Criteria:**

**Given** map generated at run start
**When** structures placed per procedural rules
**Then** one Forest Core and three Root Nests exist on grid (FR45)
**And** Root Nests enable between-wave restoration hook (FR50)
**And** structure HP visible in combat HUD (Story 4.7 dependency satisfied when both epics complete)

### Story 5.2: Structure Damage and Loss Conditions

As a player,
I want immediate run loss when Core or all Nests are destroyed,
So that stakes are clear and consequences are instant.

**Acceptance Criteria:**

**Given** CombatPhase active
**When** apes damage structures (FR46)
**Then** Forest Core and Root Nest HP decrease
**When** Forest Core HP reaches zero
**Then** run loss declared immediately (FR47)
**When** all three Root Nests destroyed
**Then** run loss declared immediately (FR48)
**And** core hit triggers light screen shake + danger flash (UX-DR28)

### Story 5.3: Run End Loss Path and Seed Display

As a player,
I want a Run End screen on loss showing outcome, seed, and CC preview,
So that I can learn from failure and reproduce bugs.

**Acceptance Criteria:**

**Given** run loss triggered
**When** RunEnd overlay displays
**Then** outcome shows loss with waves cleared (FR5, FR72)
**And** run seed displayed in numeric font (FR6, UX-DR16)
**And** CC preview shown (grant calculated in Epic 7; preview only here)
**And** loss copy: "Forest Core terminated. HR sends condolences." (UX-DR31)
**And** single Continue button returns to Main Menu

### Story 5.4: Director Spawn and Mission Type B

As a player,
I want a Director boss in wave 5 with a telegraphed mass dissatisfaction spike,
So that the final wave feels distinct from waves 1–4.

**Acceptance Criteria:**

**Given** wave 5 CombatPhase
**When** Director spawns alongside standard script (FR51)
**Then** boss banner displays "Director inbound — quarterly performance review." (UX-DR29)
**And** mass dissatisfaction spike telegraphed 2s before effect
**And** spike applies +30 dissatisfaction to plants within 5-tile radius for 10s once (FR52)
**And** Director drops Ð50 bonus on defeat (FR54)

### Story 5.5: Run Win on Director Defeat

As a player,
I want to win by completing wave 5 and defeating the Director,
So that a full run has a satisfying climax.

**Acceptance Criteria:**

**Given** wave 5 combat complete and Director HP zero
**When** win condition evaluated
**Then** run win declared (FR49, FR53)
**And** RunEnd win screen displays with CC preview and seed (FR72)
**And** win copy: "The jungle survives another quarterly review." (UX-DR31)
**And** optional confetti only if `show_confetti=true` (default false — not slice-required)

### Story 5.6: RunEnd Overlay Integration with RunManager

As a developer,
I want RunEnd to replace all UI layers without nested modals,
So that terminal run states are clean and testable.

**Acceptance Criteria:**

**Given** win or loss triggered
**When** RunEnd state entered
**Then** RunEnd overlay replaces Pause, Combat HUD, and CardPick layers (UX-DR34)
**And** RunManager.reset() available from RunEnd Continue
**And** no soft-lock in Pause → Combat → CardPick → Pause loop from Epic 1 test still passes

---

## Epic 6: Roguelike Card Picks

After waves 2 and 4, players choose 1 of 3 cards to buff same-clan plant stats or permanently terraform a single soil tile for the remainder of the run.

### Story 6.1: Card Pick Trigger and Overlay UI

As a player,
I want a card pick overlay after waves 2 and 4,
So that roguelike variance shapes my run build.

**Acceptance Criteria:**

**Given** wave 2 or wave 4 clears
**When** CardPickPhase begins
**Then** overlay blocks map input until selection (FR39, FR71, UX-DR6)
**And** three panel-card columns displayed (max 320px each)
**And** instant click-to-commit — no undo (UX-DR6)
**And** UI feedback within 100ms (NFR6)

### Story 6.2: Stat Cards via CardEffectApplier

As a player,
I want stat cards that buff same-clan plants for the rest of the run,
So that I can specialize my Red Soil defenders.

**Acceptance Criteria:**

**Given** CardPickPhase with stat card options
**When** player selects one of three stat cards
**Then** exactly one card selected per pick; max 2 picks per run (FR40)
**And** CardEffectApplier applies +10–20% ATK/DEF/grow speed/diss resist to Red clan only (FR41)
**And** stacked buff capped at +40% per stat per run
**And** card flip + accent flash on select (UX-DR14, UX-DR28)
**And** Sin/risk cards excluded from pool (FR43)
**And** effects persist for current run only (FR44)
**And** `test/card_stacking_test.gd` validates cap

### Story 6.3: Soil Terraform Card — Single Tile

As a player,
I want soil cards that permanently change one tile's soil type,
So that I can reshape chokepoints for the remainder of the run.

**Acceptance Criteria:**

**Given** soil card selected
**When** player targets one tile
**Then** GridData soil type changes permanently for run (FR42)
**And** single tile only — no region scope in slice
**And** TileMapLayer syncs from GridData
**And** dissatisfaction recalculates for affected plants
**And** soil card accent stripe purple (UX-DR14)

### Story 6.4: CardPickPhase State Integration

As a developer,
I want CardPick to insert correctly between Combat and Pause,
So that the run loop never skips or double-triggers picks.

**Acceptance Criteria:**

**Given** wave 2 or 4 clears
**When** transition executes
**Then** CombatPhase → CardPickPhase → PausePhase (never back to Combat without new wave)
**And** CardPickPhase only after waves 2 and 4 — not other waves
**And** run_flow_test extended or card-specific integration test passes

---

## Epic 7: Meta Persistence & Menu Hub

Players earn Carbon Credit from run outcomes, persist unlocks locally, and spend CC in Carbon Shop to unlock plant clans; Settings and Achievements stubs complete the menu hub.

### Story 7.1: SaveManager and Local Meta Persistence

As a player,
I want Carbon Credit balance and unlock state to persist across sessions,
So that meta progression survives closing the game.

**Acceptance Criteria:**

**Given** SaveManager autoload
**When** run ends or shop purchase occurs
**Then** CC balance and unlock state written to `user://save/meta.json` (FR59)
**And** save survives 100 load/save cycles without corruption (NFR4)
**And** no cloud sync in v1
**And** SaveManager never holds in-run Dogecoin — dual economy separation enforced

### Story 7.2: Carbon Credit Grant on Run End

As a player,
I want Carbon Credit awarded based on run outcome,
So that wins feel more rewarding than losses.

**Acceptance Criteria:**

**Given** RunEnd reached
**When** outcome calculated
**Then** win grants 100–150 CC; loss grants min(20 + waves_cleared × 15, 80) (FR55)
**And** replaces CC preview-only display from Story 5.3 — grant logic lives in SaveManager/EconomySystem here only
**And** CC earned animation on RunEnd (UX-DR16)
**And** CC chip uses CC label + carbon-credit color (UX-DR9)

### Story 7.3: Carbon Shop Stub and Clan Unlock

As a player,
I want to spend CC in Carbon Shop to unlock plant clans before starting a run,
So that meta progression expands my roster.

**Acceptance Criteria:**

**Given** Main Menu with sufficient CC
**When** player opens Carbon Shop (FR56, FR73)
**Then** locked clans show CC cost; unaffordable rows muted with shortfall tooltip (FR57, UX-DR22)
**When** player purchases unlock
**Then** CC deducted; unlock persists; post-purchase animation plays (FR60)
**And** all unlocked species available free to plant each run (FR58)
**And** Red Soil clan owned by default for slice

### Story 7.4: Main Menu Hub Completion

As a player,
I want a complete Main Menu with CC header, Shop, Settings, Achievements, and Quit,
So that pre-run navigation matches the UX spec.

**Acceptance Criteria:**

**Given** Main Menu
**When** displayed
**Then** PLAY, Carbon Shop, Achievements, Settings, Quit available (UX-DR3)
**And** Carbon Credit balance persistent in header (UX-DR9)
**And** max two navigation levels from any state
**And** panel elevation style with hard shadow and thick borders (UX-DR24)
**And** text contrast ≥ 7:1 on panels (UX-DR27)

### Story 7.5: Settings and Achievements Stubs

As a player,
I want basic Settings and Achievements screens,
So that menu hub feels complete for vertical slice demos.

**Acceptance Criteria:**

**Given** Settings screen opened
**When** player adjusts sliders
**Then** Master and SFX volume functional (FR74, UX-DR23)
**Given** Achievements screen opened
**When** displayed
**Then** read-only locked achievement list shown (FR75)
**And** no CC claim logic required for slice

---

## Final Validation Summary (2026-07-26)

### 1. FR Coverage — PASS

| Check | Result |
|-------|--------|
| FRs in inventory | 77 |
| FRs mapped in coverage map | 77 |
| Orphan FRs | 0 |
| Stories referencing FRs | 48 stories across 7 epics |

### 2. Architecture Compliance — PASS

| Check | Result |
|-------|--------|
| Starter template | None — Story 1.1 bootstraps Godot 4.7.1 from scratch (correct) |
| 4 autoloads | Story 1.1 |
| RunRoot single-scene | Story 1.4 |
| GridData authority | Story 1.3 |
| ContentRegistry at boot | Story 1.2 |
| Incremental entity creation | Data/systems created per story, not upfront |

### 3. Story Quality — PASS

| Check | Result |
|-------|--------|
| Total stories | 48 |
| Forward dependencies within epics | None identified |
| Single dev agent scope | All stories sized appropriately |
| Acceptance criteria format | Given/When/Then throughout |

### 4. Epic Structure — PASS

| Check | Result |
|-------|--------|
| User-value organization | 7 epics deliver player-visible outcomes |
| Epic 5+7 merge rationale | Run outcomes + boss share RunManager terminal states |
| File churn | RunRoot touched across epics sequentially — justified by vertical slice spine |

### 5. Epic & Story Dependencies — PASS

| Epic | Depends on | Standalone value |
|------|------------|------------------|
| 1 | — | Loop + bootstrap |
| 2 | 1 | Plant placement/care |
| 3 | 1, 2 | Flee USP |
| 4 | 1, 3 | Ape combat |
| 5 | 1, 4 | Win/loss + Director |
| 6 | 1, 2, 4 | Card picks |
| 7 | 5 | Meta persistence |

### 6. UX-DR Coverage — PASS (with note)

| Check | Result |
|-------|--------|
| UX-DRs in inventory | 35 |
| Covered in stories | 35 (UX-DR21 added to Story 4.7 AC) |
| NFR coverage | NFR1–6 in stories; NFR7 explicitly deferred |

### 7. Party Mode Patches Applied

- Story 4.7: UX-DR21 Pause HUD behavior
- Story 7.2: CC grant replaces 5.3 preview-only stub

### Recommended Next Steps

1. Run **`gds-sprint-planning`** to populate `sprint-status.yaml` with 48 story keys
2. Run **`gds-create-story`** for Story 1.1 when ready to implement
3. Bootstrap Godot project at `leaf-me-alone/` per Story 1.1

**Workflow status:** Complete — ready for development.
