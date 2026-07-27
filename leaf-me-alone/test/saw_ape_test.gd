extends GdUnitTestSuite
## Saw Ape extraction and death drops (Story 4.3).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const SawExtractionLogicRes := preload("res://scripts/systems/saw_extraction_logic.gd")
const PlantAbilitySystemScript := preload("res://scripts/systems/plant_ability_system.gd")
const ApeBaseScene := preload("res://scenes/entities/ape_base.tscn")
const ApePoolScript := preload("res://scripts/systems/ape_pool.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const MapViewScene := preload("res://scenes/run/map_view.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_saw_extract_damages_plant_hp() -> void:
	RunManager.start_run(42)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "peanut", 80)
	var abilities := PlantAbilitySystemScript.new()
	add_child(abilities)
	await get_tree().process_frame

	var result := SawExtractionLogicRes.apply_extract_tick(
		abilities, cell, GameConstantsRes.SAW_EXTRACT_DAMAGE
	)
	assert_bool(result.get("plant_damaged", false)).is_true()
	assert_int(grid.get_plant_hp(cell)).is_less(80)
	abilities.queue_free()


func test_saw_extract_depletes_plant_at_zero_hp() -> void:
	RunManager.start_run(43)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "peanut", 5)
	grid.set_plant_hp(cell, 5)
	var abilities := PlantAbilitySystemScript.new()
	add_child(abilities)
	await get_tree().process_frame

	var result := SawExtractionLogicRes.apply_extract_tick(
		abilities, cell, GameConstantsRes.SAW_EXTRACT_DAMAGE
	)
	assert_bool(result.get("tile_depleted", false)).is_true()
	assert_bool(grid.is_depleted(cell)).is_true()
	assert_bool(grid.has_plant(cell)).is_false()
	abilities.queue_free()


func test_cashew_reflect_kills_saw_via_take_damage() -> void:
	RunManager.start_run(901)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "cashew", 90)
	grid.set_plant_hp(cell, 90)

	var abilities := PlantAbilitySystemScript.new()
	add_child(abilities)
	var ape: Node2D = ApeBaseScene.instantiate()
	add_child(ape)
	var role := ContentRegistry.get_ape("saw_ape")
	ape.configure(role, cell, 1.0, 1.0)
	ape.max_hp = 8
	ape.current_hp = 8
	ape.state = ape.State.ACT

	var result := SawExtractionLogicRes.apply_extract_tick(
		abilities, cell, GameConstantsRes.SAW_EXTRACT_DAMAGE
	)
	var reflect := int(result.get("reflect_damage", 0))
	assert_int(reflect).is_greater(0)
	ape.take_damage(reflect)
	assert_int(ape.current_hp).is_less_equal(0)
	ape.queue_free()
	abilities.queue_free()


func test_saw_drop_awards_five_dogecoin_on_kill() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var economy := EconomySystemScript.new()
	add_child(economy)
	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	RunManager.start_run(902)
	RunManager.begin_combat_wave()
	assert_int(economy.get_balance()).is_equal(0)

	var ape: Node2D = ApeBaseScene.instantiate()
	map_view.get_node("Entities").add_child(ape)
	var role := ContentRegistry.get_ape("saw_ape")
	ape.configure(role, Vector2i(2, 2), 1.0, 1.0)
	ape.visible = true
	ape.state = ape.State.ACT

	ape_pool.kill_ape(ape)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(5)

	ape_pool.queue_free()
	economy.queue_free()
	map_view.queue_free()


func test_saw_dogecoin_drop_constant() -> void:
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("saw_ape")).is_equal(5)


func _find_red_cell(grid: GridData) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	fail("No placeable cell found")
	return Vector2i.ZERO
