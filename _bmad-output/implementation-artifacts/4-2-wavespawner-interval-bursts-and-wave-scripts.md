---
baseline_commit: de496942799d3d35810aae29d2af85940200bde6
---

# Story 4.2: WaveSpawner — Interval, Bursts, and Wave Scripts

Status: done

## Story

As a player,
I want apes to spawn on a fixed interval with periodic bursts per wave script,
so that combat pacing escalates across five waves.

## Acceptance Criteria

1. **Given** CombatPhase for wave N **When** wave runs **Then** apes spawn every 15s with burst every 60s (FR27) — debug builds use compressed timers
2. **Given** any combat wave **When** spawns execute **Then** vertical-slice wave script loads from `data/waves/slice_waves.json` (FR26)
3. **Given** wave N (1–5) **When** ape spawns **Then** HP scales ×1.0/×1.2/×1.4/×1.6/×2.0 (FR33) via `hp_multiplier` on `APE_SPAWNED`
4. **Given** combat timer expires **When** `active_flee_count > 0` **Then** wave transition waits until zero (already in RunRoot — verify intact)

## Tasks / Subtasks

- [x] Task 1: Wave data + constants (AC: #1, #2, #3)
  - [x] Create `data/waves/slice_waves.json` — waves 1–5 per GDD table (Director omitted until Epic 5)
  - [x] Add `GameConstants`: `WAVE_HP_MULTIPLIERS`, `APE_SPAWN_INTERVAL_SEC`, `APE_BURST_INTERVAL_SEC`, debug variants
  - [x] Keep `data/fallback/waves.json` as wave-1-only fallback
- [x] Task 2: WaveSpawner rewrite (AC: #1, #2, #3)
  - [x] Load slice_waves.json primary, fallback waves.json
  - [x] Build spawn queue from wave `spawns` array; interval spawn one ape per tick
  - [x] Burst timer spawns `burst_spawns` entries every 60s
  - [x] Wave 1 tutorial keeps shorter interval from script override
  - [x] Emit `hp_multiplier` in `APE_SPAWNED` payload
- [x] Task 3: Ape HP scaling (AC: #3)
  - [x] Add `max_hp`/`current_hp` to `ApeBase`; apply `role_def.hp * hp_multiplier` on configure
  - [x] ApePool passes `hp_multiplier` from spawn payload
- [x] Task 4: RunRoot integration (AC: #1, #4)
  - [x] Call `start_wave(wave_index)` for ALL combat waves, not only wave 1
  - [x] Preserve wave-1 tutorial hooks
- [x] Task 5: Tests (AC: #1–#4)
  - [x] `test/wave_spawner_test.gd` — script load, queue build, HP multiplier, interval/burst timing (debug constants)
  - [x] Run full GdUnit4 suite — zero regressions

## Dev Notes

### slice_waves.json schema

```json
{
  "wave_number": 2,
  "tutorial": false,
  "interval_sec": 15,
  "burst_interval_sec": 60,
  "initial_delay_sec": 2,
  "spawns": [{ "ape_id": "saw_ape", "count": 6 }, { "ape_id": "hr_ape", "count": 2 }],
  "burst_spawns": [{ "ape_id": "saw_ape", "count": 1 }]
}
```

Wave 1: tutorial true, interval_sec 2.5 (FR77 pacing preserved).

### GDD wave composition (vertical slice)

| Wave | Spawns |
|------|--------|
| 1 | 8× saw_ape |
| 2 | 6× saw + 2× hr |
| 3 | 5× saw + 3× pr |
| 4 | 4× saw + 2× hr + 2× pr |
| 5 | 6× saw + 2× hr + 1× pr (no Director — Epic 5) |

### Previous story (4.1) — DO NOT BREAK

- `APE_SPAWNED` payload keys consumed by ApePool: `wave`, `ape_id`, `index`, `total`, `spawn_cell`, `move_speed_multiplier` — keep all; add `hp_multiplier`
- ApePool pending-spawn queue pattern must remain

### Out of scope

- Director boss spawn (Epic 5)
- Ape defeat / Dogecoin (4.6)
- Saw/HR/PR behaviors (4.3–4.5)

## Dev Agent Record

### File List

- leaf-me-alone/data/waves/slice_waves.json (new)
- leaf-me-alone/scripts/utils/constants.gd
- leaf-me-alone/scripts/systems/wave_spawner.gd
- leaf-me-alone/scripts/entities/ape_base.gd
- leaf-me-alone/scripts/systems/ape_pool.gd
- leaf-me-alone/scenes/run/run_root.gd
- leaf-me-alone/test/wave_spawner_test.gd (new)

### Change Log

- 2026-07-27: Story created
- 2026-07-27: Implemented slice waves 1–5, interval/burst spawner, HP scaling, RunRoot all-wave start, tests (79/79 pass)

### Test Results

```
Overall Summary: 79 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans
```
