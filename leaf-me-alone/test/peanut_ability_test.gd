extends GdUnitTestSuite
## Peanut N-fixation buff and allelopathy slow (Story 2.6).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const PlantAbilitySystemScript := preload("res://scripts/systems/plant_ability_system.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

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


func test_peanut_cost_remains_twenty() -> void:
	var peanut := ContentRegistry.get_species("peanut")
	assert_object(peanut).is_not_null()
	assert_int(peanut.plant_cost).is_equal(20)
	var economy := ContentRegistry.get_economy()
	assert_int(economy.get_species_cost("peanut")).is_equal(20)


func test_adjacent_plant_gets_n_fixation_buff_in_combat() -> void:
	RunManager.start_run(601)
	var grid := RunManager.grid_data
	var pair := _find_adjacent_placeable_pair(grid)
	assert_vector(pair[0]).is_not_equal(Vector2i(-1, -1))
	var peanut_cell: Vector2i = pair[0]
	var ally_cell: Vector2i = pair[1]

	grid.place_plant(peanut_cell, "peanut")
	grid.place_plant(ally_cell, "cashew")
	grid.set_plant_hp(ally_cell, 90)
	RunManager.begin_combat_wave()

	var base_cashew := ContentRegistry.get_species("cashew")
	var stats := _abilities.get_combat_stats(ally_cell)
	assert_int(stats["attack"]).is_equal(roundi(base_cashew.attack * 1.15))
	assert_int(stats["defense"]).is_equal(roundi(base_cashew.defense * 1.10))


func test_peanut_without_combat_has_base_stats() -> void:
	RunManager.start_run(602)
	var grid := RunManager.grid_data
	var pair := _find_adjacent_placeable_pair(grid)
	var peanut_cell: Vector2i = pair[0]
	var ally_cell: Vector2i = pair[1]
	grid.place_plant(peanut_cell, "peanut")
	grid.place_plant(ally_cell, "cashew")

	var base_cashew := ContentRegistry.get_species("cashew")
	var stats := _abilities.get_combat_stats(ally_cell)
	assert_int(stats["attack"]).is_equal(base_cashew.attack)
	assert_int(stats["defense"]).is_equal(base_cashew.defense)


func test_ape_slowed_near_peanut_during_combat() -> void:
	RunManager.start_run(603)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var peanut_cell := _find_placeable_cell(grid)
	grid.place_plant(peanut_cell, "peanut")

	var slow_mult := _abilities.get_ape_move_speed_multiplier(peanut_cell)
	assert_float(slow_mult).is_equal(0.75)


func test_ape_not_slowed_far_from_peanut() -> void:
	RunManager.start_run(604)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var peanut_cell := _find_placeable_cell(grid)
	grid.place_plant(peanut_cell, "peanut")

	var far_cell := peanut_cell + Vector2i(5, 5)
	if not grid.is_in_bounds(far_cell):
		far_cell = Vector2i(0, 0)
	var slow_mult := _abilities.get_ape_move_speed_multiplier(far_cell)
	assert_float(slow_mult).is_equal(1.0)


func _find_adjacent_placeable_pair(grid: GridDataRes) -> Array:
	var offsets: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	]
	for y in grid.height:
		for x in grid.width:
			var a := Vector2i(x, y)
			if not grid.can_place_plant(a):
				continue
			for offset in offsets:
				var b := a + offset
				if grid.can_place_plant(b):
					return [a, b]
	return [Vector2i(-1, -1), Vector2i(-1, -1)]


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	return Vector2i(-1, -1)
