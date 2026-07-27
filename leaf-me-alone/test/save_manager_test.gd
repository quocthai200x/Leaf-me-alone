extends GdUnitTestSuite
## Unit tests for SaveManager meta persistence (Story 7.1).

const META_SAVE_PATH := "user://save/meta.json"


func before_test() -> void:
	SaveManager.reset_meta_for_tests()


func after_test() -> void:
	SaveManager.reset_meta_for_tests()


func test_default_meta_includes_red_soil_clan() -> void:
	assert_int(SaveManager.get_carbon_credit()).is_equal(0)
	assert_bool(SaveManager.is_clan_unlocked("red_soil")).is_true()
	assert_array(SaveManager.get_unlocked_clans()).contains("red_soil")


func test_save_load_roundtrip() -> void:
	SaveManager.set_carbon_credit(250)
	SaveManager.unlock_clan("tropical")
	assert_bool(SaveManager.save_meta()).is_true()

	var file := FileAccess.open(META_SAVE_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_dict(parsed).is_not_null()
	assert_int(int(parsed.get("carbon_credit", -1))).is_equal(250)
	assert_array(parsed.get("unlocked_clans", [])).contains("red_soil")
	assert_array(parsed.get("unlocked_clans", [])).contains("tropical")
	assert_bool(parsed.has("dogecoin")).is_false()


func test_invalid_json_returns_defaults() -> void:
	SaveManager.save_meta()
	var file := FileAccess.open(META_SAVE_PATH, FileAccess.WRITE)
	assert_object(file).is_not_null()
	file.store_string("{not valid json")
	file.close()

	SaveManager.reload_from_disk_for_tests()
	assert_int(SaveManager.get_carbon_credit()).is_equal(0)
	assert_bool(SaveManager.is_clan_unlocked("red_soil")).is_true()


func test_rejects_dogecoin_in_save_payload() -> void:
	var bad_payload := {
		"version": 1,
		"carbon_credit": 10,
		"dogecoin": 999,
		"unlocked_clans": ["red_soil"],
		"settings": {},
	}
	assert_bool(SaveManager.save(bad_payload)).is_false()


func test_hundred_load_save_cycles_without_corruption() -> void:
	for i in range(100):
		SaveManager.set_carbon_credit(i * 3)
		if i % 10 == 0:
			SaveManager.unlock_clan("clan_%d" % i)
		assert_bool(SaveManager.save_meta()).is_true()

		var file := FileAccess.open(META_SAVE_PATH, FileAccess.READ)
		assert_object(file).override_failure_message("cycle %d: save file missing" % i).is_not_null()
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		assert_dict(parsed).override_failure_message("cycle %d: invalid JSON" % i).is_not_null()
		assert_int(int(parsed.get("carbon_credit", -1))).is_equal(i * 3)
		assert_bool(parsed.has("dogecoin")).is_false()

		SaveManager.reload_from_disk_for_tests()
		assert_int(SaveManager.get_carbon_credit()).is_equal(i * 3)


func test_settings_roundtrip() -> void:
	SaveManager.set_setting("master_volume", 0.75)
	SaveManager.set_setting("sfx_volume", 0.5)
	assert_float(SaveManager.get_settings().get("master_volume", 0.0)).is_equal(0.75)
	assert_float(SaveManager.get_settings().get("sfx_volume", 0.0)).is_equal(0.5)
