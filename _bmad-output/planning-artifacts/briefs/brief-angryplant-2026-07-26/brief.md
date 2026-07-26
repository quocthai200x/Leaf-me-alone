---
title: "Game Brief: Leaf Me Alone"
status: complete
created: 2026-07-26
updated: 2026-07-26T15:05:00+07:00
project: AngryPlant
author: nam
---

# Game Brief: Leaf Me Alone

## Executive Summary

**Leaf Me Alone** is a satirical tower-defense roguelike for PC (Steam). You command a moody plant army defending a procedurally generated island from corporate apes extracting resources and "civilizing" the land. Plants fight only if you earn their loyalty — wrong soil, neglect, weather, and PR billboards drive dissatisfaction, and units can **flee mid-wave**. Between waves you Pause to plant, spend in-run Dogecoin, and manage moods; every 2–3 waves you pick roguelike upgrades. Survive five assaults, defeat a random Director boss, unlock clans with meta Carbon Credit.

**Audience:** 12+ PC players wanting **15–30 minute** sessions — roguelite fans, TD players, PvZ-adjacent strategists. **Premium** $14.99 EA → $19.99 at 1.0. **Solo developer**, Godot 4. **MVP:** prove flee + dissatisfaction + Pause care + cards = fresh TD in a vertical slice (tropical biome, Red Soil clan, 3–4 ape roles) before expanding content.

**Positioning:** *"PvZ meets Slay the Spire — but your towers have HR problems."* No direct competitor combines fleeing emotional plants, corporate ape satire, and biology-driven soil mechanics.

## Vision

**Core fantasy:** You are the island's caretaker-commander — defending a living jungle with plants that fight only if you earn their loyalty, and quit mid-battle if you don't.

**Elevator pitch:** Corporate apes invade to extract and develop; your defense is real plants with real moods. Pause to plant and care; fight as HR Apes trigger flee events and PR Apes erode morale. Roguelike card picks, five waves, random Director boss. No side is righteous.

**Emotional takeaway:** Cynical amusement first (corporate apes, fleeing plants, Dogecoin gardening); caretaker guilt second when neglect causes a flee or death. Tagline — *"Who's righteous? No one — only the strong survive"* — is flavor, not the post-session mood.

**Purpose:** Shippable Steam release. Scope discipline and MVP prove the core loop before content expansion.

## Target Players & Market

**Primary:** PC Steam, **12+** (E10+ / PEGI 12), intermediate-friendly. Sessions **15–30 min**. Wants wave defense with personality, run variance without deckbuilder APM, humor and clip-worthy moments, top-down mouse placement.

**Secondary:** Roguelite fans (Slay the Spire, Ratropolis), TD players (Bloons, Emberward), PvZ-adjacent casual strategists.

**Market:** TD + roguelite hybrid space is growing but crowded (~20K Steam releases/year; Very Positive reviews required). Wedge: flee mechanics + corporate satire + biology-driven soil. PC-first; console/mobile deferred. F2P not recommended.

## Core Fundamentals

**Genre:** Tower defense roguelite with ecosystem management and satirical strategy. Top-down, single-player, wave-based.

**Core loop:** Pre-run (random map) → **Pause** (plant, care, Dogecoin) → **Combat** (3–5 min wave, flee events) → **Card pick** (every 2–3 waves) → ×5 → **Boss** → meta unlocks.

**Win:** 5 waves + Director defeated. **Lose:** Forest Core dies OR all 3 Root Nests lost.

**Pillars:**
1. **Plants have emotions** — dissatisfaction drives flee; care during Pause is combat strategy
2. **Satire with bite** — corporate ape roles, Dogecoin (in-run), Carbon Credit (meta)
3. **Biology = mechanics** — four soil types, real plant roles, weather interlock
4. **Short runs, high variance** — random map, biome, boss, cards; no difficulty toggles

**Key mechanics:** Pause phase · dissatisfaction → flee (😤→🏃) · Dogecoin economy · roguelike cards · soil types · weather · Root Nests + Forest Core · ape roles (Worker, HR, PR, Green protest…) · 7 Deadly Sins (post-MVP)

## References & Differentiation

| Title | Take | Leave |
|---|---|---|
| **PvZ** | Plant theme, humor, readability | Lanes; pure good vs evil |
| **Bloons TD 6** | Wave mastery, premium model | No mood/flee |
| **Slay the Spire** | Between-wave cards, meta unlocks | Turn-based; no spatial TD |
| **Emberward** | TD roguelite on Steam, $15 tier | No satire or ecosystem mood |

**Differentiators:** (1) Units desert mid-wave (2) Corporate ape civilization as enemy (3) Real biology as roles (4) Dual satirical economy (5) No righteous side — plants flee, apes protest.

**Honest edge:** Execution and feel — not a content moat at launch. Prove the wedge in the vertical slice.

*Extended comp table → `addendum.md`*

## Scope & MVP

| | |
|---|---|
| **Platform** | PC (Steam), Godot 4, mouse placement |
| **Team** | Solo developer |
| **Session** | 15–30 min (~3–5 min combat + Pause × 5 + boss) |

**Vertical slice hypothesis:** Flee + dissatisfaction + Pause care makes TD fresh, not frustrating.

**Slice must ship:**
1. Plants flee on foot (whoosh SFX)
2. Dissatisfaction + care (Dogecoin)
3. Roguelike card picks

**Slice content:** Tropical biome · Cashew/Teak/Peanut · Worker/HR/PR + 1 Director · 5 waves + boss · Dogecoin · guided wave-1 tutorial · simple random map.

**NOT in slice:** Carbon shop, other clans, extra biomes, Deadly Sins, skins, achievements.

**Roadmap:** Slice → Steam EA (+Sand clan, +2 biomes, meta, 6+ apes) → 1.0 (4 clans, 5 biomes, 3 Directors, $19.99).

## Content & Direction

**Setting:** Procedurally generated island jungle vs corporate ape extraction. Cute chibi surface, cynical undertone.

**Narrative:** Environmental and systemic — no cutscene campaign. Mechanics are the satire.

**Art:** Top-down chibi/cartoon; corporate ape costumes; emoji mood indicators; Pause dim overlay + right panel.

**Audio:** Lo-fi forest rain (chill ↔ combat); flee whoosh as signature SFX.

## Risks & Open Questions

| Risk | Mitigation |
|---|---|
| Flee feels punishing | Prototype early; tune thresholds; tutorial + HR telegraph |
| Scope too large (solo) | One clan polished first; defer sins/skins/biomes |
| Session length vs depth | Shorten waves; tight Pause UX |
| TD roguelite saturation | Market on flee + satire; demo at festivals |

**Open for GDD:** Card risk numbers · mood/HP/Dogecoin balance · art pipeline · Director count at EA · 4 vs 5 waves for session target · Deadly Sins for non-Red clans.

**Validate:** Flee = amusement > frustration · Care feels strategic · One clan enough for EA hook · $14.99 viable · Chibi art achievable solo.
