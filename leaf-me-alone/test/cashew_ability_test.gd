extends GdUnitTestSuite
## Cashew anacardic reflect damage (Story 2.7).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const PlantAbilitySystemScript := preload("res://scripts/systems/plant_ability_system.gd")

var _abilities: PlantAbilitySystemScript


func before_test() -> void:
	RunManager.enter_main_menu()
	_abilities = PlantAbilitySystemScript.new()
	add_child(_abilities)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_abilities):
		_abilities.queue_free()
	RunManager.enter_main_menu()


func test_cashew_cost_remains_thirty_five() -> void:
	var cashew := ContentRegistry.get_species("cashew")
	assert_object(cashew).is_not_null()
	assert_int(cashew.plant_cost).is_equal(35)
	var economy := ContentRegistry.get_economy()
	assert_int(economy.get_species_cost("cashew")).is_equal(35)


func test_cashew_reflects_damage_during_combat() -> void:
	RunManager.start_run(701)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "cashew")
	grid.set_plant_hp(cell, 90)

	var result := _abilities.resolve_plant_hit(cell, 20)
	assert_int(result["plant_damage_taken"]).is_equal(14)
	assert_int(result["reflect_damage"]).is_equal(10)


func test_cashew_no_reflect_outside_combat() -> void:
	RunManager.start_run(702)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "cashew")

	var result := _abilities.resolve_plant_hit(cell, 20)
	assert_int(result["plant_damage_taken"]).is_equal(14)
	assert_int(result["reflect_damage"]).is_equal(0)


func test_non_cashew_plant_has_no_reflect() -> void:
	RunManager.start_run(703)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "peanut")

	var result := _abilities.resolve_plant_hit(cell, 20)
	assert_int(result["reflect_damage"]).is_equal(0)


func test_empty_cell_returns_zero_damage() -> void:
	RunManager.start_run(704)
	RunManager.begin_combat_wave()
	var result := _abilities.resolve_plant_hit(Vector2i(-1, -1), 20)
	assert_int(result["plant_damage_taken"]).is_equal(0)
	assert_int(result["reflect_damage"]).is_equal(0)


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	return Vector2i(-1, -1)
