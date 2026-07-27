# Story 7.3: Carbon Shop Stub and Clan Unlock

Status: done

## Dev Agent Record

### Completion Notes List

- Carbon Shop overlay on Main Menu with clan rows, CC balance, unlock purchase
- `data/clans.json` — red_soil (default), sand (200 CC stub)
- `SaveManager.try_purchase_clan()` with shortfall helper
- Plant placement gated by unlocked clan; pause catalog filters locked species

### File List

- leaf-me-alone/data/clans.json
- leaf-me-alone/scripts/data/clan_def.gd
- leaf-me-alone/autoload/content_registry.gd
- leaf-me-alone/autoload/save_manager.gd
- leaf-me-alone/scripts/data/species_def.gd
- leaf-me-alone/scripts/systems/plant_placement_system.gd
- leaf-me-alone/scenes/main/carbon_shop.gd
- leaf-me-alone/scenes/main/carbon_shop.tscn
- leaf-me-alone/scenes/main/main_menu.gd
- leaf-me-alone/scenes/main/main_menu.tscn
- leaf-me-alone/scenes/run/pause_panel.gd
- leaf-me-alone/test/carbon_shop_test.gd

## Senior Developer Review (AI)

**Review Outcome:** Approve
