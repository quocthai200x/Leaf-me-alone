extends GdUnitTestSuite
## Settings and achievements stubs (Story 7.5).

const SettingsLogicRes := preload("res://scripts/utils/settings_logic.gd")
const AchievementCatalogRes := preload("res://scripts/data/achievement_catalog.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	SaveManager.reset_meta_for_tests()


func after_test() -> void:
	RunManager.enter_main_menu()
	SaveManager.reset_meta_for_tests()
	SettingsLogicRes.apply_audio_settings(SaveManager.get_settings())


func test_settings_persist_master_and_sfx_volume() -> void:
	SaveManager.set_setting("master_volume", 0.75)
	SaveManager.set_setting("sfx_volume", 0.5)
	assert_float(SaveManager.get_settings().get("master_volume", 0.0)).is_equal(0.75)
	assert_float(SaveManager.get_settings().get("sfx_volume", 0.0)).is_equal(0.5)


func test_linear_to_bus_db_mutes_at_zero() -> void:
	assert_float(SettingsLogicRes.linear_to_bus_db(0.0)).is_equal(SettingsLogicRes.MUTE_DB)


func test_apply_audio_settings_sets_bus_indices() -> void:
	var master_idx := AudioServer.get_bus_index(&"Master")
	var sfx_idx := AudioServer.get_bus_index(&"SFX")
	assert_int(master_idx).is_greater_equal(0)
	assert_int(sfx_idx).is_greater_equal(0)
	SettingsLogicRes.apply_audio_settings({"master_volume": 0.5, "sfx_volume": 0.25})
	var expected_master := SettingsLogicRes.linear_to_bus_db(0.5)
	var expected_sfx := SettingsLogicRes.linear_to_bus_db(0.25)
	assert_float(AudioServer.get_bus_volume_db(master_idx)).is_equal_approx(expected_master, 0.001)
	assert_float(AudioServer.get_bus_volume_db(sfx_idx)).is_equal_approx(expected_sfx, 0.001)


func test_achievement_catalog_loads_locked_entries() -> void:
	var entries := AchievementCatalogRes.load_locked_entries()
	assert_int(entries.size()).is_greater_equal(3)
	for entry in entries:
		assert_str(entry.get("title", "")).is_not_empty()
