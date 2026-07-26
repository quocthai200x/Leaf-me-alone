extends GdUnitTestSuite
## Teak hardwood tank damage reduction (Story 2.8).

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


func test_teak_cost_remains_fifty() -> void:
	var teak := ContentRegistry.get_species("teak")
	assert_object(teak).is_not_null()
	assert_int(teak.plant_cost).is_equal(50)
	assert_int(ContentRegistry.get_economy().get_species_cost("teak")).is_equal(50)


func test_teak_reduces_damage_during_combat() -> void:
	RunManager.start_run(801)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "teak")
	grid.set_plant_hp(cell, 150)

	var result := _abilities.resolve_plant_hit(cell, 40)
	assert_int(result["plant_damage_taken"]).is_equal(14)
	assert_int(result["reflect_damage"]).is_equal(0)


func test_teak_no_tank_reduction_outside_combat() -> void:
	RunManager.start_run(802)
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "teak")

	var result := _abilities.resolve_plant_hit(cell, 40)
	assert_int(result["plant_damage_taken"]).is_equal(20)


func test_cashew_unaffected_by_teak_tank_logic() -> void:
	RunManager.start_run(803)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_placeable_cell(grid)
	grid.place_plant(cell, "cashew")

	var result := _abilities.resolve_plant_hit(cell, 40)
	assert_int(result["plant_damage_taken"]).is_equal(34)
	assert_int(result["reflect_damage"]).is_equal(20)


func _find_placeable_cell(grid: GridDataRes) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	return Vector2i(-1, -1)
