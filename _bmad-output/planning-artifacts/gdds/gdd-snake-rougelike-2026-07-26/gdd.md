---
title: Leaf Me Alone
game_type: tower-defense
game_type_note: Roguelike run structure (cards, procedural maps, meta progression)
platforms: PC (Godot)
created: 2026-07-26
updated: 2026-07-26
author: nam
---

# Leaf Me Alone — Game Design Document

**Author:** nam  
**Game Type:** Tower Defense (with Roguelike run structure)  
**Target Platform(s):** PC (Godot), mouse-driven placement

---

## Executive Summary

### Core Concept

**Leaf Me Alone** is a top-down ecosystem tower defense roguelike. The player commands an island jungle ecosystem against waves of corporate apes attempting to "civilize" the land. Plants are living defenders with moods — dissatisfied plants uproot and flee on foot. Between waves, the player enters a pause-phase prep screen to plant, care for, and strategize before the next assault.

Central conflict: **nature vs progress** — neither side is righteous. Tagline: *"Who's righteous? No one — only the strong survive."*

Each run: random biome map → 5 combat waves (5–10 minutes each) → roguelike card picks every 2–3 waves → wave 5 Director boss → meta Carbon Credit rewards.

### Target Audience

Players who enjoy **tower defense**, **roguelike build variance**, and **satirical humor**. Fans of wave-strategy games who want emotional/comedic unit behavior (plants deserting) rather than disposable tower sprites. PC players comfortable with mouse placement and pause-phase planning.

Tone: **cute chibi presentation** paired with **cynical corporate satire** (crypto, carbon markets, HR culture).

### Unique Selling Points (USPs)

1. **Plants that desert** — dissatisfied units flee with 😤 → 🏃 feedback and Tom & Jerry-style whoosh SFX; HR Ape accelerates desertion.
2. **Dual internal conflict** — plants flee *and* Green Apes sabotage the civilization faction (mirrored comedy beat each wave).
3. **Biology-driven 4-role soil system** — 16 real-world-inspired species with ecological mechanics (allelopathy, N-fixation, amatoxin DoT), not generic tower archetypes.
4. **Corporate jungle satire** — 9 modern ape job roles (PR billboards, Livestream map debuff, Lawyer tile locks).
5. **Dual satirical economy** — in-run **Dogecoin** (extraction crypto) vs meta **Carbon Credit** (carbon market parody).
6. **High-variance short runs** — random map, biome, boss, cards, and permanent soil terraforming create distinct runs in ~25–50 minutes.
7. **Seven Deadly Sins build chaos** — in-run-only extreme clan buffs (e.g., Greed permanently barrenifies tiles; Pride doubles DEF but death removes a 3×3 buff zone).

---

## Goals and Context

### Project Goals

1. Ship a **fun vertical slice** proving the flee + dissatisfaction + card loop in one tropical biome.
2. Validate that **corporate satire + chibi tone** lands without undermining strategic depth.
3. Establish a GDD detailed enough for **game architecture** and **epic/story breakdown** in Godot.
4. Target **intermediate-scope** solo/small-team production: 16 plants, 9 apes, 3 bosses, 5 biomes at full release.

### Background and Rationale

Design originated in brainstorming session 2026-07-26. Core fantasy: command an entire ecosystem as strategist + caretaker while nature fights back against civilization. Mashup of ecosystem management, pause-phase TD, and roguelike between-wave choices (Slay-the-Spire-style card picks without a deck builder).

Project codename in tooling: `snake-rougelike`. Canonical game title: **Leaf Me Alone**.

---

## Core Gameplay

### Game Pillars

1. **Living Ecosystem, Not Static Towers**  
   Plants have moods, soil preferences, and flee behavior. Placement is caretaking, not only optimization. Every wave risks losing units to dissatisfaction, not just damage.

2. **Nature vs Progress — Nobody's Right**  
   Satire targets both extractive civilization (apes) and chaotic nature (plants desert, Deadly Sin greed barrenifies tiles). Moral ambiguity is a design feature, not flavor text.

3. **Pause-Phase Strategy, Wave-Phase Chaos**  
   Prep phases reward planning (plant, water, fertilize, read weather). Combat phases are readable TD assaults with comedic corporate roles disrupting the plan.

4. **Run Variance Through Biology + Cards**  
   Random biomes, card picks, soil terraforming, and in-run Sin buffs create distinct builds without a complex pre-run loadout.

### Core Gameplay Loop

1. **Main Menu → PLAY** → random biome map generated → guided tutorial wave 1.
2. **Pre-wave Pause (prep phase):** Dim overlay; map visible; UI panel on right. Player spends Dogecoin to plant species, cares for plants (water/fertilize to reduce dissatisfaction and heal HP), reviews weather forecast.
3. **Combat wave:** One ape assault; TD combat; duration **5–10 minutes** per wave.
4. **On wave clear:** After **waves 2 and 4**, player picks **1 of 3 roguelike cards** (stat buff, soil terraform, or risk card).
5. Repeat for **5 waves total**.
6. **Wave 5:** Random **Director boss** (1 of 3) with unique mission mix.
7. **Run end:** Win → Carbon Credit payout + achievements; Lose → reduced Carbon Credit.
8. **Meta:** Carbon Shop (pre-run) — unlock plant clans and cosmetic skins with Carbon Credit.

**In-run economy loop:** Apes drop Dogecoin on death → spend during Pause on planting and care → no in-run shop.

### Win/Loss Conditions

| Outcome | Condition |
|---------|-----------|
| **Win** | Survive all 5 waves and defeat the wave-5 Director boss |
| **Lose** | **Forest Core** (central sacred tree) HP reaches 0 **OR** all **3 Root Nest** strongholds are lost |
| **Run length** | 5 waves × 5–10 min ≈ **25–50 minutes** total |

---

## Game Mechanics

### Primary Mechanics

#### Dissatisfaction and Flee

Plants track **dissatisfaction** from:

- Wrong soil type for species
- Enemy plant neighbors ("cây thù" — allelopathy conflict)
- Lack of care (not watered/fertilized when needed)
- Weather mismatch (e.g., desert species in rain, water-lovers in harsh sun)

**Dissatisfaction feedback:** Emoji above plant **😤** (unhappy) → **🏃** (fleeing). Plant uproots and runs toward the back of the map. Flee SFX: Tom & Jerry-style **whoosh** (clip-worthy moment).

**HR Ape:** Convince plants to flee **earlier** (reduces dissatisfaction threshold before flee triggers).  
**Sensitive Plant (*Mimosa pudica*):** Flee master — folds leaves when touched; cheap to plant; flees readily (wildcard, any soil).

[ASSUMPTION: Dissatisfaction threshold = 100 abstract points; +25 per unaddressed cause per Pause phase; flee triggers at 75 for Sensitive Plant, 100 for standard plants, 50 when HR Ape is in radius — tune in vertical slice.]

#### Plant Verbs

Grow/spread · Attack · Block/entangle · Regenerate · Cooperate · **Flee** · **Mutate**

#### Soil and Plant System

**Rule:** **3 plants per soil type**; each trio covers **Attack · Defense · Buff · Debuff** (dual-role allowed when biology supports).

**4 soil types × 3 plants = 12 core species + 4 wildcard specials = 16 total.**

| Soil | Species | Primary role | Secondary role |
|------|---------|--------------|----------------|
| Red (laterite) | Cashew | Attack | — |
| Red (laterite) | Teak | Defense | — |
| Red (laterite) | Peanut | Buff | Debuff (allelopathy) |
| Sand (coastal) | Coconut | Attack | — |
| Sand (coastal) | Mangrove | Defense | — |
| Sand (coastal) | Beach Spinifex | Buff | Debuff (slow + chip) |
| Rock + Moss | Bamboo | Attack | — |
| Rock + Moss | Lichen | Defense | — |
| Rock + Moss | Aloe Vera | Buff | Debuff (ape irritant) |
| Mold/Fungal | Death Cap | Attack (DoT) | — |
| Mold/Fungal | Reishi | Defense | Buff (adjacent heal/resist) |
| Mold/Fungal | Corpse Flower | Debuff | — |

**Biological mechanics:**

| Species | Role behavior |
|---------|---------------|
| Cashew | Anacardic acid — reflects damage on chop/extract |
| Teak | Hard wood — primary tank |
| Peanut | N₂ fixation buff + allelopathy debuff (slow/weaken outsiders) |
| Coconut | Falling fruit/rachis — AoE below canopy |
| Mangrove | Stilt roots — block, hold sand |
| Beach Spinifex | Dune stabilization + sharp leaves (slow + light damage) |
| Bamboo | Rhizome/shoot strike from underground |
| Lichen | Rock crust — hard to extract, reduced damage taken |
| Aloe Vera | Gel heals adjacent plants; sap irritates apes |
| Death Cap | Amatoxin stacking DoT |
| Reishi | Blocks + heal/resist debuff for adjacent plants |
| Corpse Flower | Morale/speed debuff on apes |

**4 Wildcards (any soil, weaker stats, flee-prone):**

- Sensitive Plant — flee master
- Pitcher Plant — weak attack
- Strangler Fig — weak defense, slow squeeze
- Sundew — weak debuff; needs humidity → easily dissatisfied

**Mutation paths (3):** Combat / Root / Seed — [NOTE FOR DESIGNER: path mechanics not yet specified; unlock scope tied to Carbon Shop clans.]

#### Seven Deadly Sins (In-Run Only)

In-run card/buff framework; **not meta progression**. Red Soil clan fully specified; other clans deferred.

| Sin | Plant | Effect |
|-----|-------|--------|
| Pride | Teak | Never flees; DEF ×2; on death = 3×3 zone loses red soil buff |
| Gluttony | Cashew | Devours low-HP apes; grows fast; red soil depleted after 3 waves |
| Lust | Peanut | Uncontrolled spread; auto-claims empty tiles each Pause |
| Envy | Cashew | Debuff non-red-soil plants; +50% buff to adjacent red-soil plants |
| Wrath | Teak | Reflect damage ×3; cannot be cared for; cannot hide |
| Sloth | Peanut | Auto-hides entire first Pause; no attack for 2 waves |
| Greed | Cashew | Steals all tile buffs; tile becomes barren permanently |

#### Weather

| Weather | Effect |
|---------|--------|
| Rain | Water-loving plants recover; desert/sun-loving plants dissatisfied |
| Harsh sun | Must water or dissatisfaction rises; apes extract faster |
| Storm | Plants knocked down; apes pause movement |
| Mold/fog | Species-dependent debuff/buff [NOTE FOR DESIGNER: mushroom allies vs sickened normal plants — rule TBD] |

Weather is announced during Pause so player can plan care spend.

#### Ape Roles (9)

[NOTE FOR DESIGNER: Roster proposed in brainstorm — pending nam approval before art lock.]

| Role | Name | Behavior |
|------|------|----------|
| Worker | Saw Ape | Chop trees, basic soil extraction |
| Miner | Shovel Ape | Dig deep — take soil, longer-lasting tile debuff |
| Engineer | Glue Ape | Concrete roads — apes move faster on roads |
| Marketing | PR Ape | Billboards — ↑ dissatisfaction in radius |
| Lawyer | Briefcase Ape | Extraction permits — lock tiles from planting |
| Scientist | Spray Ape | Herbicide AoE damage |
| HR | HR Ape | Convince plants to flee earlier |
| Influencer | Live Ape | Livestream deforestation — small whole-map debuff |
| Protest | Green Ape | Slow/sabotage civilization faction (random ally) |

**Extraction:** Removing soil weakens the forest unless recaptured. Glue Ape roads and mobile factory boss create **concrete tiles** altering traversal.

**Ape movement:** Tile-grid **A\*** pathfinding. Goal priority: **Forest Core > nearest Root Nest > highest-value extract tile**. Mangrove/Lichen tiles add movement cost; Glue Ape **concrete roads** reduce cost by 50%. Blocked tiles force reroute.

**Dogecoin drops:** Vary by role — Live Ape, PR Ape, Director > Worker. [ASSUMPTION: Worker 5, Miner 8, Engineer 6, PR 12, Lawyer 10, Spray 9, HR 15, Live 20, Director 50 — tune in slice.]

#### Boss System — Directors

**3 Directors; 1 random per run at wave 5.** Each combines mission types:

- **A:** Mobile factory → spreads concrete tiles
- **B:** Bribe plants → mass dissatisfaction spike
- **C:** Suppress green protest → counters Green Ape ally spawns

[NOTE FOR DESIGNER: Individual Director names, visuals, and unique ability kits not yet defined.]

#### Card System (Between-Wave Roguelike Picks)

- Pick **1 of 3 cards after waves 2 and 4** (max **2 picks per run**).
- **Roguelike balance band:** Each stat card grants **+10–20%** to one stat; max **+40%** stacked per stat per run. Sin and risk cards excluded from vertical slice pool.
- **Stat cards:** Random stat (ATK / DEF / grow speed / dissatisfaction resist); buffs only plants of **same clan** brought into run.
- **Soil cards:** Change region/tile permanently on run map; scope = 1 tile or small region by card rarity.
- **Risk cards:** Strong buff but increases plant dissatisfaction gain rate. [NOTE FOR DESIGNER: specific risk card definitions need playtest — Q12b.]

#### Strongholds

| Structure | Function |
|-----------|----------|
| **Forest Core** | Central sacred tree — run ends if destroyed |
| **Root Nest (×3)** | Spawn plants + restore resources; lose all 3 = run fail |

#### Economy (In-Run)

- **Dogecoin:** Drops from all apes; spent on planting and Pause-phase care.
- **Planting costs:** Per-species (Teak expensive, Sensitive Plant cheap). [ASSUMPTION: Sensitive 10, Peanut 20, Cashew 35, Teak 50 Dogecoin — tune in slice.]
- **Care during Pause:** Spend Dogecoin to reduce dissatisfaction and heal HP.
- **No in-run shop.**

#### Meta Economy

- **Carbon Credit:** Earned on run completion (win > lose) + achievements.
- **Carbon Shop (pre-run):** Unlock plant clans; cosmetic ape/plant skins (skins deferred until core is fun).
- **Pre-run loadout:** All unlocked plants available free in run; no starting buffs; no difficulty modifiers.

#### Achievements (Examples)

Mix funny/meme + skill + build challenges — not a separate lore category.

Examples from brainstorm: **Mass Quit** (X plants flee one wave), **HR Unemployment** (win with zero dissatisfaction events while HR present — design tension noted), **Carbon Neutral** (win without losing a Root Nest).

### Controls and Input

| Input | Action |
|-------|--------|
| Mouse click | Select tile, place plant, confirm UI |
| Mouse drag | [ASSUMPTION: Pan map if map exceeds viewport] |
| Pause UI panel | Plant catalog, care actions, weather readout, Dogecoin balance |
| Keyboard | [ASSUMPTION: Space or P to pause/speed — optional for v1.0 slice] |

Platform: **PC only** for v1.0. Mouse-first placement.

---

## Tower Defense Specific Design

### Tower Types and Upgrades

Plants function as **towers with mood**. Categories map to TD roles:

| TD Role | Plant examples | Notes |
|---------|----------------|-------|
| Damage | Cashew, Coconut, Bamboo, Death Cap | Single-target reflect, AoE drop, underground strike, DoT |
| Tank / Block | Teak, Mangrove, Lichen, Reishi | High HP, root block, damage reduction |
| Support / Buff | Peanut, Aloe, Reishi | Adjacent heal, N-fixation, resist |
| Debuff / Slow | Peanut, Beach Spinifex, Corpse Flower, Sundew | Allelopathy, slow, morale debuff |
| Special | Sensitive Plant | Flee bait / dissatisfaction indicator |

**Upgrades:** Between-wave **card picks** replace traditional tower upgrade trees. In-run **Deadly Sin** buffs act as extreme temporary "upgrade paths" with tradeoffs. No mid-wave tower upgrade UI.

[ASSUMPTION: Base plant HP 80–200 by role; ATK 5–25 DPS equivalent; range 2–4 tiles — tune per species in data tables during architecture phase.]

### Enemy Wave Design

| Parameter | Value |
|-----------|-------|
| Waves per run | 5 |
| Wave duration | 5–10 minutes |
| Wave 5 | Director boss + escorts |
| Composition | Mix of 2–4 ape roles per wave, escalating extract pressure |
| Scaling | Later waves add higher-drop roles (HR, Live) and extraction intensity |

**Vertical slice wave script:**

| Wave | Duration | Spawns | Notes |
|------|----------|--------|-------|
| 1 | 5 min | 8× Saw Ape | Tutorial — teach place + care |
| 2 | 6 min | 6× Saw + 2× HR | First flee pressure; **card pick after clear** |
| 3 | 7 min | 5× Saw + 3× PR | Billboard dissatisfaction zones |
| 4 | 8 min | 4× Saw + 2× HR + 2× PR | Peak prep economy test; **card pick after clear** |
| 5 | 10 min | 6× Saw + 2× HR + 1× PR + **Director placeholder** | Boss uses mission type B (mass dissatisfaction) in slice |

[ASSUMPTION: Ape HP multiplier ×1.0 / ×1.2 / ×1.4 / ×1.6 / ×2.0 by wave; spawn interval 15s with burst groups every 60s.]

**Enemy archetypes via roles:** Fast (Glue road benefit), Tank (Shovel sustained dig), Support (PR debuff zone), Specialist (HR flee pressure, Lawyer tile deny).

**Endless mode:** Out of scope for v1.0.

### Path and Placement Strategy

- **Top-down full island view** — not lane-based classic TD.
- **Free placement** on buildable soil tiles; Lawyer permits create **non-buildable** zones.
- **Terrain types:** 4 soil types + concrete (ape roads/factory) + barren (Greed Sin).
- **Choke points:** Natural island geography + player-placed Mangrove/Bamboo zones.
- **Line of sight / range:** Visualized on plant select; ground-level attacks vs canopy AoE distinguished for Coconut.

Soil terraforming cards permanently alter the strategic space within a run.

### Economy and Resources (TD Frame)

| Resource | Source | Spend |
|----------|--------|-------|
| Dogecoin | Ape kills, role-weighted drops | Planting, Pause care |
| Forest integrity | Forest Core + Root Nest HP | Implicit — lose condition |
| Card picks | Wave clear at intervals | Build variance |

No sell/refund mechanic [ASSUMPTION: plants cannot be sold once placed — fleeing removes them from combat but tile may remain occupied until barren/depleted].

### Abilities and Powers

Player-activated abilities are **minimal in v1.0** — strategy flows through placement and care during Pause, not cooldown abilities.

Passive "abilities" emerge from plant verbs, weather, cards, and Deadly Sins.

[NOTE FOR DESIGNER: Optional future active — emergency rain dance or fertilizer burst — deferred.]

### Difficulty and Replayability

- **Fixed balance** — no difficulty selector for v1.0.
- **Replayability drivers:** Random biome, random boss, card variance, soil terraform outcomes, Deadly Sin rolls, Green Ape ally randomness.
- **Mission objectives / star ratings:** [ASSUMPTION: achievements substitute for star ratings in v1.0.]

---

## Roguelike Layer (Cross-Cutting)

Documented here because run structure is co-primary with TD combat.

### Run Structure

- **Length:** 5 waves, ~25–50 min.
- **Starting conditions:** Empty-handed — no pre-run buffs; all unlocked species available to plant.
- **Victory:** Boss defeated after wave 5.
- **Scaling:** Card picks + wave composition escalation; no per-run difficulty slider.

### Procedural Generation

- **Fully random map each run** from biome template.
- **5 biomes:** Tropical island, Coastal island, Mountain island, Humid/mold island, Hybrid random mix.
- **Seed system:** Deterministic run seed stored in save metadata; **debug replay** and daily challenge seed supported in full release; slice uses random seed with seed displayed on run-end screen.

### Permadeath and Meta Progression

- **Run failure:** Lose remaining wave progress; partial Carbon Credit: **`20 + (waves_cleared × 15)`** CC (e.g., lose on wave 3 → 50 CC).
- **Meta persists:** Carbon Credit, unlocked clans, achievements, cosmetics.
- **In-run only:** Deadly Sins, card buffs, soil terraform — reset each run.

### Item and Upgrade System

Roguelike "items" = **between-wave cards** (stat, soil, risk). No inventory grid. Rarity on soil card scope (1 tile vs region).

---

## Progression and Balance

### Player Progression

1. **Tutorial run:** Guided wave 1 on tropical biome.
2. **Meta unlocks:** Carbon Shop clan unlocks expand plant roster available each run.
3. **Skill progression:** Player mastery of dissatisfaction management, care economy, and card/soil synergies.
4. **Achievement hunting:** Meme + skill challenges reward Carbon Credit bonuses.

No character levels or XP.

### Difficulty Curve

| Phase | Challenge |
|-------|-----------|
| Wave 1 | Tutorial pacing; 1–2 ape roles; teach flee + care |
| Waves 2–3 | Introduce PR/HR; first card pick; weather pressure |
| Wave 4 | Multi-role assault; extraction threatens Root Nests |
| Wave 5 | Director boss mission + peak role mix |

[ASSUMPTION: No dynamic rubber-banding — failure is learning-driven.]

### Economy and Resources

**In-run Dogecoin budget tension:** Plant expensive tanks vs cheap flee-prone scouts vs care spend before weather spikes.

**Meta Carbon Credit pacing:** [ASSUMPTION: Win grants 100–150 CC, loss grants 20–40 CC; first clan unlock at 200 CC — tune for ~3–5 runs to first unlock.]

---

## Level Design Framework

### Level Types

| Biome | Soil emphasis | Weather bias | Ape entry flavor |
|-------|---------------|--------------|------------------|
| Tropical island | Red (laterite) | Rain cycles | Inland civilize push |
| Coastal island | Sand | Harsh sun, storms | Shore landing |
| Mountain island | Rock + Moss | Storm, harsh sun | Ridge extraction |
| Humid island | Mold/Fungal | Mold/fog | Spore-heavy debuff zone |
| Hybrid | Random mix | Mixed | Unpredictable |

Each map includes **Forest Core (center)** and **3 Root Nests** at fixed semantic positions per template (exact coordinates procedural).

### Level Progression

Single map per run. Progression is **wave index**, not geography traversal. Soil cards reshape the same map over the run.

**Vertical slice:** **1 tropical biome** only — Cashew, Teak, Peanut vs HR Ape + PR Ape.

---

## Art and Audio Direction

### Art Style

- **Apes:** Chibi corporate satire — vests, briefcases, billboards, livestream gear.
- **Plants:** [ASSUMPTION: Semi-chibi botanical readable silhouettes — slightly stylized but not full chibi to contrast apes; confirm with nam.]
- **UI:** Pause panel right-side; emoji dissatisfaction indicators (😤 🏃).
- **Environment:** Island/jungle top-down; readable soil type color coding (red/sand/rock/mold).
- **Skins:** Deferred until core loop validated.

### Audio and Music

| Context | Direction |
|---------|-----------|
| Prep / Pause | Lo-fi forest rain — chill planning mood |
| Combat | Escalating percussion + comedic stings on HR flee moments |
| Flee SFX | Tom & Jerry-style whoosh — priority polish item |
| Boss | Distinct Director theme per boss [when identities defined] |

Music varies by biome at full release; tropical lo-fi for slice.

---

## Technical Specifications

### Performance Requirements

[ASSUMPTION: 60 FPS sustained at 1080p on mid-range PC (GTX 1060 / RX 580 equivalent) during peak wave with 40 active plants and 30 apes, measured over a 3-minute combat segment.]

### Platform-Specific Details

| Spec | Target |
|------|--------|
| Engine | Godot 4.x [ASSUMPTION: align with project setup] |
| Platform | Windows PC (primary) |
| Input | Mouse primary |
| Resolution | 1920×1080 design baseline; scalable UI |
| Save | Meta progression + settings local save |

### Asset Requirements

| Category | v1.0 Slice | Full Game |
|----------|------------|-----------|
| Plant species | 3 (Cashew, Teak, Peanut) | 16 |
| Ape roles | 2 (HR, PR) | 9 |
| Bosses | 1 Director placeholder (wave 5, mission B) | 3 |
| Biomes | 1 tropical | 5 |
| UI screens | Main menu, Pause, Card pick, Run end, Carbon Shop | + Achievements, Settings |

---

## Development Epics

### Epic Summary

| # | Epic | Priority | Depends |
|---|------|----------|---------|
| E1 | Core TD Loop + Pause Phase | P0 | — |
| E2 | Dissatisfaction, Care, and Flee | P0 | E1 |
| E3 | Plant Species — Red Soil Clan | P0 | E1, E2 |
| E4 | Ape Roles — HR + PR | P0 | E1 |
| E5 | Dogecoin Economy | P0 | E1, E3 |
| E6 | Roguelike Card Picks | P1 | E1 |
| E7 | Win/Loss + Forest Core + Root Nests | P0 | E1 |
| E8 | Wave 5 Director Boss | P1 | E4, E7 |
| E9 | Meta — Carbon Credit + Carbon Shop | P1 | E7 |
| E10 | Weather System | P1 | E2 |
| E11 | Full Biome + Soil Expansion | P2 | E3, E10 |
| E12 | Remaining Ape Roles + Directors | P2 | E4, E8 |
| E13 | Deadly Sins + Mutation Paths | P2 | E3, E6 |
| E14 | Achievements + Polish (SFX/Music) | P2 | E2, E9 |

Detailed breakdown: see `epics.md`.

---

## Success Metrics

### Technical Metrics

- 60 FPS sustained during peak combat scenario (see Performance Requirements).
- Zero soft-lock states in Pause → Combat → Card → Pause loop.
- Save/load meta progression without corruption across 100 cycle test.

### Gameplay Metrics

- **Vertical slice playtest:** ≥70% of testers describe flee moment as "funny" or "memorable" (survey prompt post-session).
- **Session length:** Median run 30–40 minutes (5 waves).
- **Retry rate:** ≥50% of playtesters start a second run within same session (roguelike engagement signal).
- **HR + flee interaction:** Observed in ≥80% of wave 2+ sessions where HR is present (telemetry or playtest log).

---

## Out of Scope

**v1.0 / vertical slice cuts:**

- In-run shop
- Difficulty modifiers / difficulty selector
- Complex pre-run loadout or starting buffs
- Ape/plant cosmetic skins (deferred until core fun proven)
- 7 Deadly Sins for Sand, Rock, Mold clans (Red clan only for first playable)
- Endless/survival mode
- Multiplayer
- Mobile / gamepad (PC mouse only)

**Post-launch / future:**

- Remaining biomes beyond slice (E11)
- Full 9 ape roster and 3 named Directors (E12)
- Skin marketplace aesthetic (Carbon Shop cosmetics)
- Player-activated emergency abilities
- Narrative campaign mode

---

## Assumptions and Dependencies

### Assumptions Index

All inline `[ASSUMPTION]` tags consolidated:

| ID | Assumption |
|----|------------|
| A-01 | Dissatisfaction threshold = 100 points; +25 per unaddressed cause per Pause; flee at 75 (Sensitive), 100 (standard), 50 with HR in radius |
| A-02 | Dogecoin drops: Worker 5, Miner 8, Engineer 6, PR 12, Lawyer 10, Spray 9, HR 15, Live 20, Director 50 |
| A-03 | Plant costs: Sensitive 10, Peanut 20, Cashew 35, Teak 50 Dogecoin |
| A-04 | Base plant HP 80–200 by role; ATK 5–25 DPS; range 2–4 tiles |
| A-05 | Mouse drag pans map when map exceeds viewport |
| A-06 | Space or P toggles pause/speed — optional for v1.0 slice |
| A-07 | 60 FPS at 1080p on mid-range PC (GTX 1060 class), 40 plants + 30 apes, 3-min combat sample |
| A-08 | No dynamic rubber-banding — failure is learning-driven |
| A-09 | Achievements substitute for star ratings in v1.0 |
| A-10 | Plants cannot be sold/refunded once placed in v1.0 |
| A-11 | Godot 4.x is the production engine |
| A-12 | Semi-chibi plant art unless nam specifies full chibi match |
| A-13 | Carbon Credit: win 100–150, loss uses `20 + waves_cleared × 15`; first clan unlock at 200 CC (~3–5 runs) |
| A-14 | Ape HP multiplier ×1.0 / ×1.2 / ×1.4 / ×1.6 / ×2.0 by wave; spawn interval 15s, burst every 60s |
| A-15 | Roguelike stat card band: +10–20% per card, max +40% stacked per stat per run |

### Dependencies

- Brainstorming session 2026-07-26 (`_bmad-output/brainstorming-session-2026-07-26-en.md`) — primary design input.
- `gds-game-architecture` — next workflow for Godot system design.
- Playtest feedback required before locking card risk definitions (Q12b) and HR Unemployment achievement rule.

### Designer Notes

- [NOTE FOR DESIGNER: Approve 9-ape role roster before animation budget lock.]
- [NOTE FOR DESIGNER: Resolve mold weather — mushroom allies vs sickened plants.]
- [NOTE FOR DESIGNER: Name and kit the 3 Directors beyond mission type letters A/B/C.]
- [NOTE FOR DESIGNER: Define Combat/Root/Seed mutation path mechanics.]
