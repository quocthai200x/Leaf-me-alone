extends GdUnitTestSuite
## Run End logic and transitions (Stories 5.3, 5.5, 5.6).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const RunEndLogicRes := preload("res://scripts/systems/run_end_logic.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_loss_copy_default() -> void:
	var copy := RunEndLogicRes.get_outcome_copy("loss", "forest_core_destroyed")
	assert_str(copy).contains("Forest Core terminated")


func test_win_copy() -> void:
	var copy := RunEndLogicRes.get_outcome_copy("win", "")
	assert_str(copy).contains("quarterly review")


func test_cc_preview_loss_caps_at_eighty() -> void:
	assert_int(RunEndLogicRes.compute_cc_preview("loss", 0)).is_equal(20)
	assert_int(RunEndLogicRes.compute_cc_preview("loss", 5)).is_equal(80)


func test_cc_preview_win() -> void:
	assert_int(RunEndLogicRes.compute_cc_preview("win", 5)).is_equal(GameConstantsRes.RUN_END_CC_WIN_PREVIEW)


func test_declare_run_win_on_wave_five() -> void:
	RunManager.start_run(555)
	for _i in GameConstantsRes.MAX_COMBAT_WAVES:
		RunManager.begin_combat_wave()
	RunManager.run_state.director_defeated = true
	RunManager.declare_run_win()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.RunEnd)
	assert_str(RunManager.run_state.run_outcome).is_equal("win")


func test_reset_allowed_from_run_end() -> void:
	RunManager.start_run(556)
	RunManager.begin_combat_wave()
	RunManager.declare_run_loss("forest_core_destroyed")
	assert_bool(RunManager.get_state() == RunStateEnumRes.State.RunEnd).is_true()
	RunManager.reset()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.MainMenu)
