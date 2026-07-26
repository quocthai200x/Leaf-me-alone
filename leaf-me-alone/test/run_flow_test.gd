extends GdUnitTestSuite
## Integration test: run start → combat wave 1 → pause after timer (Story 1.9).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const FIXTURE_PATH := "res://test/fixtures/run_seed_001.json"


func before_test() -> void:
	RunManager.enter_main_menu()


func test_play_combat_pause_transition() -> void:
	var fixture := _load_fixture()
	var seed_value := int(fixture.get("master_seed", 0))
	assert_int(seed_value).is_greater(0)

	var grid: GridDataRes = RunManager.start_run(seed_value)
	assert_object(grid).is_not_null()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
	assert_int(RunManager.run_state.dogecoin).is_equal(0)
	assert_int(grid.compute_layout_hash()).is_equal(int(str(fixture.get("expected_layout_hash", "0"))))
	assert_int(grid.count_soil(SoilTypeRes.Type.RED)).is_equal(int(fixture.get("expected_red_soil_count", 0)))

	assert_bool(RunManager.begin_combat_wave()).is_true()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CombatPhase)
	assert_int(RunManager.run_state.wave_index).is_equal(1)

	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
	assert_str(RunStateEnumRes.State.keys()[RunManager.get_state()]).is_equal(
		str(fixture.get("wave_1_combat_end_state", "PausePhase"))
	)


func _load_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	assert_object(file).override_failure_message("Missing golden fixture: %s" % FIXTURE_PATH).is_not_null()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_object(parsed).override_failure_message("Invalid JSON in fixture").is_not_null()
	return parsed as Dictionary
