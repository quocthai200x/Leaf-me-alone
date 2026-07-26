# PRD Addendum — Leaf Me Alone

Depth that does not fit PRD narrative shape. Referenced by `prd.md`.

---

## Vertical-Slice Wave Spawn Script

Referenced by FR-26. `[ASSUMPTION: GDD wave table — pending playtest tuning]`

| Wave | Duration | Spawns | Card Pick |
|------|----------|--------|-----------|
| 1 (tutorial) | 5 min | 8× Saw Ape | — |
| 2 | 6 min | 6× Saw + 2× HR | Yes |
| 3 | 7 min | 5× Saw + 3× PR | — |
| 4 | 8 min | 4× Saw + 2× HR + 2× PR | Yes |
| 5 | 10 min | 6× Saw + 2× HR + 1× PR + Director | — |

**Spawn pacing:** Individual spawn every 15 s; burst groups every 60 s (GDD A-14).

**Ape HP multiplier by wave:** ×1.0 / ×1.2 / ×1.4 / ×1.6 / ×2.0

---

## Balance Parameters (Pre-Playtest)

All values `[ASSUMPTION]` — resolve at O-002 first playtest.

| Parameter | Value |
|-----------|-------|
| Plant cost — Peanut | 20 Dogecoin |
| Plant cost — Cashew | 35 Dogecoin |
| Plant cost — Teak | 50 Dogecoin |
| Dogecoin drop — Saw | 5 |
| Dogecoin drop — HR | 15 |
| Dogecoin drop — PR | 12 |
| Dogecoin drop — Director | 50 |
| Flee threshold — standard | 100 dissatisfaction |
| Flee threshold — sensitive | 75 |
| Flee threshold — HR in radius | 50 |
| Dissatisfaction per unaddressed cause / Pause | +25 |
| CC win | 100–150 |
| CC loss formula | `min(20 + (waves_cleared × 15), 80)` |
| First clan unlock | 200 CC |
| Stat card buff | +10–20% per pick, max +40% stacked per stat |
| Director mission B spike | +30 dissatisfaction, 5-tile radius, 10 s |

---

## Satirical Achievement Voice (Post-Slice Reference)

Deferred from MVP (E14). Tone examples for future implementation:

- **Mass Quit** — Win a run after 5+ plants fled
- **HR Unemployment** — Win with zero dissatisfaction events while HR Ape was present (GDD rule)
- **Greenwash Fail** — Lose while Green Ape was active (full game)
- **Carbon Neutral** — Win without spending Dogecoin on care

---

## Deferred Technical Detail

- **Extraction tile degradation:** Saw Ape weakens soil/tiles over time; recapture loop post-slice
- **Glue Ape concrete roads:** −50% movement cost on affected tiles (E12)
- **Green Ape ally trigger:** Frequency undefined (O-009)
- **Analytics event schema:** Add before public playtest (PRD §10.2)

---

## Reconciliation Notes (Finalize 2026-07-26)

- **Red-clan Deadly Sins:** GDD D-009 specifies Red clan design complete but Out of Scope excludes Sins from first playable; MVP card pool = stat + soil only; Sin cards post-slice.
- **Ape count:** Wave script uses Saw + HR + PR (3 roles); GDD asset table "2 roles" treated as erratum — wave script authoritative.
