extends GdUnitTestSuite
## Carbon Shop clan unlock (Story 7.3).

const PlantPlacementSystemScript := preload("res://scripts/systems/plant_placement_system.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()
	SaveManager.reset_meta_for_tests()


func after_test() -> void:
	RunManager.enter_main_menu()
	SaveManager.reset_meta_for_tests()


func test_red_soil_owned_by_default() -> void:
	assert_bool(SaveManager.is_clan_unlocked("red_soil")).is_true()
	var clan = ContentRegistry.get_clan("red_soil")
	assert_object(clan).is_not_null()
	assert_int(clan.unlock_cost).is_equal(0)


func test_purchase_sand_clan_deducts_cc_and_persists() -> void:
	SaveManager.set_carbon_credit(250)
	assert_bool(SaveManager.try_purchase_clan("sand", 200)).is_true()
	assert_bool(SaveManager.is_clan_unlocked("sand")).is_true()
	assert_int(SaveManager.get_carbon_credit()).is_equal(50)


func test_purchase_fails_when_unaffordable() -> void:
	SaveManager.set_carbon_credit(50)
	assert_bool(SaveManager.try_purchase_clan("sand", 200)).is_false()
	assert_bool(SaveManager.is_clan_unlocked("sand")).is_false()
	assert_int(SaveManager.get_clan_shortfall(200)).is_equal(150)


func test_clans_catalog_loads() -> void:
	assert_array(ContentRegistry.get_all_clan_ids()).contains("red_soil")
	assert_array(ContentRegistry.get_all_clan_ids()).contains("sand")
