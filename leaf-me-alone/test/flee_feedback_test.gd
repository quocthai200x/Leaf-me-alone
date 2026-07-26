extends GdUnitTestSuite
## Mass flee feedback tests (Story 3.7).

const FleeFeedbackLogicRes := preload("res://scripts/systems/flee_feedback_logic.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const FleeFeedbackSystemScript := preload("res://scripts/systems/flee_feedback_system.gd")
const DissatisfactionSystemScript := preload("res://scripts/systems/dissatisfaction_system.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_crossed_warning_threshold_only_on_first_crossing() -> void:
	assert_bool(FleeFeedbackLogicRes.crossed_warning_threshold(49, 50)).is_true()
	assert_bool(FleeFeedbackLogicRes.crossed_warning_threshold(50, 75)).is_false()
	assert_bool(FleeFeedbackLogicRes.crossed_warning_threshold(40, 49)).is_false()


func test_mass_flee_vignette_requires_two_active_flees_or_hr() -> void:
	assert_bool(FleeFeedbackLogicRes.should_show_mass_flee_vignette(1, false)).is_false()
	assert_bool(FleeFeedbackLogicRes.should_show_mass_flee_vignette(2, false)).is_true()
	assert_bool(FleeFeedbackLogicRes.should_show_mass_flee_vignette(1, true)).is_true()


func test_resignation_toast_copy() -> void:
	assert_str(
		FleeFeedbackLogicRes.format_resignation_toast("Teak")
	).is_equal("Teak has resigned effective immediately")


func test_dissatisfaction_update_tracks_warning_crossing() -> void:
	RunManager.start_run(42)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "peanut", 80)
	var feedback := FleeFeedbackSystemScript.new()
	add_child(feedback)
	await get_tree().process_frame
	feedback._last_dissatisfaction[cell] = 49
	grid.adjust_plant_dissatisfaction(cell, 50)
	EventBus.emit_run_event(RunEventRes.Type.DISSATISFACTION_UPDATED, {})
	await get_tree().process_frame
	assert_int(feedback._last_dissatisfaction[cell]).is_equal(50)
	feedback.queue_free()


func test_flee_trigger_shows_vignette_on_mass_flee() -> void:
	var hud := preload("res://scenes/run/combat_hud.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	var dissat := DissatisfactionSystemScript.new()
	var feedback := FleeFeedbackSystemScript.new()
	add_child(dissat)
	add_child(feedback)
	await get_tree().process_frame
	dissat.active_flee_count = 2
	EventBus.emit_run_event(
		RunEventRes.Type.FLEE_TRIGGERED,
		{"cell": Vector2i(2, 2), "species_id": "teak", "dissatisfaction": 100}
	)
	await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	assert_float(hud.get_node("%FleeVignetteTop").color.a).is_greater(0.0)
	feedback.queue_free()
	dissat.queue_free()
	hud.queue_free()


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	fail("No placeable cell")
	return Vector2i.ZERO
