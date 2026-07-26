extends GdUnitTestSuite
## Flee sequence tests (Story 3.4).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const FleeSequenceSystemScript := preload("res://scripts/systems/flee_sequence_system.gd")
const DissatisfactionSystemScript := preload("res://scripts/systems/dissatisfaction_system.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_remove_plant_from_combat_clears_grid_plant() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(7)
	var cell := Vector2i(5, 5)
	if not grid.can_place_plant(cell):
		for y in grid.height:
			for x in grid.width:
				var pos := Vector2i(x, y)
				if grid.can_place_plant(pos):
					cell = pos
					break
	grid.place_plant(cell, "peanut", 80)
	assert_bool(grid.remove_plant_from_combat(cell)).is_true()
	assert_bool(grid.has_plant(cell)).is_false()
	assert_bool(bool(grid.get_cell(cell).get("occupied", true))).is_false()


func test_flee_sequence_emits_plant_fled_and_clears_plant() -> void:
	RunManager.start_run(300)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "cashew", 90)
	var dissat := DissatisfactionSystemScript.new()
	var flee := FleeSequenceSystemScript.new()
	add_child(dissat)
	add_child(flee)
	await get_tree().process_frame
	var fled_events: Array = []
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.PLANT_FLED:
			fled_events.append(payload)
	EventBus.run_event.connect(handler)
	EventBus.emit_run_event(
		RunEventRes.Type.FLEE_TRIGGERED,
		{"cell": cell, "species_id": "cashew", "dissatisfaction": 100}
	)
	await get_tree().create_timer(0.2).timeout
	assert_int(fled_events.size()).is_equal(1)
	assert_bool(grid.has_plant(cell)).is_false()
	EventBus.run_event.disconnect(handler)
	flee.queue_free()
	dissat.queue_free()


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	fail("No placeable cell")
	return Vector2i.ZERO
