# Story 2.5: Water and Fertilize Care Actions

Status: done

## Story

As a player,
I want to water and fertilize plants during Pause,
So that I can reduce dissatisfaction and restore HP before the next wave.

## Acceptance Criteria

1. Water/Fertilize deduct Dogecoin per `data/economy.json` (FR20, FR21)
2. Insufficient funds disable care buttons with tooltip (UX-DR11)
3. CARE mode: select action then click planted tile to apply
4. Sparkle juice stub on care confirm (UX-DR28)
5. UI feedback within 100ms of click (NFR6)

## Tasks / Subtasks

- [x] GridData plant HP + dissatisfaction fields; init on placement
- [x] CareSystem with try_water / try_fertilize via EconomySystem
- [x] Pause panel Water/Fertilize buttons + affordability
- [x] InputRouter CARE mode click targeting
- [x] Tests + full suite pass
