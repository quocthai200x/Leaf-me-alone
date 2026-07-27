extends GdUnitTestSuite
## PR Ape billboard AoE and death drops (Story 4.5).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const PrBillboardLogicRes := preload("res://scripts/systems/pr_billboard_logic.gd")
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


func test_billboard_aoe_covers_adjacent_plant() -> void:
	var boards := [{"center": Vector2i(5, 5), "radius": 3}]
	assert_bool(PrBillboardLogicRes.is_in_aoe(Vector2i(6, 5), boards)).is_true()
	assert_bool(PrBillboardLogicRes.is_in_aoe(Vector2i(9, 5), boards)).is_false()


func test_billboard_increases_plant_dissatisfaction() -> void:
	RunManager.start_run(5501)
	RunManager.begin_combat_wave()
	var grid := RunManager.grid_data
	var cell := _find_red_cell(grid)
	grid.place_plant(cell, "peanut", 80)
	var before := grid.get_plant_dissatisfaction(cell)

	var dissat := DissatisfactionSystemScript.new()
	add_child(dissat)
	dissat.register_billboard(cell)
	dissat._apply_billboard_dissatisfaction()

	assert_int(grid.get_plant_dissatisfaction(cell)).is_equal(
		before + GameConstantsRes.PR_BILLBOARD_DISSATISFACTION_DELTA
	)
	dissat.queue_free()


func test_pr_drop_awards_twelve_dogecoin_on_kill() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var economy := EconomySystemScript.new()
	add_child(economy)
	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	RunManager.start_run(5502)
	RunManager.begin_combat_wave()
	assert_int(economy.get_balance()).is_equal(0)

	var ape: Node2D = ApeBaseScene.instantiate()
	map_view.get_node("Entities").add_child(ape)
	var role := ContentRegistry.get_ape("pr_ape")
	ape.configure(role, Vector2i(4, 4), 1.0, 1.0)
	ape.visible = true
	ape.state = ape.State.ACT

	ape_pool.kill_ape(ape)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(12)

	ape_pool.queue_free()
	economy.queue_free()
	map_view.queue_free()


func test_pr_dogecoin_drop_constant() -> void:
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("pr_ape")).is_equal(12)


func _find_red_cell(grid: GridData) -> Vector2i:
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.can_place_plant(pos):
				return pos
	fail("No placeable cell found")
	return Vector2i.ZERO
