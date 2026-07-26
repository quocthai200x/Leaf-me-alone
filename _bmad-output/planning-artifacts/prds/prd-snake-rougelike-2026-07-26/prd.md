---
title: Leaf Me Alone
created: 2026-07-26
updated: 2026-07-26
version: 1.0
---

# PRD: Leaf Me Alone

## 0. Document Purpose

This PRD formalizes functional and non-functional requirements for **Leaf Me Alone** (codename: `snake-rougelike`) to guide Godot implementation, epic/story breakdown, and playtest acceptance. It builds on the Game Design Document at `_bmad-output/planning-artifacts/gdds/gdd-snake-rougelike-2026-07-26/gdd.md` — mechanics, art direction, and progression design live there; this document does not relitigate those decisions.

**Primary audience:** nam (solo/small-team builder) and future collaborators who need testable requirements before writing code or tickets.

**Structure:** Glossary-anchored vocabulary; features grouped with globally numbered FRs; cross-cutting NFRs in §5; assumptions tagged inline and indexed in §13.

**Design pillars** (from GDD/brainstorm): (1) plants have emotions, (2) satire with bite, (3) biology interlocks with soil/weather, (4) short runs, high variance.

**Related artifacts:**
- GDD v0.1 — design authority for mechanics, balance intent, and content roster
- Brainstorming session 2026-07-26 — origin context and design pillars
- GDD epics (E1–E14) — implementation sequencing reference

---

## 1. Vision

**Leaf Me Alone** is a top-down ecosystem tower-defense roguelike. The player commands a jungle island against corporate apes who arrive to "civilize" the land. Plants are living defenders with moods — when dissatisfied, they uproot and flee. The central theme is **nature vs progress** with moral ambiguity: neither side is righteous; only the strong survive.

Each run is a fixed five-wave session (~25–50 minutes). Between waves, the player enters a **Pause Phase** to plant, water, fertilize, and read weather — then fights a combat wave where apes path toward sacred structures. Roguelike card picks after waves 2 and 4 add variance. Meta progression uses **Carbon Credit** to unlock plant clans between runs.

The product differentiator is the **dissatisfaction flee system**: tower-defense units can desert when soil, neighbors, care, weather, or ape pressure make them unhappy. This turns TD into ecosystem stewardship with satirical bite (Dogecoin economy, corporate ape roles, carbon-market meta).

> *"Who's righteous? No one — only the strong survive."*

Post-MVP, Green Ape protest mechanics mirror plant flee as dual-side satire (GDD USP #2); MVP focuses on plant flee + corporate ape pressure.

---

## 2. Target User

### 2.1 Primary Persona

**Alex — The Systems Tinkerer** `[ILLUSTRATIVE]`

Alex plays short roguelike sessions on PC (30–60 min blocks). They enjoy humor and satire without sacrificing mechanical depth — soil types, weather, and unit mood interacting in ways they can optimize over repeated runs. They share clip-worthy moments (plants fleeing en masse, absurd corporate ape behavior) but stay for mastery: learning dissatisfaction thresholds, care economy, and card synergies.

### 2.2 Jobs To Be Done

- **Functional:** Survive five escalating waves by placing and caring for plants that defend sacred structures against ape incursions.
- **Emotional:** Feel the tension of being both strategist and caretaker — plants are allies with agency, not disposable towers; feel nature fighting back when the ecosystem deserts or resists on its own terms.
- **Social:** Discover and share memorable flee moments and satirical corporate-ape interactions.
- **Contextual:** Pick up a run quickly on PC with mouse-driven placement; no complex pre-run loadout or difficulty tuning required for v1.

### 2.3 Non-Users (v1)

- Mobile or gamepad-first players — PC mouse placement only in v1.
- Players seeking narrative campaigns or multiplayer co-op.
- Players who want deep pre-run buildcrafting, difficulty sliders, or in-run shops.

### 2.4 Key User Journeys

- **UJ-1 — First Run (Tutorial Wave):** New player launches from Main Menu, completes guided wave 1, learns Pause placement and basic care, experiences first dissatisfaction signal.
- **UJ-2 — Full Run Loop:** Player completes waves 1–5 with Pause prep, card picks after waves 2 and 4, Dogecoin earn/spend, and a win or loss outcome with Carbon Credit summary.
- **UJ-3 — Meta Unlock:** Player spends accumulated Carbon Credit in Carbon Shop to unlock a new plant clan, then starts a subsequent run with expanded roster.
- **UJ-4 — Flee Crisis Recovery:** Mid-run, multiple plants become dissatisfied; player spends Pause phase and Dogecoin on care to prevent mass flee before the next wave.
- **UJ-5 — Boss Finish:** Player survives wave 5 combat and defeats the Director boss to secure a run win.

---

## 3. Glossary

- **Ape** — Enemy unit representing a corporate role; paths toward structures and applies role-specific effects (extraction, dissatisfaction, tile debuffs).
- **Carbon Credit (CC)** — Meta currency earned from run outcomes and achievements; spent in Carbon Shop to unlock plant clans. Persists across runs.
- **Carbon Shop** — Pre-run screen where the player spends CC on permanent unlocks.
- **Card Pick** — Roguelike choice moment after waves 2 and 4; player selects 1 of 3 offered cards.
- **Combat Phase** — Active tower-defense segment of a wave; apes spawn and path toward targets until the wave timer ends or win/loss triggers.
- **Director** — Wave-5 boss ape with a mission type (A, B, or C) that shapes the final encounter.
- **Dissatisfaction** — Per-plant mood meter; rises from environmental and ape pressures; at threshold, triggers flee.
- **Dogecoin** — In-run currency earned from ape kills; spent on planting and care during Pause. Resets each run.
- **Flee** — Dissatisfied plant uproots, runs off-map, and is removed from combat.
- **Forest Core** — Central sacred tree structure; run ends in loss if its HP reaches zero.
- **Pause Phase** — Between-wave preparation state: placement, care, weather readout, economy review.
- **Plant** — Player-placed defender with role (Attack, Defense, Buff, Debuff) and soil preference.
- **Root Nest** — Secondary structure (three per map); losing all Root Nests ends the run in loss.
- **Run** — Single play session from Main Menu start through win, loss, or abandon; five waves fixed.
- **Soil Type** — Tile classification (Red, Sand, Rock, Mold in full game; Red only in MVP slice) determining plant compatibility.
- **Wave** — One Combat Phase segment within a run; five waves total, escalating duration and spawn composition.
- **Allelopathic** — Plant-to-plant hostility (e.g., Peanut debuff) that increases neighbor dissatisfaction or applies combat debuffs.
- **Buildable Tile** — Soil tile eligible for plant placement; excludes non-buildable zones (e.g., Lawyer-permit blocked tiles in full game).
- **Plant Clan** — Unlock group purchased in Carbon Shop; stat cards apply to same-clan plants only.
- **Stat Card** — Card Pick subtype that buffs ATK, DEF, grow speed, or dissatisfaction resist for same-clan plants.
- **Soil Card** — Card Pick subtype that permanently terraforms one tile or small region for the remainder of the run.

---

## 4. Features

### 4.1 Core Run Loop (Pause ↔ Combat)

**Description:** Each run follows a repeating loop: Pause Phase preparation → Combat Phase wave → repeat for five waves. Card picks interrupt the loop after waves 2 and 4. Run ends at win (wave 5 Director defeated) or loss (Forest Core or all Root Nests destroyed). Realizes UJ-1, UJ-2, UJ-5.

**Functional Requirements:**
- **FR-1** — The player can start a new run from Main Menu that loads a procedurally generated tropical map and begins wave 1.
- **FR-2** — The system transitions automatically from Combat Phase end to Pause Phase before the next wave, except after wave 5 resolution.
- **FR-3** — Each Combat Phase lasts a fixed duration by wave number `[ASSUMPTION: 5/6/7/8/10 min for waves 1–5]`.
- **FR-4** — The player can complete exactly five Combat Phases per run; no endless mode in v1.
- **FR-5** — The system presents a Run End summary showing win/loss, waves cleared, and Carbon Credit earned preview.
- **FR-6** — The system displays the run seed on Run End for reproducibility/debug.

**Notes:** Wave spawn tables and durations defined in GDD; balance numbers tagged `[ASSUMPTION]` pending playtest.

---

### 4.2 Dissatisfaction and Flee

**Description:** Each plant tracks dissatisfaction from wrong soil, allelopathic neighbors, lack of care, weather mismatch, and ape-induced pressure (PR billboards, HR flee-threshold reduction). When dissatisfaction reaches the flee threshold, the plant performs a flee sequence (visual emoji progression, whoosh SFX, removal from combat). This is the core differentiator — realizes UJ-4.

**Functional Requirements:**
- **FR-7** — The system increases a plant's dissatisfaction when it is on incompatible soil for its species.
- **FR-8** — The system increases dissatisfaction when hostile allelopathic neighbors affect a plant.
- **FR-9** — The system increases dissatisfaction each Pause Phase when required care (water/fertilize) was not applied `[ASSUMPTION: +25 per unaddressed cause per Pause]`.
- **FR-10** — The system increases dissatisfaction when weather mismatches species preference.
- **FR-11** — The player can observe each plant's dissatisfaction state during Combat Phase via per-plant visual indicators (approaching flee vs fleeing).
- **FR-12** — The system triggers flee when dissatisfaction reaches the flee threshold `[ASSUMPTION: 100 standard, 75 sensitive species, 50 when HR Ape in radius]`.
- **FR-13** — On flee, the plant is removed from active combat with flee feedback per §6 Aesthetic (audio/visual).
- **FR-14** — After flee, the vacated tile remains occupied until depleted/barren `[ASSUMPTION: GDD A-10]`.
- **FR-15** — PR Ape billboards increase dissatisfaction in their area of effect during Combat Phase.
- **FR-16** — HR Ape presence lowers flee threshold for affected plants within its radius.

**Feature-specific NFRs:**
- Flee whoosh SFX is priority polish for MVP slice (GDD E14-S5).

---

### 4.3 Plant Placement and Care

**Description:** During Pause Phase, the player spends Dogecoin to place unlocked plant species on buildable soil tiles and to perform care actions that reduce dissatisfaction and restore HP. Free tile placement on valid soil; no sell/refund mechanic in v1. Realizes UJ-1, UJ-2, UJ-4.

**Functional Requirements:**
- **FR-17** — The player can view a plant catalog during Pause Phase showing species available for the current run (based on CC unlocks).
- **FR-18** — The player can place a plant on a buildable soil tile by selecting species and target tile, spending Dogecoin at species-specific cost `[ASSUMPTION: Peanut 20, Cashew 35, Teak 50]`.
- **FR-19** — The system rejects placement on non-buildable or occupied tiles.
- **FR-20** — The player can spend Dogecoin during Pause to water a plant, reducing dissatisfaction.
- **FR-21** — The player can spend Dogecoin during Pause to fertilize a plant, restoring HP and reducing dissatisfaction.
- **FR-22** — Cashew (Attack) reflects damage to attacking apes on hit `[ASSUMPTION: GDD species table]`.
- **FR-23** — Peanut (Buff/Debuff) provides adjacent N-fixation buff and allelopathic slow to nearby apes `[ASSUMPTION: GDD species table]`.
- **FR-24** — Teak (Defense) absorbs high damage as a tank unit `[ASSUMPTION: GDD species table]`.
- **FR-25** — MVP slice includes exactly three Red Soil species: Cashew, Teak, Peanut.

---

### 4.4 Ape Encounters and Pathing

**Description:** Apes spawn during Combat Phase per wave script, path toward priority targets (Forest Core > nearest Root Nest > high-value extract tile), and apply role-specific behaviors. MVP slice includes Saw Ape (Worker), HR Ape, and PR Ape. Realizes UJ-2, UJ-4, UJ-5.

**Functional Requirements:**
- **FR-26** — The system spawns apes according to the vertical-slice wave script per addendum `[ASSUMPTION: see addendum wave table]`.
- **FR-27** — The system spawns apes on a fixed interval with periodic burst groups `[ASSUMPTION: every 15s, burst every 60s per GDD A-14]`.
- **FR-28** — Apes path using tile-grid navigation toward Forest Core, then nearest Root Nest, then highest-value extract tile when structures are unreachable.
- **FR-29** — Saw Ape (Worker) performs extraction/destruction behavior on target tiles and structures.
- **FR-30** — HR Ape applies flee-threshold reduction to plants in radius (FR-16).
- **FR-31** — PR Ape deploys billboards that increase dissatisfaction in AoE (FR-15).
- **FR-32** — The system drops Dogecoin on ape death with role-weighted amounts `[ASSUMPTION: Saw 5, HR 15, PR 12]`.
- **FR-33** — Ape HP scales by wave number `[ASSUMPTION: ×1.0 / ×1.2 / ×1.4 / ×1.6 / ×2.0 for waves 1–5]`.

---

### 4.5 Dogecoin Economy (In-Run)

**Description:** Dogecoin is earned from combat and spent during Pause on planting and care. No in-run shop, sell, or refund. Resets each run. Realizes UJ-2.

**Functional Requirements:**
- **FR-34** — The player can view current Dogecoin balance during Pause Phase.
- **FR-35** — The system awards Dogecoin to the player when apes are defeated in Combat Phase.
- **FR-36** — The system deducts Dogecoin when the player places plants or performs care actions.
- **FR-37** — The system prevents spending below zero Dogecoin; insufficient funds block the action.
- **FR-38** — Dogecoin balance resets to zero at run start; no carry-over between runs.

---

### 4.6 Roguelike Card Picks

**Description:** After waves 2 and 4, the player picks 1 of 3 offered cards. MVP slice pool includes stat buff cards and soil terraforming cards; Sin and risk cards excluded. Buffs cap at +40% stacked per stat per run and apply to same-clan plants only. Realizes UJ-2.

**Functional Requirements:**
- **FR-39** — The system presents a Card Pick overlay after wave 2 and after wave 4 completion, before the next Pause Phase.
- **FR-40** — The player can select exactly 1 of 3 displayed cards per pick event (maximum 2 picks per run).
- **FR-41** — Stat cards increase ATK, DEF, grow speed, or dissatisfaction resist by 10–20% for same-clan plants `[ASSUMPTION: max +40% stacked per stat per run]`.
- **FR-42** — Soil cards permanently change one tile or small region to a different soil type for the remainder of the run.
- **FR-43** — The MVP slice card pool excludes Sin cards and risk cards; Red-clan Deadly Sin cards deferred post-slice per GDD D-009 `[NON-GOAL for MVP]`.
- **FR-44** — Selected card effects persist for the remainder of the current run only.

---

### 4.7 Strongholds, Win, and Loss

**Description:** Forest Core and three Root Nests define run survival. Win requires surviving all five waves and defeating the wave-5 Director. Loss triggers on Core destruction or all Nests lost. Realizes UJ-2, UJ-5.

**Functional Requirements:**
- **FR-45** — Each run includes one Forest Core and three Root Nests placed per procedural map rules.
- **FR-46** — Apes can damage Forest Core and Root Nests during Combat Phase.
- **FR-47** — The system declares run loss immediately when Forest Core HP reaches zero.
- **FR-48** — The system declares run loss immediately when all three Root Nests are destroyed.
- **FR-49** — The system declares run win when the player completes wave 5 Combat Phase and defeats the wave-5 Director boss.
- **FR-50** — Root Nests enable plant spawning and resource restoration between waves.

---

### 4.8 Wave-5 Director Boss

**Description:** Wave 5 includes a Director boss — one of three mission types in full game; MVP slice uses mission type B (mass dissatisfaction spike) with a placeholder Director identity. Realizes UJ-5.

**Functional Requirements:**
- **FR-51** — The system spawns a Director boss during wave 5 alongside the standard wave script.
- **FR-52** — MVP slice Director implements mission type B: triggers a mass dissatisfaction spike during the encounter `[ASSUMPTION: +30 dissatisfaction to all plants within 5-tile radius for 10 s, once per encounter]`.
- **FR-53** — Defeating the Director is required for run win (FR-49).
- **FR-54** — Director defeat awards bonus Dogecoin `[ASSUMPTION: 50]`.

**Notes:** `[NOTE FOR PM]` Director identities and kits for mission types A/B/C deferred (GDD O-006).

---

### 4.9 Meta Progression (Carbon Credit)

**Description:** Carbon Credit persists across runs. Earned primarily from run outcomes (win > loss) and achievements in full game. Spent in Carbon Shop to unlock plant clans. No pre-run buffs or difficulty modifiers. Realizes UJ-3.

**Functional Requirements:**
- **FR-55** — The system awards Carbon Credit at Run End based on outcome: win grants more than loss `[ASSUMPTION: win 100–150 CC; loss = min(20 + (waves_cleared × 15), 80)]`.
- **FR-56** — The player can access Carbon Shop from Main Menu before starting a run.
- **FR-57** — The player can spend CC in Carbon Shop to permanently unlock plant clans `[ASSUMPTION: first clan unlock costs 200 CC]`.
- **FR-58** — All unlocked plant species are available free to plant each run; no per-run unlock fee.
- **FR-59** — The system persists CC balance and unlock state locally across sessions.
- **FR-60** — MVP Carbon Shop stub accepts if CC balance displays on Run End and at least one clan unlock purchase works; full catalog UI deferred `[ASSUMPTION: E9 stub per GDD epics]`.

**Notes:** Cosmetic skins deferred `[v2 — out of MVP]`. Achievements with CC bonuses are full-game scope (E14); not required for slice acceptance.

---

### 4.10 Procedural Map Generation

**Description:** Each run generates a random tropical island map from a biome template. Top-down view; free placement on buildable tiles. Realizes UJ-1, UJ-2.

**Functional Requirements:**
- **FR-61** — The system generates a unique map layout at run start from the tropical biome template.
- **FR-62** — MVP slice maps use Red Soil as the default/only soil type except tiles modified by soil cards.
- **FR-63** — The player can pan the map view when content exceeds viewport `[ASSUMPTION: mouse drag pan]`.
- **FR-64** — The system stores the run seed in save metadata for reproduction.

---

### 4.11 Weather (MVP Minimal)

**Description:** Weather affects dissatisfaction and is announced/read during Pause. Full weather roster (rain, harsh sun, storm, mold/fog) is post-slice; MVP requires at least one weather type functional. Realizes UJ-2, UJ-4.

**Functional Requirements:**
- **FR-65** — The system applies at least one weather state per run that affects plant dissatisfaction per species preference rules.
- **FR-66** — The player can view current/upcoming weather information during Pause Phase.
- **FR-67** — Weather mismatch contributes to dissatisfaction increase (FR-10).

**Notes:** Mold weather rules for mushroom allies vs sickened plants remain open (GDD O-008).

---

### 4.12 UI Surfaces

**Description:** Required screens and states for MVP slice navigation. Realizes UJ-1 through UJ-5.

**Functional Requirements:**
- **FR-68** — Main Menu provides PLAY action that starts a new run.
- **FR-69** — Pause Phase surfaces plant catalog, care actions, weather readout, and Dogecoin balance alongside the map view.
- **FR-70** — Combat Phase displays active TD gameplay with per-plant dissatisfaction indicators.
- **FR-71** — Card Pick overlay appears after waves 2 and 4 (FR-39).
- **FR-72** — Run End screen displays outcome, CC preview, and run seed (FR-5, FR-6).
- **FR-73** — Carbon Shop screen accessible pre-run for clan unlocks (may stub per FR-60).
- **FR-74** — Settings screen stub provides audio volume controls `[v2 — full settings deferred]`.
- **FR-75** — Achievements screen stub displays locked achievement list; CC claim logic post-slice (E14).

---

### 4.13 First-Run Tutorial

**Description:** Wave 1 teaches placement, care, and dissatisfaction feedback through guided prompts — realizes UJ-1.

**Functional Requirements:**
- **FR-76** — During wave 1, the system presents guided prompts covering plant placement, watering/fertilizing, and dissatisfaction feedback.
- **FR-77** — Wave 1 uses a tutorial-scoped spawn script (8× Saw Ape) with pacing that allows teaching before pressure peaks `[ASSUMPTION: GDD wave 1 script]`.

---

## 5. Non-Functional Requirements (Cross-Cutting)

- **NFR-1 Performance:** The game sustains 60 FPS at 1920×1080 on mid-range PC hardware (GTX 1060 / RX 580 equivalent) during peak load `[ASSUMPTION: 40 active plants + 30 apes, measured over 3-minute combat segment]`.
- **NFR-2 Platform:** Windows PC primary; mouse-first input for placement and UI.
- **NFR-3 Implementation constraint:** Godot 4.x engine per GDD technical specification `[ASSUMPTION]`.
- **NFR-4 Save integrity:** Local save for CC total, unlocks, and settings survives 100 load/save cycles without corruption or soft-lock in the Pause → Combat → Card → Pause loop.
- **NFR-5 Determinism:** Run seed enables reproducible map generation for debug and playtest reporting.
- **NFR-6 Responsiveness:** UI actions (plant placement, card pick confirm) provide feedback within 100 ms of input under NFR-1 load conditions `[ASSUMPTION]`.
- **NFR-7 Accessibility:** Not in MVP scope; `[v2 — out of MVP]` — no WCAG target for v1.

---

## 6. Aesthetic and Tone

- **Visual:** Chibi corporate apes (vests, briefcases, billboards) vs semi-chibi botanical plant silhouettes `[ASSUMPTION: plant art style pending O-005]`.
- **UI:** Pause panel surfaces catalog, care, weather, economy; dissatisfaction indicators on plants; tagline usable as copy/voice reference.
- **Audio:** Lo-fi forest rain during Pause; escalating percussion during Combat; priority flee whoosh SFX (Tom & Jerry style); comedic sting when HR Ape triggers flee `[ASSUMPTION: GDD audio spec]`.
- **Anti-reference:** Grim realistic warfare TD; earnest eco-propaganda without satirical edge.

Tone must stay **cute + cynical** — humor from corporate absurdity, stakes from flee-driven loss of defense.

---

## 7. Platform

| Attribute | v1 MVP | v2+ |
|-----------|--------|-----|
| Platform | Windows PC | Additional PC stores |
| Input | Mouse click (placement, UI) | Optional keyboard pause/speed `[ASSUMPTION]` |
| Display | 1920×1080 baseline, scalable UI | — |
| Multiplayer | No | No current plan |
| Mobile / Gamepad | No | `[NON-GOAL for MVP]` |

---

## 8. Monetization

`[ASSUMPTION: premium single-purchase or free demo — not specified in GDD]`

- **v1 MVP:** No in-app purchases, ads, or live-service monetization required for vertical slice validation.
- **Post-MVP:** Cosmetic skins and potential marketplace noted in GDD as deferred; requires separate business decision before PRD update.

`[NOTE FOR PM]` Confirm monetization model before store submission requirements are added to this PRD.

---

## 9. Non-Goals (Explicit)

- In-run shop, sell/refund of plants, or player-activated emergency abilities in v1.
- Difficulty selector, pre-run buffs, or complex loadout screens.
- Narrative campaign mode or multiplayer.
- Mobile, gamepad-primary, or VR support.
- Endless/survival mode beyond five waves.
- Full 16-plant / 9-ape / 3-Director / 5-biome roster in MVP slice.
- Deadly Sins, Sin cards, and risk cards in MVP slice card pool.
- Green Ape ally, remaining six ape roles, and four wildcard plants in MVP slice.
- Cloud save / cross-device sync.
- Localization beyond English for MVP slice.
- Formal accessibility compliance (WCAG) for v1.

---

## 10. MVP Scope

### 10.1 In Scope

- Full Pause ↔ Combat loop for 5 waves with scripted spawns — **3 ape roles (Saw, HR, PR)** per GDD wave script (note: GDD asset table lists 2 roles; wave script is authoritative).
- Dissatisfaction, care, and flee system with emoji feedback and priority whoosh SFX.
- Three Red Soil plants: Cashew, Teak, Peanut.
- Dogecoin earn/spend loop.
- Card picks after waves 2 and 4 (stat + soil cards only).
- Forest Core + 3 Root Nests win/loss.
- Wave-5 Director placeholder (mission type B).
- Procedural tropical map (Red Soil default).
- Minimum one weather type affecting dissatisfaction.
- Guided tutorial wave 1 (FR-76, FR-77).
- UI: Main Menu, Pause, Card Pick, Run End, Settings/Achievements stubs; Carbon Shop stub acceptable.
- Local CC persistence (earn + display; shop may stub per FR-60).
- Epics E1–E7, E6 minimal, E8 placeholder, E14-S5 flee SFX per GDD epic priorities.

### 10.2 Out of Scope for MVP

| Item | Reason |
|------|--------|
| In-run shop, difficulty modes, pre-run buffs | Explicit GDD cut (D-011) |
| Skins and cosmetics | Deferred until core loop fun |
| Sin/risk/Deadly Sin cards | Balance + scope; Red clan Sins post-slice |
| Green Ape + 6 other ape roles | Content expansion (E12) |
| 4 additional biomes + 13 more plants | Content expansion (E11) |
| Full achievement system | E14; CC from achievements post-slice |
| Full weather roster | E10; 1 type sufficient for slice |
| Director identities A/C kits | O-006 open |
| Analytics/telemetry event schema | `[NOTE FOR PM]` add before public playtest |

---

## 11. Success Metrics

**Primary**
- **Vertical slice playability** — Internal playtesters complete at least one full 5-wave run (win or loss) without soft-lock or crash. Target: 100% of playtest sessions in first playtest cohort.
- **Flee system comprehension** — ≥70% of first-time playtesters correctly identify why a plant fled when prompted post-run `[ASSUMPTION: survey N≥5]`.
- **Flee memorability** — ≥70% of playtesters rate at least one flee moment as funny or memorable (GDD gameplay metric).
- **Run completion rate** — ≥50% of playtest runs reach wave 3+ before first playtest balance pass `[ASSUMPTION: pre-tuning baseline]`.
- **Session length** — Median run duration 30–40 minutes `[ASSUMPTION: GDD target]`.

**Secondary**
- **Retry intent** — ≥50% of playtesters start a second run within the same session (GDD target).
- **HR + flee comedy beat** — HR Ape present with at least one flee event in ≥80% of wave 2+ sessions (GDD gameplay metric).
- **Clip-worthiness** — At least one flee moment per run on average reported as memorable in playtest notes (qualitative, first cohort).

**Counter-metrics (do not optimize)**
- **Wave 5 clear rate** — Do not tune difficulty to force >80% win rate before balance data exists; early high win rate may indicate flee system is non-threatening.
- **Session length inflation** — Do not add content to push average session beyond 60 minutes for MVP; five-wave contract is a design constraint.
- **Meta grind speed** — Do not accelerate CC earn to unlock all clans within 2 runs; mastery and repeated failure are part of roguelike identity.

---

## 12. Open Questions

1. **O-001** — Final approval of 9-ape roster (GDD D-008); MVP uses Saw/HR/PR only.
2. **O-002** — Balance numbers: dissatisfaction thresholds, Dogecoin drops, plant costs, ape HP — all `[ASSUMPTION]` pending playtest.
3. **O-003** — Risk card definitions excluded from slice; need playtest design pass before full game.
4. **O-004** — Deadly Sins for Sand/Rock/Mold clans — post-Red-clan playtest.
5. **O-005** — Plant art style: full chibi vs semi-chibi to match apes.
6. **O-006** — Three Director identities and kits for mission types A/B/C.
7. **O-007** — Mutation paths (Combat/Root/Seed) scope tied to Carbon Shop clans.
8. **O-008** — Mold weather: mushroom allies vs sickened plants rules.
9. **O-009** — Green Ape ally trigger frequency.
10. **O-010** — Monetization model (premium vs free vs demo) before store requirements.
11. **O-011** — HR Unemployment achievement rule: GDD uses zero dissatisfaction **events while HR present**; brainstorm variant used zero dissatisfaction **entire run** — adopt GDD rule for implementation.

---

## 13. Assumptions Index

- **§0** `[ASSUMPTION]` — PRD audience is solo/small-team builder heading to Godot implementation.
- **§4.1 FR-3** — Wave durations: 5/6/7/8/10 minutes for waves 1–5.
- **§4.1 Notes** — Balance numbers pending playtest (see O-002).
- **§4.2 FR-9** — +25 dissatisfaction per unaddressed cause per Pause Phase.
- **§4.2 FR-12** — Flee thresholds: 100 standard, 75 sensitive, 50 with HR in radius.
- **§4.2 FR-14** — Post-flee tile occupied until barren (GDD A-10).
- **§4.3 FR-18** — Plant costs: Peanut 20, Cashew 35, Teak 50 Dogecoin.
- **§4.3 FR-22–24** — Species combat behaviors per GDD species table.
- **§4.4 FR-26** — Vertical-slice wave spawn script per addendum.
- **§4.4 FR-27** — Spawn interval 15s, burst every 60s (GDD A-14).
- **§4.4 FR-32** — Dogecoin drops: Saw 5, HR 15, PR 12.
- **§4.4 FR-33** — Ape HP multipliers ×1.0–×2.0 by wave.
- **§4.6 FR-41** — Stat card buff +10–20%, max +40% stacked per stat per run.
- **§4.8 FR-52** — Director mission B: +30 dissatisfaction, 5-tile radius, 10 s, once per encounter.
- **§4.8 FR-54** — Director bonus Dogecoin: 50.
- **§4.9 FR-55** — CC win 100–150; loss `min(20 + (waves_cleared × 15), 80)`.
- **§4.9 FR-57** — First clan unlock 200 CC (~3–5 runs).
- **§4.9 FR-60** — Carbon Shop stub acceptance criteria.
- **§4.10 FR-63** — Mouse drag map pan when viewport exceeded.
- **§4.13 FR-77** — Wave 1 tutorial spawn: 8× Saw Ape.
- **§5 NFR-1** — Peak load test scenario: 40 plants + 30 apes.
- **§5 NFR-3** — Godot 4.x engine.
- **§5 NFR-6** — 100 ms UI feedback target.
- **§6** — Semi-chibi plant silhouettes; HR flee comedic sting (pending O-005).
- **§7** — Optional keyboard pause/speed toggle.
- **§8** — Premium or free-demo monetization undecided.
- **§11** — Playtest survey N≥5; run completion ≥50% is pre-tuning baseline; median session 30–40 min.

---

*GDD reference: `_bmad-output/planning-artifacts/gdds/gdd-snake-rougelike-2026-07-26/gdd.md`*
*Addendum: `addendum.md` — wave scripts, balance tables, deferred technical detail*
