extends GdUnitTestSuite
## PathfindingService A* tests (Story 4.1).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const PathfindingServiceScript := preload("res://scripts/systems/pathfinding_service.gd")
const FIXTURE_PATH := "res://test/fixtures/run_seed_001.json"


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_astar_path_exists_on_walkable_tiles() -> void:
	var grid := _grid_from_fixture()
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	pathfinding.initialize_from_grid(grid)

	var start := _find_walkable_cell(grid, Vector2i(0, 0))
	var goal := _find_walkable_cell(grid, Vector2i(grid.width - 1, grid.height - 1))
	var route: PackedVector2Array = pathfinding.find_path(start, goal)
	assert_int(route.size()).is_greater(0)
	if route.size() > 0:
		assert_vector(route[0]).is_equal(Vector2(start))
	pathfinding.queue_free()


func test_plant_fled_blocks_cell_incrementally() -> void:
	var grid := _grid_from_fixture()
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	pathfinding.initialize_from_grid(grid)
	await get_tree().process_frame

	var cell := _find_walkable_cell(grid, Vector2i(grid.width / 2, grid.height / 2))
	grid.place_plant(cell, "peanut", 80)
	pathfinding.initialize_from_grid(grid)

	var north := cell + Vector2i(0, -1)
	if not grid.is_in_bounds(north) or _is_cell_impassable(grid, north):
		pathfinding.queue_free()
		return

	assert_int(pathfinding.find_path(north, cell).size()).is_greater(0)

	grid.set_depleted_after_flee(cell)
	EventBus.emit_run_event(RunEventRes.Type.PLANT_FLED, {"cell": cell, "species_id": "peanut"})
	await get_tree().process_frame

	assert_bool(pathfinding.is_cell_blocked(cell)).is_true()
	assert_int(pathfinding.find_path(north, cell).size()).is_equal(0)
	pathfinding.queue_free()


func test_goal_selection_prefers_forest_core_then_root_nest() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	pathfinding.initialize_from_grid(grid)

	var core := pathfinding.get_forest_core_stub()
	assert_vector(core).is_equal(Vector2i(grid.width / 2, grid.height - 1))
	assert_int(pathfinding.get_root_nest_stubs().size()).is_equal(3)

	var from := Vector2i(-1, -1)
	for offset in [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
		var candidate: Vector2i = core + offset
		if grid.is_in_bounds(candidate) and not _is_cell_impassable(grid, candidate):
			from = candidate
			break
	if from == Vector2i(-1, -1):
		pathfinding.queue_free()
		return
	if pathfinding.find_path(from, core).is_empty():
		pathfinding.queue_free()
		return

	assert_vector(pathfinding.select_goal(from)).is_equal(core)
	pathfinding.queue_free()


func test_goal_falls_back_to_best_extract_tile() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(7)
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)

	var plant_cell := _find_walkable_cell(grid, Vector2i(2, 2))
	grid.place_plant(plant_cell, "teak", 100)
	pathfinding.initialize_from_grid(grid)

	# Block stub structure goals by depleting planted stand-ins on those cells.
	var core := pathfinding.get_forest_core_stub()
	if not _is_cell_impassable(grid, core):
		grid.place_plant(core, "peanut", 50)
		grid.set_depleted_after_flee(core)
	for nest in pathfinding.get_root_nest_stubs():
		if grid.is_in_bounds(nest) and not _is_cell_impassable(grid, nest):
			grid.place_plant(nest, "peanut", 50)
			grid.set_depleted_after_flee(nest)
	pathfinding.initialize_from_grid(grid)

	var from := Vector2i(-1, -1)
	for offset in [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]:
		var candidate: Vector2i = plant_cell + offset
		if grid.is_in_bounds(candidate) and not _is_cell_impassable(grid, candidate):
			if not pathfinding.find_path(candidate, plant_cell).is_empty():
				from = candidate
				break
	if from == Vector2i(-1, -1):
		pathfinding.queue_free()
		return

	var goal := pathfinding.select_goal(from)
	assert_vector(goal).is_equal(plant_cell)
	pathfinding.queue_free()


func test_select_goal_and_path_returns_goal_with_cached_path() -> void:
	var grid := _grid_from_fixture()
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	pathfinding.initialize_from_grid(grid)

	var start := _find_walkable_cell(grid, Vector2i(2, 2))
	var result: Dictionary = pathfinding.select_goal_and_path(start)
	var path: PackedVector2Array = result.get("path", PackedVector2Array())
	var goal: Vector2i = result.get("goal", Vector2i.ZERO)
	assert_int(path.size()).is_greater(0)
	assert_vector(Vector2i(path[path.size() - 1])).is_equal(goal)
	pathfinding.queue_free()


func _grid_from_fixture() -> GridDataRes:
	var fixture := _load_fixture()
	var grid := GridDataRes.new()
	grid.generate_from_seed(int(fixture.get("master_seed", 12345)))
	return grid


func _load_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	assert_object(file).override_failure_message("Missing golden fixture: %s" % FIXTURE_PATH).is_not_null()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_object(parsed).override_failure_message("Invalid JSON in fixture").is_not_null()
	return parsed as Dictionary


func _find_walkable_cell(grid: GridDataRes, preferred: Vector2i) -> Vector2i:
	if _is_walkable(grid, preferred):
		return preferred
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if _is_walkable(grid, pos):
				return pos
	fail("No walkable cell found")
	return Vector2i.ZERO


func _is_walkable(grid: GridDataRes, pos: Vector2i) -> bool:
	return not _is_cell_impassable(grid, pos)


func _is_cell_impassable(grid: GridDataRes, pos: Vector2i) -> bool:
	if not grid.is_in_bounds(pos):
		return true
	var cost := float(grid.get_cell(pos).get("movement_cost", 99.0))
	return cost >= 99.0 or grid.is_depleted(pos)
