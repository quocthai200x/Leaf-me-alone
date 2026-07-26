extends GdUnitTestSuite
## Dissatisfaction multi-cause logic tests (Story 3.1).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const SpeciesDefRes := preload("res://scripts/data/species_def.gd")
const DissatisfactionCauseLogicRes := preload(
	"res://scripts/systems/dissatisfaction_cause_logic.gd"
)
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const DissatisfactionSystemScript := preload(
	"res://scripts/systems/dissatisfaction_system.gd"
)
const DissatisfactionThresholdRes := preload(
	"res://scripts/systems/dissatisfaction_threshold.gd"
)
const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_soil_mismatch_increases_dissatisfaction_delta() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	var cell := _find_red_cell(grid)
	assert_bool(grid.place_plant(cell, "peanut", 80)).is_true()
	grid.set_cell_soil(cell, SoilTypeRes.Type.SAND)
	var species := ContentRegistry.get_species("peanut")
	assert_bool(DissatisfactionCauseLogicRes.has_soil_mismatch(grid, cell, species)).is_true()
	var delta := DissatisfactionCauseLogicRes.compute_environmental_delta(
		grid, cell, species, "tropical_sun"
	)
	assert_int(delta).is_equal(GameConstantsRes.DISSATISFACTION_SOIL_MISMATCH_DELTA)


func test_allelopathic_neighbor_increases_dissatisfaction_delta() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	var red_a := _find_red_cell(grid)
	var red_b := red_a + Vector2i(1, 0)
	if not grid.is_in_bounds(red_b) or grid.get_soil_type(red_b) != SoilTypeRes.Type.RED:
		red_b = red_a + Vector2i(0, 1)
	grid.place_plant(red_a, "peanut", 80)
	grid.place_plant(red_b, "cashew", 90)
	assert_bool(DissatisfactionCauseLogicRes.has_allelopathic_neighbor(grid, red_b)).is_true()
	var cashew := ContentRegistry.get_species("cashew")
	var delta := DissatisfactionCauseLogicRes.compute_environmental_delta(
		grid, red_b, cashew, "tropical_rain"
	)
	assert_int(delta).is_equal(GameConstantsRes.DISSATISFACTION_ALLELOPATHY_DELTA)


func test_weather_mismatch_increases_dissatisfaction_delta() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "cashew", 90)
	var cashew := ContentRegistry.get_species("cashew")
	assert_bool(
		DissatisfactionCauseLogicRes.has_weather_mismatch(cashew, "tropical_sun")
	).is_true()
	var delta := DissatisfactionCauseLogicRes.compute_environmental_delta(
		grid, cell, cashew, "tropical_sun"
	)
	assert_int(delta).is_equal(GameConstantsRes.DISSATISFACTION_WEATHER_MISMATCH_DELTA)


func test_missed_care_applies_twenty_five_per_unaddressed_cause() -> void:
	assert_int(
		DissatisfactionCauseLogicRes.compute_missed_care_delta(false, false)
	).is_equal(50)
	assert_int(
		DissatisfactionCauseLogicRes.compute_missed_care_delta(true, false)
	).is_equal(25)
	assert_int(
		DissatisfactionCauseLogicRes.compute_missed_care_delta(true, true)
	).is_equal(0)


func test_dissatisfaction_system_applies_missed_care_on_pause_to_combat() -> void:
	RunManager.start_run(100)
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "peanut", 80)
	var dissat := DissatisfactionSystemScript.new()
	add_child(dissat)
	await get_tree().process_frame
	EventBus.emit_run_event(
		RunEventRes.Type.STATE_CHANGED,
		{"from": RunStateEnumRes.State.MainMenu, "to": RunStateEnumRes.State.PausePhase}
	)
	await get_tree().process_frame
	EventBus.emit_run_event(
		RunEventRes.Type.STATE_CHANGED,
		{"from": RunStateEnumRes.State.PausePhase, "to": RunStateEnumRes.State.CombatPhase}
	)
	await get_tree().process_frame
	assert_int(grid.get_plant_dissatisfaction(cell)).is_equal(50)
	dissat.queue_free()


func test_standard_flee_threshold_is_one_hundred() -> void:
	var cashew := ContentRegistry.get_species("cashew")
	var threshold := DissatisfactionThresholdRes.get_flee_threshold(
		cashew, Vector2i(5, 5), []
	)
	assert_int(threshold).is_equal(GameConstantsRes.STANDARD_FLEE_THRESHOLD)


func test_sensitive_species_flee_threshold_is_seventy_five() -> void:
	var peanut := ContentRegistry.get_species("peanut")
	var threshold := DissatisfactionThresholdRes.get_flee_threshold(
		peanut, Vector2i(5, 5), []
	)
	assert_int(threshold).is_equal(GameConstantsRes.SENSITIVE_FLEE_THRESHOLD)


func test_hr_modifier_lowers_threshold_to_fifty() -> void:
	var cashew := ContentRegistry.get_species("cashew")
	var hr_mods := [{"center": Vector2i(5, 5), "radius": 3}]
	var threshold := DissatisfactionThresholdRes.get_flee_threshold(
		cashew, Vector2i(6, 5), hr_mods
	)
	assert_int(threshold).is_equal(GameConstantsRes.HR_FLEE_THRESHOLD)


func test_should_flee_at_threshold() -> void:
	assert_bool(DissatisfactionThresholdRes.should_flee(100, 100)).is_true()
	assert_bool(DissatisfactionThresholdRes.should_flee(99, 100)).is_false()


func test_trigger_flee_emits_event_and_tracks_active_count() -> void:
	var dissat := DissatisfactionSystemScript.new()
	add_child(dissat)
	await get_tree().process_frame
	RunManager.start_run(200)
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "cashew", 90)
	var flee_events: Array = []
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.FLEE_TRIGGERED:
			flee_events.append(payload)
	EventBus.run_event.connect(handler)
	dissat.trigger_flee(cell)
	assert_int(flee_events.size()).is_equal(1)
	assert_str(str((flee_events[0] as Dictionary).get("species_id"))).is_equal("cashew")
	assert_int(dissat.active_flee_count).is_equal(1)
	dissat.notify_flee_completed(cell)
	assert_int(dissat.active_flee_count).is_equal(0)
	EventBus.run_event.disconnect(handler)
	dissat.queue_free()


func _find_red_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.get_soil_type(pos) == SoilTypeRes.Type.RED and grid.can_place_plant(pos):
				return pos
	fail("No red placeable cell found")
	return Vector2i.ZERO
