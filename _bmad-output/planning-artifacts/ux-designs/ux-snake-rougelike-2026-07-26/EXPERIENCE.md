---
title: 'EXPERIENCE.md — Leaf Me Alone'
status: final
updated: 2026-07-26
form_factor: PC (Windows), mouse-first, 1920×1080 baseline
sources:
  - gdds/gdd-snake-rougelike-2026-07-26/gdd.md
  - prds/prd-snake-rougelike-2026-07-26/prd.md
  - briefs/brief-angryplant-2026-07-26/brief.md
developer_intent:
  platform: PC
  stakes: commercial
  feel: chibi, fun, meme
  working_mode: fast path
---

# EXPERIENCE.md — Leaf Me Alone

> **Contract:** On conflict with mocks, wireframes, or imports, **DESIGN.md** and **EXPERIENCE.md** win. Visual specs → `DESIGN.md`; behavior and flows → this file. Token references use `{path.to.token}` → `DESIGN.md` frontmatter.

## Foundation

**Leaf Me Alone** ships on **Windows PC (Steam)**, **mouse-first** placement and UI. Engine: **Godot 4.x** Control-based UI theme extending `{DESIGN.md}` tokens. Single-player, top-down island TD with Pause-phase prep and roguelike card picks.

**Commercial stakes** imply Steam-screenshot polish, clip-worthy flee moments, and UI legibility at 1080p for 15–30 minute sessions. **[ASSUMPTION: English-only for EA; i18n layout reserve for v1.0.]**

Visual identity: see `DESIGN.md`. Behavioral UX owns flows, states, and input — not color hex values.

## Information Architecture

Flat, fast, mouse-driven — max **two navigation levels** from any run state.

### Pre-run (Main Menu hub)

Visual reference: [Main Menu mockup](mockups/key-main-menu.html).

- **PLAY** → new run (procedural tropical map, wave 1 tutorial)
- **Carbon Shop** → spend CC on clan unlocks (stub acceptable MVP; full catalog EA)
- **Achievements** → locked list stub (E14)
- **Settings** → audio volume stub (full settings v2)
- **Quit**

Persistent header: **Carbon Credit balance** (`{colors.carbon-credit}`).

### In-run surfaces

| Surface | Trigger | Primary content |
|---------|---------|-----------------|
| **Combat HUD** | Active wave | Map, units, structure HP, wave timer, Dogecoin chip, dissatisfaction indicators — [mockup](mockups/key-combat-hud.html) |
| **Pause Phase panel** | Between waves; optional mid-wave **[ASSUMPTION: Pause only between waves for MVP — no mid-combat pause per GDD loop]** | Plant catalog, care (water/fertilize), weather readout, Dogecoin balance — [mockup](mockups/key-pause-phase.html) |
| **Card Pick overlay** | After waves 2 and 4 clear | 1-of-3 cards (stat / soil MVP; risk post-slice) — [mockup](mockups/key-card-pick.html) |
| **Tutorial prompts** | Wave 1 guided | Placement, care, dissatisfaction teach |
| **Run End** | Win / loss / abandon | Outcome, waves cleared, CC preview, run seed — [mockup](mockups/key-run-end.html) |

### Navigation flow

```
Main Menu ──PLAY──► Run Start (map gen)
                         │
         ┌───────────────┴───────────────┐
         ▼                               │
    Pause Phase ◄── wave clear ── Combat Phase
         │                               │
         │         Card Pick (W2, W4) ◄───┘
         │
         └── wave 5 clear + Director defeated ──► Run End ──► Main Menu
```

**Surface closure:** Every GDD/PRD UI requirement maps to a surface above. No in-run shop, no sell/refund UI, no difficulty selector (v1).

## Voice and Tone

**Cute surface, cynical punchline.** Microcopy sounds like a meme-aware gardener who also reads corporate LinkedIn:

- **Menus:** Short, confident. "PLAY" not "Start New Expedition."
- **Satire:** Dogecoin tooltip: *"Totally real currency. Trust us."* Carbon Shop: *"Offset your guilt. Unlock more plants."*
- **Tutorial:** Plain instructions — humor after comprehension, not during.
- **Run End win:** *"The jungle survives another quarterly review."*
- **Run End loss:** *"Forest Core terminated. HR sends condolences."*
- **Flee moment:** Optional toast *[ASSUMPTION]*: *"Teak has resigned effective immediately."*

Tagline *"Who's righteous? No one — only the strong survive"* — title screen and Run End flavor only, not repeated in HUD.

Brand voice details in `DESIGN.md` Brand & Style; EXPERIENCE owns when/where copy appears.

## Component Patterns

Behavioral specs; visual tokens in `DESIGN.md.Components`.

- **Menu item** — click selects; hover highlights `{colors.primary-hover}`; single-click confirm (no double-click).
- **Plant catalog cell** — click selects species; cursor becomes placement mode; click valid tile to confirm spend; invalid tile = red flash + brief tooltip ("Wrong soil" / "Occupied" / "Need Ð20").
- **Care action** — select plant on map (or catalog focus) → Water / Fertilize buttons in panel; deduct Dogecoin on confirm; insufficient funds = disabled state + tooltip.
- **Card pick tile** — hover expands effect summary; click selects; confirm button or instant confirm **[ASSUMPTION: instant click-to-commit for speed]**; no undo.
- **Structure HP chip** — Forest Core + 3 Root Nest icons; click pans map to structure **[ASSUMPTION]**.
- **Dissatisfaction indicator** — per-plant emoji progression `{components.dissatisfaction-emoji}`; no click required; HR/PR effects telegraph via ape role icons in spawn banner.
- **Weather readout** — Pause panel only; shows current + next wave forecast; mismatch icon on affected species in catalog.
- **Currency display** — Dogecoin updates on kill (combat) and spend (Pause); animate `{typography.numeric}` tick, no slot-machine exaggeration.
- **Wave banner** — non-interactive; slides in at combat start, auto-dismiss 3s; shows wave number + incoming ape role icons when new roles debut.
- **Tutorial callout** — non-blocking pointer on first exposure to each concept; dismisses when the player completes the prompted action.
- **Run End summary** — single Continue focus; displays outcome, CC earned, run seed; no nested navigation.

## State Patterns

- **Main Menu idle** — ambient lo-fi loop; CC balance visible.
- **Carbon Shop — unaffordable** — locked clan rows muted; tooltip shows CC shortfall; no purchase dialog.
- **Carbon Shop — post-purchase** — unlock animates; row moves to owned state; balance updates immediately.
- **Settings / Achievements stub** — volume slider functional (Settings); achievement list read-only locked entries (Achievements).
- **Run loading** — biome name + seed generation quip *[ASSUMPTION: "Generating island… HR not included."]*
- **Pause Phase** — map dimmed 60%; panel interactive; apes absent; player can pan/drag map.
- **Combat active** — HUD visible; Pause panel hidden; wave timer counts down; spawns per wave script.
- **Card Pick interrupt** — combat frozen; overlay blocks map input until selection.
- **Dissatisfaction rising** — emoji 😤 appears; meter tint `{colors.dissatisfaction}`; optional plant wiggle animation.
- **Flee triggered** — 😤 → 🏃 sequence; Tom & Jerry whoosh SFX (priority polish); plant removed; tile remains occupied until barren.
- **Mass flee / HR moment** — screen-edge vignette `{colors.flee}` 200ms; comedic sting SFX; optional meme toast.
- **Wave clear** — brief celebration banner; transition to Pause or Card Pick.
- **Director encounter (W5)** — boss banner; mission B mass dissatisfaction spike telegraphed 2s before effect.
- **Run win** — Run End with CC payout (100–150 CC `[ASSUMPTION]`), seed display.
- **Run loss** — immediate on Core HP=0 or all Nests lost; partial CC `20 + waves_cleared × 15`.
- **Tutorial (W1)** — non-blocking prompts until placement/care/flee concepts touched; 8× Saw Ape pacing.

## Interaction Primitives

- **Primary click** — select UI, confirm placement, pick card.
- **Click + drag** — pan map when content exceeds viewport `[ASSUMPTION per GDD A-05]`.
- **Hover** — tooltip on catalog species, cards, disabled actions.
- **Right-click** — cancel placement mode / deselect species `[ASSUMPTION]`.
- **Keyboard** — `[ASSUMPTION optional v1]` Space/P pause or speed; Esc opens pause-abandon confirm only from Pause `[ASSUMPTION]`; not required for MVP acceptance per PRD.
- **No gamepad** — v1 non-goal.

Feedback budget: UI actions respond within **100ms** per PRD NFR-6.

## HUD & Diegetic UI

**Hybrid model:**

| Element | Diegesis | Notes |
|---------|----------|-------|
| Dissatisfaction emoji (😤 🏃) | **Diegetic-adjacent** | Floats above plant in world space; primary flee read |
| Dogecoin counter | **Non-diegetic** | Top-right chip during combat |
| Wave timer | **Non-diegetic** | Top-center |
| Forest Core / Root Nest HP | **Non-diegetic** | Bottom-left cluster |
| PR billboard AoE | **Diegetic** | In-world corporate billboard prop |
| Pause panel | **Non-diegetic** | Right dock |
| Card Pick | **Non-diegetic** | Full overlay |

**Information hierarchy (combat):**

1. **Critical** — Core/Nest HP, active flee events, wave timer
2. **Strategic** — Dogecoin, dissatisfaction on key plants, ape role spawn hints
3. **Ambient** — soil type readability (map tint), weather icon

Non-critical HUD never hides during combat — flee system requires constant mood visibility. Pause Phase hides combat HUD except structure HP summary in panel header `[ASSUMPTION]`.

## Input Schemes

| Context | Input | Actions |
|---------|-------|---------|
| Main Menu | Mouse | Navigate, click PLAY/Shop/Settings |
| Pause Phase | Mouse | Pan map (drag), select catalog, place plant, care actions |
| Combat | Mouse | Pan map (drag), observe HUD; no placement |
| Card Pick | Mouse | Select 1 of 3 cards |
| Run End | Mouse | Continue to Main Menu, optional "Share seed" copy button `[ASSUMPTION]` |

**Remapping:** Not in MVP (PRD). **[ASSUMPTION for commercial v1.0: add rebinding for pause/speed keys only.]**

**Context prompts:** Placement mode shows ghost preview on hover tile; invalid tiles red-outlined.

## Game Feel & Juice

UI responsiveness is part of the fantasy — **caretaker guilt + meme comedy**.

| Event | Feedback |
|-------|----------|
| Plant placed | Soft pop SFX + 1-frame scale bounce |
| Water / fertilize | Sparkle particles + satisfaction meter tick down |
| Ape killed | Dogecoin +Ð float (`{colors.dogecoin}`, `{typography.numeric}`) |
| Dissatisfaction threshold | 😤 pop + warning chirp |
| Flee | 😤→🏃 + whoosh SFX + optional resignation toast |
| HR Ape flee trigger | Extra comedic sting + "[ASSUMPTION] HR approved this departure" |
| Card selected | Card flip + accent flash (stat/soil color) |
| Wave start | Banner slide + percussion hit |
| Core hit | Screen shake light + `{colors.danger}` flash |
| Run win | Confetti `[ASSUMPTION]` + lo-fi sting resolve |

Juice respects **reduced motion toggle** `[ASSUMPTION for commercial v1.0]` — shake/particles off; SFX and emoji remain.

## Inspiration & Anti-patterns

**Take:**
- **PvZ** — plant readability, humor, immediate feedback
- **Bloons TD 6** — clean corner HUD, wave clarity
- **Slay the Spire** — card pick pacing, run-end summary
- **Emberward** — TD roguelite Steam UX baseline

**Leave:**
- Lane-only TD UI (this is free-placement island)
- Deckbuilder hand management UI
- Grim war HUD / desaturated "strategy" chrome
- Earnest eco-propaganda without satirical edge

**Anti-patterns for this product:**
- Hiding dissatisfaction behind a unit inspect panel
- Punishing flee without telegraph (HR/PR must be readable before crisis)
- Dense spreadsheet Pause UI — catalog stays visual/icon-first
- Overusing `{typography.meme}` in tutorial or loss explanations

## Responsive & Platform

- **Target:** 1920×1080 primary; scalable UI anchors (corners + right panel).
- **Min supported `[ASSUMPTION]`:** 1280×720 — Pause panel narrows to 320px min; catalog scrolls vertically.
- **Ultrawide:** Map extends; panel stays fixed width right dock.
- **Steam Deck / gamepad:** Non-goal v1 (PRD explicit cut).
- **Performance:** 60 FPS peak scenario (40 plants + 30 apes) — HUD must not allocate per-frame UI churn; emoji pooled.

## Accessibility Floor

PRD defers formal WCAG for MVP slice; **commercial intent** raises the floor for Steam EA:

| Requirement | MVP slice | Commercial EA target |
|-------------|-----------|----------------------|
| Colorblind-safe resources | Emoji + icons for mood/currency | + optional protan/deutan `[ASSUMPTION]` |
| Text scaling | Fixed scale | HUD scale slider `[ASSUMPTION v1.0]` |
| Reduced motion | Not in slice | Toggle disables shake/particles |
| Remapping | None | Pause/speed keys `[ASSUMPTION v1.0]` |
| Subtitles | N/A (minimal VO) | SFX caption stubs for flee/boss `[ASSUMPTION]` |

Dissatisfaction **never relies on color alone** — emoji + optional meter always paired.

## Key Flows

### Flow 1 — Alex's First Run (UJ-1 Tutorial)

**Protagonist:** Alex, first launch, skeptical the flee gimmick is funny.

1. Main Menu → clicks **PLAY** (big `{colors.primary}` button).
2. Map generates — tropical island, Red Soil; tutorial prompt: *"Place a Peanut here — cheap and cheerful."*
3. Pause Phase opens automatically before wave 1; Alex selects Peanut (Ð20), clicks tile near Root Nest.
4. Prompt: *"Water your moody employees before the apes arrive."* — Alex waters Peanut.
5. Combat starts — 8 Saw Apes; wave timer visible; Dogecoin chip at Ð0.
6. Alex kills apes, earns Ð; notices 😤 on a neglected plant **[ASSUMPTION: tutorial forces one care miss]**.
7. **Climax:** Plant flees 😤→🏃 with whoosh — Alex laughs, screenshots it.
8. Wave 1 clears → Pause opens → Alex feels caretaker guilt + amusement.

### Flow 2 — Alex's Full Run (UJ-2 + UJ-4 Flee Crisis)

1. Waves 2–4 loop: Pause prep → Combat → Card Pick after W2 and W4.
2. Wave 2: HR Apes spawn; flee threshold drops; Alex spends Dogecoin on care instead of more Teak.
3. **Climax (Wave 4):** PR billboards + HR overlap; three plants hit 😤 simultaneously — Alex panic-waters during Pause, saves two, loses one — *"Teak has resigned effective immediately."*
4. Card Pick after W4: Alex picks soil terraform card, reshapes choke point.
5. Wave 5 Director — mass dissatisfaction spike telegraphed; Alex pre-waters all plants.
6. Director defeated → Run End → CC +120, seed displayed → Main Menu.

### Flow 3 — Alex Unlocks a Clan (UJ-3 Meta)

1. Main Menu shows CC balance (e.g., 220 after several runs).
2. Alex opens **Carbon Shop** — sees Red Soil clan owned, Sand clan locked at 200 CC.
3. Clicks unlock — confirmation → CC deducted.
4. Returns to Main Menu → PLAY — catalog now shows Sand species `[post-slice content]`.

### Flow 4 — Boss Finish (UJ-5)

1. Wave 5 banner: *"Director inbound — quarterly performance review."*
2. Combat escalates; Director ability triggers dissatisfaction spike (telegraphed).
3. **Climax:** Final ape dies, Director HP reaches zero — slow-mo 0.5s `[ASSUMPTION]` → Run End win screen.
4. CC payout animates; achievement stub tease for "Mass Quit" `[post-MVP]`.

## Open Questions

| ID | Question | Blocker? |
|----|----------|------------|
| UX-O-01 | Full chibi plants vs semi-chibi (GDD O-005 vs nam "chibi" intent) | No — art lock |
| UX-O-02 | Instant card pick vs confirm button | No — `[ASSUMPTION]` instant |
| UX-O-03 | Mid-combat pause availability | No — `[ASSUMPTION]` between-waves only MVP |
| UX-O-04 | Meme toast frequency on flee (every flee vs first per wave) | No |
| UX-O-05 | Commercial accessibility scope for EA vs MVP slice | No — table above |
| UX-O-06 | Director identity visual kit (GDD O-006) | No — placeholder OK for slice |
| UX-O-07 | Right-click cancel placement | No — `[ASSUMPTION]` yes |

## Assumptions Index

Consolidated `[ASSUMPTION]` tags from this spine — tune in playtest / art lock.

- Semi-chibi plants (slightly less exaggerated than apes)
- English-only EA; i18n reserve v1.0
- Pause only between waves (no mid-combat pause MVP)
- Map pans to Forest Core on Pause entry
- Instant click-to-commit card pick
- Right-click cancels placement mode
- Optional keyboard Space/P pause; Esc abandon from Pause only
- Flee resignation toast copy (frequency TBD UX-O-04)
- Run loading quip, win confetti, share-seed button
- Commercial EA: HUD scale, reduced motion, colorblind mode, pause key remap
- Min resolution 1280×720 with scrolling catalog
- Structure HP chip click-to-pan
