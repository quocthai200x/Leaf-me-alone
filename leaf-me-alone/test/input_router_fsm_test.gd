extends GdUnitTestSuite
## InputRouter InteractionMode FSM tests (Story 2.3).

const InteractionModeRes := preload("res://scripts/input/interaction_mode.gd")
const InputRouterScript := preload("res://scripts/input/input_router.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

var _router: InputRouterScript


func before_test() -> void:
	RunManager.enter_main_menu()
	_router = InputRouterScript.new()
	add_child(_router)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_router):
		_router.queue_free()
	RunManager.enter_main_menu()


func test_select_species_enters_place_plant_in_pause() -> void:
	RunManager.start_run(101)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": "peanut"}
	)
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.PLACE_PLANT)
	assert_str(_router.get_selected_species_id()).is_equal("peanut")


func test_select_care_enters_care_mode() -> void:
	RunManager.start_run(102)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_care"}
	)
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.CARE)
	assert_str(_router.get_selected_species_id()).is_empty()


func test_cancel_placement_intent_returns_idle() -> void:
	RunManager.start_run(103)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": "cashew"}
	)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "cancel_placement"}
	)
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.IDLE)


func test_ui_intent_ignored_during_combat() -> void:
	RunManager.start_run(104)
	RunManager.begin_combat_wave()
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.IDLE)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": "teak"}
	)
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.IDLE)


func test_combat_transition_resets_place_plant_mode() -> void:
	RunManager.start_run(105)
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": "peanut"}
	)
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.PLACE_PLANT)
	RunManager.begin_combat_wave()
	assert_int(_router.get_mode()).is_equal(InteractionModeRes.Mode.IDLE)
