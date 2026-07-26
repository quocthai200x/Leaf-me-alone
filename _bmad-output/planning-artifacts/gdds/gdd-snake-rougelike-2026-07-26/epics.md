# Leaf Me Alone — Development Epics

**GDD workspace:** `gdd-snake-rougelike-2026-07-26`  
**Author:** nam  
**Updated:** 2026-07-26

Epic summary table lives in `gdd.md`. This file holds sequence, stories, and acceptance criteria.

---

## Epic Sequence

```
E1 Core TD Loop + Pause Phase
 ├── E2 Dissatisfaction, Care, and Flee
 ├── E3 Plant Species — Red Soil Clan
 ├── E4 Ape Roles — HR + PR
 └── E5 Dogecoin Economy
       ├── E6 Roguelike Card Picks
       ├── E7 Win/Loss + Forest Core + Root Nests
       └── E10 Weather System
             ├── E8 Wave 5 Director Boss
             ├── E9 Meta — Carbon Credit + Carbon Shop
             └── E11 Full Biome + Soil Expansion
                   ├── E12 Remaining Ape Roles + Directors
                   ├── E13 Deadly Sins + Mutation Paths
                   └── E14 Achievements + Polish
```

**Vertical slice boundary:** E1 + E2 + E3 + E4 + E5 + E6 (minimal) + E7 = first playable proving core fantasy.

---

## E1 — Core TD Loop + Pause Phase

**Goal:** Playable wave cycle with pause-phase prep and combat-phase TD assault on a single tropical map template.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E1-S1 | Main menu with PLAY | PLAY loads procedural tropical map and starts wave 1 |
| E1-S2 | Pause phase UI | Dim overlay; map visible; right panel shows plant catalog placeholder, Dogecoin, weather |
| E1-S3 | Wave start/end flow | Player confirms prep → combat runs → wave clear returns to Pause or card screen |
| E1-S4 | Top-down camera | Full island visible; mouse click selects tiles |
| E1-S5 | Wave timer/pacing | Combat wave supports 5–10 minute duration with spawn script hook |
| E1-S6 | Tutorial wave 1 | Guided prompts teach plant, care, and flee basics during first wave |

**Definition of Done:** One complete wave cycle (Pause → Combat → Pause) without plants or apes behaving correctly yet (placeholders OK).

---

## E2 — Dissatisfaction, Care, and Flee

**Goal:** Plants react to neglect and flee; player can spend Dogecoin to care during Pause.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E2-S1 | Dissatisfaction meter | Visible 😤 emoji when dissatisfaction > threshold |
| E2-S2 | Flee behavior | Plant uproots, runs to map back edge, removed from combat; 🏃 emoji + whoosh SFX |
| E2-S3 | Care actions | Water and fertilize reduce dissatisfaction and restore HP; costs Dogecoin |
| E2-S4 | Dissatisfaction causes | Wrong soil, missing care, and weather mismatch each increase dissatisfaction |
| E2-S5 | Sensitive Plant flee | Flee master — lower threshold, cheaper plant cost |

**Definition of Done:** Playtester can intentionally cause flee and prevent it with care spend.

---

## E3 — Plant Species — Red Soil Clan

**Goal:** Cashew, Teak, Peanut implement Attack/Defense/Buff/Debuff roles on red laterite soil.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E3-S1 | Cashew — reflect damage | Returns damage to Saw/Shovel apes on chop/extract |
| E3-S2 | Teak — tank | High HP; blocks advance |
| E3-S3 | Peanut — buff/debuff | N-fixation buff to adjacent allies; allelopathy slow on non-peanut neighbors |
| E3-S4 | Soil type validation | Planting on wrong soil increases dissatisfaction |
| E3-S5 | Plant placement costs | Per-species Dogecoin cost on place |

**Definition of Done:** All three species playable with distinct TD roles in wave combat.

---

## E4 — Ape Roles — HR + PR

**Goal:** Signature comedy roles for vertical slice.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E4-S1 | HR Ape spawn + behavior | Reduces flee threshold for plants in radius |
| E4-S2 | PR Ape billboard | Places billboard structure; increases dissatisfaction in AoE |
| E4-S3 | Ape extraction | Apes reduce tile/soil integrity on extract action |
| E4-S4 | Dogecoin drop on kill | HR drops higher than Worker baseline |
| E4-S5 | Wave composition script | Waves 2+ can include HR and/or PR |

**Definition of Done:** HR + flee interaction observed as signature beat in playtest.

---

## E5 — Dogecoin Economy

**Goal:** In-run currency loop — earn from kills, spend on plants and care.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E5-S1 | Dogecoin UI | Balance shown in Pause panel |
| E5-S2 | Drop on ape death | Role-weighted drop amounts |
| E5-S3 | Insufficient funds | Cannot plant or care without enough Dogecoin; UI feedback |
| E5-S4 | No in-run shop | Dogecoin has no shop sink beyond plant + care |

**Definition of Done:** Player must prioritize spend across planting vs care across a 5-wave run.

---

## E6 — Roguelike Card Picks

**Goal:** Between-wave card choice adds run variance.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E6-S1 | Card pick trigger | Modal after **waves 2 and 4** (max 2 picks per run) |
| E6-S2 | Stat card | +ATK / +DEF / grow speed / dissatisfaction resist for red clan plants in run |
| E6-S3 | Soil terraform card | Permanently changes 1 tile soil type on run map |
| E6-S4 | Risk card placeholder | 1 risk card with increased dissatisfaction rate + strong buff — tune later |
| E6-S5 | Card UI | Player picks 1 of 3 offered cards |

**Definition of Done:** At least one card pick per run changes plant stats or map soil.

---

## E7 — Win/Loss + Forest Core + Root Nests

**Goal:** Run termination conditions and objective structures.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E7-S1 | Forest Core | Central tree with HP; game over at 0 |
| E7-S2 | Root Nests (×3) | Structures with HP; spawn/resource restore hook |
| E7-S3 | Lose all nests | Run ends if 3rd Nest destroyed |
| E7-S4 | Win condition | Survive wave 5 and boss defeat |
| E7-S5 | Run end screen | Win/loss summary; Carbon Credit preview |

**Definition of Done:** Run ends correctly on Core death, nest wipe, or boss victory.

---

## E8 — Wave 5 Director Boss

**Goal:** Climactic boss wave with mission-type behavior.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E8-S1 | Director spawn | 1 of 3 Directors selected at run start; appears wave 5 |
| E8-S2 | Mission type A | Mobile factory spreads concrete tiles |
| E8-S3 | Mission type B | Mass dissatisfaction event on plants |
| E8-S4 | Mission type C | Suppresses Green Ape ally spawns |
| E8-S5 | Boss defeat | Triggers win state |

**Definition of Done:** Boss wave feels distinct from waves 1–4; win triggers run complete.

---

## E9 — Meta — Carbon Credit + Carbon Shop

**Goal:** Persistence between runs.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E9-S1 | Carbon Credit grant | Win > loss payout on run end |
| E9-S2 | Save meta | CC total and unlocks persist |
| E9-S3 | Carbon Shop UI | Pre-run screen lists unlockable clans |
| E9-S4 | Clan unlock | Spend CC to unlock Sand clan (first expansion content) |
| E9-S5 | Free in-run planting | All unlocked species placeable without per-run cost unlock |

**Definition of Done:** Second run can include newly unlocked clan plants after shop purchase.

---

## E10 — Weather System

**Goal:** Weather modifies dissatisfaction and ape behavior.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E10-S1 | Weather forecast in Pause | Next-wave weather shown |
| E10-S2 | Rain | Water-lovers recover; sun-lovers dissatisfied |
| E10-S3 | Harsh sun | Care required; apes extract faster |
| E10-S4 | Storm | Plants knocked down; apes pause |
| E10-S5 | Mold/fog | Placeholder debuff until rules finalized |

**Definition of Done:** Weather changes optimal care spend each Pause.

---

## E11 — Full Biome + Soil Expansion

**Goal:** All 5 biomes and 12 core plant species.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E11-S1 | Coastal biome + sand plants | Coconut, Mangrove, Beach Spinifex |
| E11-S2 | Mountain biome + rock plants | Bamboo, Lichen, Aloe Vera |
| E11-S3 | Humid biome + mold plants | Death Cap, Reishi, Corpse Flower |
| E11-S4 | Hybrid biome generator | Random soil mix |
| E11-S5 | 4 wildcard species | Sensitive, Pitcher, Strangler, Sundew |

---

## E12 — Remaining Ape Roles + Directors

**Goal:** Full 9-role roster and 3 named Directors.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E12-S1 | Worker, Miner, Engineer | Saw, Shovel, Glue apes |
| E12-S2 | Lawyer, Scientist, Live | Briefcase, Spray, Live apes |
| E12-S3 | Green Ape ally | Random sabotage of civilization faction |
| E12-S4 | 3 Director identities | Unique visuals + kits beyond A/B/C templates |
| E12-S5 | Concrete tile system | Glue roads + factory boss tiles affect pathing |

---

## E13 — Deadly Sins + Mutation Paths

**Goal:** In-run high-variance buff framework.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E13-S1 | Sin card offer | Deadly Sin can appear in card pool |
| E13-S2 | Red clan 7 Sins | All Pride–Greed effects implemented |
| E13-S3 | Sand/Rock/Mold Sins | Design + implement remaining 21 Sin mappings |
| E13-S4 | Mutation paths | Combat/Root/Seed path choice and effects |
| E13-S5 | Sin not in meta | Sins reset each run; not sold in Carbon Shop |

---

## E14 — Achievements + Polish (SFX/Music)

**Goal:** Retention hooks and feel polish.

### Stories

| ID | Story | Acceptance Criteria |
|----|-------|---------------------|
| E14-S1 | Achievement system | Track meme + skill achievements |
| E14-S2 | Mass Quit / HR Unemployment | Example achievements trigger correctly |
| E14-S3 | Lo-fi prep music | Pause phase track |
| E14-S4 | Combat music escalation | Wave intensity layers |
| E14-S5 | Flee whoosh SFX | Tom & Jerry-style polish pass |
| E14-S6 | Achievement hooks | Mass Quit and related triggers (tutorial moved to E1-S6) |

---

## Vertical Slice Checklist

Minimum shippable proof of fun:

- [ ] E1 — Pause/combat loop
- [ ] E2 — Flee + care + dissatisfaction
- [ ] E3 — Cashew, Teak, Peanut
- [ ] E4 — HR + PR apes
- [ ] E5 — Dogecoin earn/spend
- [ ] E6 — At least stat + soil cards
- [ ] E7 — Forest Core + 3 Root Nests + win/loss
- [ ] E8 — Director placeholder boss (wave 5, mission B)
- [ ] E14-S5 — Flee whoosh SFX (high priority feel moment)

**Explicitly not in slice:** E9 full meta (CC can stub), E10 full weather (1 weather type OK), E11+ content expansion, Green Ape (E12), Deadly Sins (E13).
