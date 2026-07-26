extends GdUnitTestSuite
## Care action tests (Story 2.5).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const PlantPlacementSystemScript := preload("res://scripts/systems/plant_placement_system.gd")
const CareSystemScript := preload("res://scripts/systems/care_system.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")

var _economy: EconomySystemScript
var _placement: PlantPlacementSystemScript
var _care: CareSystemScript


func before_test() -> void:
	RunManager.enter_main_menu()
	_economy = EconomySystemScript.new()
	_placement = PlantPlacementSystemScript.new()
	_care = CareSystemScript.new()
	add_child(_economy)
	add_child(_placement)
	add_child(_care)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_care):
		_care.queue_free()
	if is_instance_valid(_placement):
		_placement.queue_free()
	if is_instance_valid(_economy):
		_economy.queue_free()
	RunManager.enter_main_menu()


func test_water_reduces_dissatisfaction_and_costs_five() -> void:
	RunManager.start_run(901)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	_economy.try_earn(25)
	grid.place_plant(cell, "peanut")
	grid.set_plant_hp(cell, 50)
	grid.adjust_plant_dissatisfaction(cell, 30)

	assert_bool(_care.try_water(cell)).is_true()
	assert_int(_economy.get_balance()).is_equal(20)
	assert_int(grid.get_plant_dissatisfaction(cell)).is_equal(15)


func test_fertilize_restores_hp_and_costs_ten() -> void:
	RunManager.start_run(902)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	_economy.try_earn(30)
	grid.place_plant(cell, "peanut")
	grid.set_plant_hp(cell, 40)
	grid.adjust_plant_dissatisfaction(cell, 20)

	assert_bool(_care.try_fertilize(cell)).is_true()
	assert_int(_economy.get_balance()).is_equal(20)
	assert_int(grid.get_plant_hp(cell)).is_equal(60)
	assert_int(grid.get_plant_dissatisfaction(cell)).is_equal(10)


func test_care_rejects_empty_tile_and_insufficient_funds() -> void:
	RunManager.start_run(903)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	assert_bool(_care.try_water(cell)).is_false()

	grid.place_plant(cell, "peanut")
	assert_bool(_care.try_water(cell)).is_false()


func test_plant_cared_event_emitted() -> void:
	RunManager.start_run(904)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	_economy.try_earn(10)
	grid.place_plant(cell, "peanut")

	var capture := {"seen": false}
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.PLANT_CARED:
			var data: Dictionary = payload
			if data.get("care_type", "") == "water" and data.get("cell", Vector2i.ZERO) == cell:
				capture["seen"] = true
	EventBus.run_event.connect(handler)
	assert_bool(_care.try_water(cell)).is_true()
	await get_tree().process_frame
	EventBus.run_event.disconnect(handler)
	assert_bool(capture["seen"]).is_true()


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	return Vector2i(-1, -1)
