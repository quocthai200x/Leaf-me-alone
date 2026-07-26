# Story 2.4: Plant Catalog and Placement Validation

Status: done

## Story

As a player,
I want to view available species and place them on valid Red Soil tiles,
So that I build my defensive line during Pause.

## Acceptance Criteria

1. Catalog shows Cashew, Teak, Peanut with Ð cost and role labels (FR17, FR25, UX-DR10)
2. Valid Red Soil click places plant and deducts Dogecoin (FR18)
3. Invalid/occupied tiles reject placement (FR19)
4. Ghost preview on hover; invalid tiles red-outlined (UX-DR19)
5. Placement juice: scale bounce tween (UX-DR28 stub; SFX deferred)

## Tasks / Subtasks

- [x] GridData placement API + PlantPlacementSystem
- [x] Catalog UI in pause panel
- [x] InputRouter PLACE_PLANT click/hover + map preview
- [x] Tests + full suite pass
