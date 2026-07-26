---
baseline_commit: fa6634c1f7d5f8bd4605e0092a7ffbfd81d7b98a
---

# Story 2.2: EconomySystem and Dogecoin Wallet

Status: review

## Story

As a player,
I want a Dogecoin balance that tracks spending and resets each run,
So that I make meaningful earn-vs-spend decisions during Pause.

## Acceptance Criteria

1. **Given** a new run starts **When** EconomySystem initializes **Then** Dogecoin balance is 0 (FR38)
2. **And** Dogecoin stored as int only — no fractional currency
3. **When** player spends on plant or care **Then** balance deducts atomically (FR36)
4. **And** spending below zero is blocked (FR37)
5. **And** Dogecoin chip visible in Pause panel with Ð icon + numeric value (FR34, UX-DR9)

## Tasks / Subtasks

- [x] Task 1: EconomySystem core (AC: #1–4)
  - [x] Create `scripts/systems/economy_system.gd` under RunRoot (NOT autoload)
  - [x] `get_balance() -> int`, `try_spend(amount: int) -> bool`, `try_earn(amount: int) -> void`
  - [x] All mutations go through EconomySystem; never set `run_state.dogecoin` outside it
  - [x] `try_spend` rejects amount <= 0 and insufficient balance; int-only
  - [x] Emit `RunEvent.DOGECOIN_CHANGED` with `{balance, delta}` on change
- [x] Task 2: RunRoot integration (AC: #1)
  - [x] Add EconomySystem node to `run_root.tscn`; group `economy_system`
  - [x] EconomySystem reads/writes `RunManager.run_state.dogecoin` as single wallet
  - [x] Verify balance is 0 after `RunManager.start_run()` (init_from_seed)
- [x] Task 3: Pause panel Dogecoin chip (AC: #5, UX-DR9)
  - [x] Update `pause_panel.tscn/gd`: Ð glyph + numeric Label using theme `Label/numeric`
  - [x] Subscribe to `DOGECOIN_CHANGED` and refresh chip
  - [x] Do NOT put spend logic in pause_panel — display only
- [x] Task 4: Tests (AC: #1–4)
  - [x] `test/economy_system_test.gd` — reset, spend, block overspend, earn
  - [x] Run full GdUnit4 suite; no regressions (8/8 pass)

## Dev Agent Record

### Agent Model Used

Composer

### Completion Notes List

- EconomySystem as RunRoot child; sole mutator of run_state.dogecoin
- DOGECOIN_CHANGED event for UI refresh
- Pause panel shows Ð + balance with numeric theme variation

### File List

- leaf-me-alone/scripts/systems/economy_system.gd
- leaf-me-alone/scripts/data/run_event.gd
- leaf-me-alone/scenes/run/run_root.tscn
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/scenes/run/pause_panel.tscn
- leaf-me-alone/test/economy_system_test.gd
- _bmad-output/implementation-artifacts/2-2-economysystem-and-dogecoin-wallet.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-07-26: Story 2.2 — EconomySystem wallet + pause panel chip

## Senior Developer Review (AI)

**Review Outcome:** Approve

**Review Date:** 2026-07-26

**Summary:** Wallet API correct, events wired, UI display-only, tests cover spend/earn guards and event emission. No direct dogecoin mutation outside EconomySystem.

### Action Items

- [x] All ACs satisfied
