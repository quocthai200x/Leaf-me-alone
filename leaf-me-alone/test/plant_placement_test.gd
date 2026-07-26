extends GdUnitTestSuite
## Plant catalog placement validation (Story 2.4).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const PlantPlacementSystemScript := preload("res://scripts/systems/plant_placement_system.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")

var _economy: EconomySystemScript
var _placement: PlantPlacementSystemScript


func before_test() -> void:
	RunManager.enter_main_menu()
	_economy = EconomySystemScript.new()
	_placement = PlantPlacementSystemScript.new()
	add_child(_economy)
	add_child(_placement)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_placement):
		_placement.queue_free()
	if is_instance_valid(_economy):
		_economy.queue_free()
	RunManager.enter_main_menu()


func test_can_place_only_on_red_unoccupied_soil() -> void:
	RunManager.start_run(777)
	var grid := RunManager.grid_data

	var red_cell := _find_placeable_cell(grid)
	assert_vector(red_cell).is_not_equal(Vector2i(-1, -1))
	assert_bool(grid.can_place_plant(red_cell)).is_true()

	var rock_cell := _find_soil_cell(grid, SoilTypeRes.Type.ROCK)
	assert_bool(grid.can_place_plant(rock_cell)).is_false()

	grid.place_plant(red_cell, "peanut")
	assert_bool(grid.can_place_plant(red_cell)).is_false()


func test_try_place_deducts_dogecoin_and_emits_event() -> void:
	RunManager.start_run(888)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	assert_vector(cell).is_not_equal(Vector2i(-1, -1))

	_economy.try_earn(20)
	var capture := {"seen": false}
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.PLANT_PLACED:
			var data: Dictionary = payload
			if data.get("species_id", "") == "peanut" and data.get("cell", Vector2i.ZERO) == cell:
				capture["seen"] = true
	EventBus.run_event.connect(handler)

	assert_bool(_placement.try_place_plant(cell, "peanut")).is_true()
	assert_int(_economy.get_balance()).is_equal(0)
	assert_str(grid.get_plant_species_id(cell)).is_equal("peanut")

	await get_tree().process_frame
	EventBus.run_event.disconnect(handler)
	assert_bool(capture["seen"]).is_true()


func test_try_place_rejects_insufficient_funds() -> void:
	RunManager.start_run(889)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	assert_bool(_placement.try_place_plant(cell, "peanut")).is_false()
	assert_str(grid.get_plant_species_id(cell)).is_empty()


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	return Vector2i(-1, -1)


func _find_soil_cell(grid: GridDataRes, soil: int) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.get_soil_type(pos) == soil:
				return pos
	return Vector2i(-1, -1)
