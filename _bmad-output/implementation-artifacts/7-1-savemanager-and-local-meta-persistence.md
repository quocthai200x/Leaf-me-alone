---
baseline_commit: 3f6cd2bc94c9a130fbfe3a5d0a0b899fd74d0409
---

# Story 7.1: SaveManager and Local Meta Persistence

Status: done

## Story

As a player,
I want Carbon Credit balance and unlock state to persist across sessions,
So that meta progression survives closing the game.

## Acceptance Criteria

1. **Given** SaveManager autoload **When** run ends or shop purchase occurs **Then** CC balance and unlock state written to `user://save/meta.json` (FR59)
2. **And** save survives 100 load/save cycles without corruption (NFR4)
3. **And** no cloud sync in v1
4. **And** SaveManager never holds in-run Dogecoin — dual economy separation enforced

## Tasks / Subtasks

- [x] Task 1: Define meta save schema and defaults (AC: #1, #4)
  - [x] `version`, `carbon_credit`, `unlocked_clans`, `settings` keys in meta dict
  - [x] Default `unlocked_clans` includes `red_soil` (slice clan owned by default)
  - [x] No `dogecoin` key ever written or read
- [x] Task 2: Expand SaveManager autoload (AC: #1, #3, #4)
  - [x] Load meta on `_ready()`; typed getters/setters for CC and unlocks
  - [x] `save_meta()` persists in-memory state atomically to `user://save/meta.json`
  - [x] `add_carbon_credit()`, `unlock_clan()`, `is_clan_unlocked()` helpers
  - [x] Emit `meta_changed` signal after mutations (for Epic 7 UI stories)
- [x] Task 3: NFR4 durability test (AC: #2)
  - [x] `test/save_manager_test.gd` — round-trip, defaults, 100-cycle stress, invalid JSON recovery
- [x] Task 4: Verify no regressions (AC: #2)
  - [x] Run full GdUnit4 suite headless

## Dev Notes

### Current State (READ BEFORE EDITING)

**`autoload/save_manager.gd`** — stub from Story 1.1:
- `META_SAVE_PATH = "user://save/meta.json"`
- `_ensure_save_dir()`, generic `save(data)`, `load_meta()` returning raw dict
- No structured schema, no in-memory cache, no `_ready()` load

**Dual economy (must preserve):**
- Dogecoin lives in `RunManager.run_state.dogecoin` only — resets each run
- Carbon Credit is meta-only in SaveManager — never mix currencies

**CC preview (Story 5.3)** — `RunEndLogic.compute_cc_preview()` exists; actual grant deferred to Story 7.2. Do NOT wire grant logic here.

### Meta Save Schema

```json
{
  "version": 1,
  "carbon_credit": 0,
  "unlocked_clans": ["red_soil"],
  "settings": {
    "master_volume": 1.0,
    "sfx_volume": 1.0
  }
}
```

- Path: `user://save/meta.json` (never `res://`)
- `version` for future migrations
- Settings stub populated now for Story 7.5

### SaveManager API (implement exactly)

```gdscript
signal meta_changed

func get_carbon_credit() -> int
func set_carbon_credit(amount: int) -> void  # clamps >= 0, calls save_meta()
func add_carbon_credit(delta: int) -> void
func get_unlocked_clans() -> Array[String]
func is_clan_unlocked(clan_id: String) -> bool
func unlock_clan(clan_id: String) -> void  # idempotent, saves
func get_settings() -> Dictionary
func set_setting(key: String, value: Variant) -> void
func save_meta() -> bool
func reset_meta_for_tests() -> void  # test-only helper to wipe and reload defaults
```

### Architecture Compliance

- Godot 4.7.1, GDScript, autoload singleton pattern
- JSON via `JSON.stringify()` / `JSON.parse_string()` — same as existing stub
- Atomic write: write full dict in one `FileAccess.open(WRITE)` call
- Invalid/corrupt JSON → log warning, return defaults (do not crash)

### File Structure

| File | Action |
|------|--------|
| `leaf-me-alone/autoload/save_manager.gd` | UPDATE — full meta persistence |
| `leaf-me-alone/test/save_manager_test.gd` | NEW — unit + 100-cycle test |

### Testing Requirements

- GdUnit4 headless: `Godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a test/save_manager_test.gd`
- Full suite after changes
- 100-cycle test: mutate CC + unlock, save/load each iteration, assert values match

### Project Context Rules

- Local save only — no cloud/network calls
- `snake_case` files, signals via EventBus for gameplay; SaveManager may use own `meta_changed` signal
- Balance defaults in constants or schema defaults — CC starts at 0

### Previous Story Intelligence (6.4)

- GdUnit4 tests use `before_test()` cleanup via `RunManager.enter_main_menu()`
- Test files preload resources with `Res` suffix pattern
- Commits: `Story X.Y: <summary>.`

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 7.1]
- [Source: _bmad-output/project-context.md — Dual economy, save path]
- [Source: leaf-me-alone/autoload/save_manager.gd — existing stub]

## Dev Agent Record

### Agent Model Used

Composer

### Debug Log References

- GdUnit4 requires `--ignoreHeadlessMode` on Godot 4.7.1 CLI

### Completion Notes List

- Expanded SaveManager with structured meta schema, in-memory cache, typed CC/unlock/settings API
- Added `meta_changed` signal for downstream Epic 7 UI
- 6 unit tests including 100-cycle NFR4 stress test — all pass
- Full suite: 151 tests, 0 failures

### File List

- leaf-me-alone/autoload/save_manager.gd (modified)
- leaf-me-alone/test/save_manager_test.gd (new)
- _bmad-output/implementation-artifacts/7-1-savemanager-and-local-meta-persistence.md (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Review Date:** 2026-07-27

**Summary:** SaveManager correctly implements meta persistence with dual-economy separation, schema normalization, corrupt-JSON recovery, and comprehensive tests including 100-cycle durability.

**Action Items:**

- [x] No blocking issues found

## Change Log

- 2026-07-27: Story created via create-story workflow
- 2026-07-27: Implemented SaveManager meta persistence and tests; code review approved
