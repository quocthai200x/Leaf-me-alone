---
name: Leaf Me Alone
description: Chibi corporate-satire TD roguelike UI — cute surface, cynical meme energy, mouse-first PC HUD.
status: final
updated: 2026-07-26
project: snake-rougelike
colors:
  primary: '#7BC950'
  primary-hover: '#5FA838'
  secondary: '#FFB347'
  surface: '#1A2F1A'
  surface-alt: '#243824'
  surface-panel: '#2D4A2D'
  text: '#F5F0E6'
  muted: '#A8B5A0'
  border: '#4A6B4A'
  danger: '#FF6B6B'
  warning: '#FFD93D'
  dogecoin: '#C2A633'
  carbon-credit: '#6BCBAA'
  soil-red: '#C45C3E'
  soil-sand: '#E8D4A8'
  soil-rock: '#8B9A8C'
  soil-mold: '#6B5B7A'
  concrete: '#9E9E9E'
  barren: '#4A3F35'
  dissatisfaction: '#FF8C42'
  flee: '#FF4757'
  card-stat: '#74B9FF'
  card-soil: '#A29BFE'
  card-risk: '#FF7675'
typography:
  display:
    fontFamily: '"Fredoka", "Baloo 2", "Segoe UI", sans-serif'
    fontWeight: '700'
    fontSize: '2.25rem'
  heading:
    fontFamily: '"Fredoka", "Baloo 2", "Segoe UI", sans-serif'
    fontWeight: '600'
    fontSize: '1.5rem'
  body:
    fontFamily: '"Nunito", "Segoe UI", sans-serif'
    fontWeight: '500'
    fontSize: '1rem'
    lineHeight: '1.5'
  label:
    fontFamily: '"Nunito", "Segoe UI", sans-serif'
    fontWeight: '600'
    fontSize: '0.875rem'
    letterSpacing: '0.02em'
  numeric:
    fontFamily: '"JetBrains Mono", "Consolas", monospace'
    fontWeight: '600'
    fontSize: '1rem'
  meme:
    fontFamily: '"Comic Neue", "Comic Sans MS", cursive'
    fontWeight: '700'
    fontSize: '1.125rem'
rounded:
  sm: '6px'
  md: '12px'
  lg: '20px'
  xl: '28px'
  full: '9999px'
spacing:
  '1': '4px'
  '2': '8px'
  '3': '12px'
  '4': '16px'
  '5': '24px'
  '6': '32px'
  gutter: '16px'
  panel-padding: '20px'
  hud-margin: '24px'
components:
  button-primary:
    background: '{colors.primary}'
    background-hover: '{colors.primary-hover}'
    text: '{colors.text}'
    radius: '{rounded.md}'
    min-height: '44px'
  button-secondary:
    background: '{colors.surface-alt}'
    border: '2px solid {colors.border}'
    text: '{colors.text}'
    radius: '{rounded.md}'
  panel-pause:
    background: '{colors.surface-panel}'
    border: '3px solid {colors.border}'
    radius: '{rounded.lg}'
    shadow: '0 8px 0 rgba(0,0,0,0.25)'
  panel-card:
    background: '{colors.surface-alt}'
    border: '3px solid {colors.border}'
    radius: '{rounded.lg}'
    hover-border: '{colors.primary}'
  currency-dogecoin:
    icon: 'Ð'
    color: '{colors.dogecoin}'
    font: '{typography.numeric.fontFamily}'
  currency-carbon:
    icon: 'CC'
    color: '{colors.carbon-credit}'
    font: '{typography.numeric.fontFamily}'
  dissatisfaction-emoji:
    unhappy: '😤'
    fleeing: '🏃'
    size: '1.5rem'
  health-bar-core:
    fill: '{colors.primary}'
    background: '{colors.surface-alt}'
    height: '12px'
    radius: '{rounded.full}'
  plant-catalog-cell:
    size: '72px'
    radius: '{rounded.md}'
    selected-ring: '3px {colors.secondary}'
  card-pick-stat:
    accent: '{colors.card-stat}'
  card-pick-soil:
    accent: '{colors.card-soil}'
  card-pick-risk:
    accent: '{colors.card-risk}'
  tooltip:
    background: '{colors.surface-panel}'
    border: '2px solid {colors.border}'
    radius: '{rounded.sm}'
    text: '{colors.text}'
---

# DESIGN.md — Leaf Me Alone

> **Contract:** On conflict with mocks, wireframes, or imports, this file and `EXPERIENCE.md` win. This file owns visual identity; behavior lives in `EXPERIENCE.md`.

## Brand & Style

**Leaf Me Alone** reads as **chibi cartoon jungle vs corporate meme satire** — round, bouncy, emoji-forward, never grim. Apes wear exaggerated corporate costumes (vests, briefcases, billboards); plants are readable botanical silhouettes with **[ASSUMPTION: semi-chibi plants — slightly less exaggerated than apes to preserve species readability at TD scale; nam requested full chibi/fun/meme tone — confirm plant proportion lock]**.

The UI personality is **internet-native humor**: Dogecoin counters, Carbon Credit parody, achievement names like meme headlines. Visual language favors **thick outlines, soft shadows, sticker-like panels** — closer to a cozy mobile game than a military HUD. Satire lives in copy and costume, not in desaturated "serious strategy" chrome.

Commercial bar: every screen must screenshot well for Steam capsule and clip moments (flee whoosh + 😤→🏃) must pop on stream without UI clutter.

**Anti-reference:** Grim realistic warfare TD, earnest eco-propaganda without bite, sterile flat Material dashboards.

## Colors

| Role | Token | Hex | Use |
|------|-------|-----|-----|
| Primary | `primary` | `#7BC950` | PLAY, confirm, healthy ecosystem accents |
| Primary hover | `primary-hover` | `#5FA838` | Button hover / selected plant action |
| Secondary | `secondary` | `#FFB347` | Highlights, wave banners, card hover |
| Surface | `surface` | `#1A2F1A` | Full-screen backdrops, dim combat overlay |
| Surface alt | `surface-alt` | `#243824` | Menu cards, catalog cells |
| Panel | `surface-panel` | `#2D4A2D` | Pause right panel, card pick tray |
| Text | `text` | `#F5F0E6` | Primary labels |
| Muted | `muted` | `#A8B5A0` | Tooltips, secondary stats |
| Border | `border` | `#4A6B4A` | Panel outlines, cell dividers |
| Danger | `danger` | `#FF6B6B` | Core/Nest critical HP, loss states |
| Warning | `warning` | `#FFD93D` | Dissatisfaction rising, tutorial callouts |
| Dogecoin | `dogecoin` | `#C2A633` | In-run currency — always paired with Ð glyph |
| Carbon Credit | `carbon-credit` | `#6BCBAA` | Meta currency — always paired with CC label |
| Dissatisfaction | `dissatisfaction` | `#FF8C42` | Mood meter fill, PR billboard AoE tint |
| Flee | `flee` | `#FF4757` | Flee flash, mass-quit moments |
| Soil red | `soil-red` | `#C45C3E` | Laterite tiles (MVP default) |
| Soil sand | `soil-sand` | `#E8D4A8` | Coastal biome |
| Soil rock | `soil-rock` | `#8B9A8C` | Mountain biome |
| Soil mold | `soil-mold` | `#6B5B7A` | Humid biome |
| Concrete | `concrete` | `#9E9E9E` | Ape roads / factory spread |
| Barren | `barren` | `#4A3F35` | Greed Sin / depleted tiles |
| Card stat | `card-stat` | `#74B9FF` | Stat buff card accent |
| Card soil | `card-soil` | `#A29BFE` | Soil terraform card accent |
| Card risk | `card-risk` | `#FF7675` | Risk card accent (post-MVP pool) |

Contrast: `{colors.text}` on `{colors.surface-panel}` ≥ 7:1 for commercial readability at 1080p. Muted text reserved for non-critical labels only. **Resources never rely on hue alone** — Dogecoin always shows Ð icon; dissatisfaction always shows emoji + meter shape.

## Typography

- **Display** — `{typography.display}` for title screen logo lockup and Run End headlines ("MASS QUIT" achievement flair).
- **Heading** — `{typography.heading}` for panel titles (Pause catalog, Card Pick).
- **Body** — `{typography.body}` for descriptions, card effect text, tutorial prompts.
- **Label** — `{typography.label}` for HUD chips (wave timer, weather).
- **Numeric** — `{typography.numeric}` for Dogecoin, Carbon Credit, timers, HP — fixed width to prevent jitter.
- **Meme** — `{typography.meme}` **[ASSUMPTION: sparing use only]** for achievement popups and satirical one-liners; never for core gameplay instructions.

Scale: 16px body base → 21 / 28 / 38 display ramp (1.333 perfect fourth). Godot theme maps to these semantic roles.

## Layout & Spacing

8px base grid (`{spacing.2}`). **1920×1080 design baseline**; UI scales proportionally.

- **Pause Phase:** Map occupies left ~65%; `{components.panel-pause}` docked right ~35% (min 380px, max 480px). Dim overlay `{colors.surface}` at 60% over map during prep.

Visual reference: [Pause Phase mockup](mockups/key-pause-phase.html).
- **Combat HUD:** Corner-anchored chips inside `{spacing.hud-margin}` safe margin; never cover Forest Core or active flee paths.
- **Card Pick:** Full-screen scrim; three `{components.panel-card}` columns centered, max 320px each.

Visual reference: [Card Pick mockup](mockups/key-card-pick.html).
- **Main Menu / Carbon Shop:** Single centered column, max 560px wide.

Visual reference: [Main Menu mockup](mockups/key-main-menu.html).

Mouse hit targets ≥ 44×44px on all interactive elements (commercial PC baseline).

## Elevation & Depth

Sticker / chunky UI depth — panels use **hard offset shadow** (0 8px 0 rgba(0,0,0,0.25)), not soft Material blur. Layers:

1. **World** — island map, units, diegetic emoji above plants
2. **HUD overlay** — wave timer, structure HP, Dogecoin chip (combat only)
3. **Panel layer** — Pause catalog, Card Pick
4. **Modal / toast** — tutorial prompts, achievement banners, flee "HR DID IT AGAIN" quips **[ASSUMPTION]**

No nested modals — Card Pick replaces Pause; Run End replaces all.

## Shapes

Rounded-friendly chibi aesthetic: `{rounded.md}` on buttons and catalog cells; `{rounded.lg}` on panels; `{rounded.full}` on currency pills and HP bars. Thick `{colors.border}` outlines (2–3px) on all panels — readability over minimalism.

## Components

- **Button primary** — `{components.button-primary}`; bouncy 100ms scale on click; PLAY on title is largest instance.
- **Button secondary** — `{components.button-secondary}`; Back, Options, stub screens.
- **Pause panel** — `{components.panel-pause}`; sections stack: Dogecoin → Weather → Plant catalog → Care actions.
- **Plant catalog cell** — `{components.plant-catalog-cell}`; species portrait, cost in `{colors.dogecoin}`, role icon (ATK/DEF/Buff/Debuff). Selected state: `{components.plant-catalog-cell.selected-ring}`.
- **Care action row** — Water / Fertilize buttons with cost; disabled when insufficient Dogecoin (muted + shake **[ASSUMPTION]**).
- **Currency Dogecoin** — `{components.currency-dogecoin}`; always visible in Pause; combat chip top-right during waves.
- **Currency Carbon** — `{components.currency-carbon}`; Main Menu, Carbon Shop, Run End only.
- **Dissatisfaction emoji** — `{components.dissatisfaction-emoji}`; floats above plant in-world (diegetic-adjacent); meter bar optional under emoji at >50% dissatisfaction.
- **Health bar Core/Nest** — `{components.health-bar-core}`; pulses `{colors.danger}` below 25% HP.
- **Card pick tile** — `{components.panel-card}`; top accent stripe by type (stat/soil/risk); clan icon for stat cards.
- **Wave banner** — `{typography.heading}` + wave number; slides in at combat start, auto-dismiss 3s.
- **Run End summary** — Win/loss headline, waves cleared, CC earned, run seed in `{typography.numeric}`.

Visual references: [Combat HUD mockup](mockups/key-combat-hud.html) (flee clip moment), [Run End mockup](mockups/key-run-end.html).
- **Tutorial callout** — `{colors.warning}` pointer arrow + `{typography.body}`; dismiss on action complete.

## Do's and Don'ts

- **Do** keep flee feedback (😤 → 🏃 + whoosh) visually louder than damage numbers — it's the clip moment.
- **Do** pair every currency display with icon + label (Ð Dogecoin, CC Carbon Credit).
- **Do** color-code soil types consistently with map tile tints — player learns biology by sight.
- **Do** use satirical copy on Run End and achievements; keep tutorial instructions plain and clear.
- **Don't** use realistic corporate blue-gray SaaS palettes — breaks chibi/meme tone.
- **Don't** hide dissatisfaction state behind a menu — always visible on affected plants during combat.
- **Don't** stack Pause panel over the Forest Core — map pan defaults to center on Core at Pause entry **[ASSUMPTION]**.
