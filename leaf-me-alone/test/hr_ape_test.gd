extends GdUnitTestSuite
## HR Ape flee threshold modifier and death drops (Story 4.4).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const FleeFeedbackLogicRes := preload("res://scripts/systems/flee_feedback_logic.gd")
const DissatisfactionThresholdRes := preload("res://scripts/systems/dissatisfaction_threshold.gd")
const HrApeSystemScript := preload("res://scripts/systems/hr_ape_system.gd")
const DissatisfactionSystemScript := preload("res://scripts/systems/dissatisfaction_system.gd")
const ApeBaseScene := preload("res://scenes/entities/ape_base.tscn")
const ApePoolScript := preload("res://scripts/systems/ape_pool.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const MapViewScene := preload("res://scenes/run/map_view.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_hr_ape_system_registers_modifier_near_plant() -> void:
	RunManager.start_run(4401)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var plant_cell := _find_red_cell(grid)
	grid.place_plant(plant_cell, "peanut", 80)

	var dissat := DissatisfactionSystemScript.new()
	add_child(dissat)
	var hr_system := HrApeSystemScript.new()
	add_child(hr_system)
	await get_tree().process_frame

	var ape: Node2D = ApeBaseScene.instantiate()
	add_child(ape)
	var role := ContentRegistry.get_ape("hr_ape")
	ape.configure(role, plant_cell + Vector2i(1, 0), 1.0, 1.0)
	ape.state = ape.State.ACT

	# Simulate active ape in pool group via manual modifier registration path.
	dissat.clear_hr_modifiers()
	dissat.register_hr_modifier(ape.grid_cell)
	var hr_mods := dissat.get_hr_modifiers()
	var threshold := DissatisfactionThresholdRes.get_flee_threshold(
		ContentRegistry.get_species("peanut"), plant_cell, hr_mods
	)
	assert_int(threshold).is_equal(GameConstantsRes.HR_FLEE_THRESHOLD)

	ape.queue_free()
	hr_system.queue_free()
	dissat.queue_free()


func test_hr_drop_awards_fifteen_dogecoin_on_kill() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var economy := EconomySystemScript.new()
	add_child(economy)
	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	RunManager.start_run(4402)
	RunManager.begin_combat_wave()
	assert_int(economy.get_balance()).is_equal(0)

	var ape: Node2D = ApeBaseScene.instantiate()
	map_view.get_node("Entities").add_child(ape)
	var role := ContentRegistry.get_ape("hr_ape")
	ape.configure(role, Vector2i(3, 3), 1.0, 1.0)
	ape.visible = true
	ape.state = ape.State.ACT

	ape_pool.kill_ape(ape)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(15)

	ape_pool.queue_free()
	economy.queue_free()
	map_view.queue_free()


func test_hr_dogecoin_drop_constant() -> void:
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("hr_ape")).is_equal(15)


func test_hr_sting_respects_five_second_cooldown() -> void:
	assert_bool(FleeFeedbackLogicRes.should_play_hr_sting(-1.0, 10.0)).is_true()
	assert_bool(FleeFeedbackLogicRes.should_play_hr_sting(10.0, 12.0)).is_false()
	assert_bool(FleeFeedbackLogicRes.should_play_hr_sting(10.0, 15.0)).is_true()


func _find_red_cell(grid: GridData) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	fail("No placeable cell found")
	return Vector2i.ZERO
