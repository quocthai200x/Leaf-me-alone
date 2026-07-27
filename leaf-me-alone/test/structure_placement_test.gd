extends GdUnitTestSuite
## Forest Core + Root Nest placement (Story 5.1).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const StructureTypeRes := preload("res://scripts/data/structure_type.gd")
const StructureHpSystemScript := preload("res://scripts/systems/structure_hp_system.gd")
const PathfindingServiceScript := preload("res://scripts/systems/pathfinding_service.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_place_structures_seed_deterministic() -> void:
	var grid_a := GridDataRes.new()
	grid_a.generate_from_seed(42)
	grid_a.place_structures_from_seed(42)
	var grid_b := GridDataRes.new()
	grid_b.generate_from_seed(42)
	grid_b.place_structures_from_seed(42)

	assert_int(grid_a.get_structures().size()).is_equal(grid_b.get_structures().size())
	assert_vector(grid_a.get_forest_core_cell()).is_equal(grid_b.get_forest_core_cell())
	assert_array(grid_a.get_root_nest_cells()).is_equal(grid_b.get_root_nest_cells())


func test_one_core_and_three_nests_on_red_soil() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(12345)
	grid.place_structures_from_seed(12345)

	assert_int(grid.get_structures().size()).is_equal(4)
	assert_vector(grid.get_forest_core_cell()).is_not_equal(Vector2i(-1, -1))
	assert_int(grid.get_root_nest_cells().size()).is_equal(3)

	var used: Array[Vector2i] = []
	for entry in grid.get_structures():
		var cell: Vector2i = entry.get("cell", Vector2i(-1, -1))
		assert_bool(grid.is_in_bounds(cell)).is_true()
		assert_int(grid.get_soil_type(cell)).is_equal(SoilTypeRes.Type.RED)
		assert_bool(cell in used).is_false()
		used.append(cell)
		assert_bool(grid.has_structure_at(cell)).is_true()
		assert_bool(grid.can_place_plant(cell)).is_false()


func test_run_manager_places_structures_on_start() -> void:
	RunManager.start_run(777)
	var grid := RunManager.grid_data
	assert_object(grid).is_not_null()
	assert_int(grid.get_structures().size()).is_equal(4)
	assert_int(grid.get_root_nest_cells().size()).is_equal(3)


func test_pathfinding_reads_placed_structure_goals() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(7)
	grid.place_structures_from_seed(7)
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	pathfinding.initialize_from_grid(grid)

	assert_vector(pathfinding.get_forest_core_stub()).is_equal(grid.get_forest_core_cell())
	assert_array(pathfinding.get_root_nest_stubs()).is_equal(grid.get_root_nest_cells())
	pathfinding.queue_free()


func test_structure_hp_system_loads_from_grid() -> void:
	RunManager.start_run(99)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame

	var core: Dictionary = structure.get_core_state()
	assert_int(structure.get_nest_states().size()).is_equal(3)
	assert_vector(core.get("cell", Vector2i.ZERO)).is_equal(RunManager.grid_data.get_forest_core_cell())
	assert_int(core.get("current_hp", 0)).is_equal(500)
	structure.queue_free()


func test_between_wave_restoration_hook_available_with_living_nests() -> void:
	RunManager.start_run(42)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame

	assert_bool(structure.can_apply_between_wave_restoration()).is_true()
	structure.apply_between_wave_restoration_stub()
	structure.queue_free()


func test_core_structure_type_constant() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	grid.place_structures_from_seed(42)
	var core_entry := grid.get_structure_at(grid.get_forest_core_cell())
	assert_str(core_entry.get("type", "")).is_equal(StructureTypeRes.FOREST_CORE)
	assert_bool(bool(core_entry.get("restoration_enabled", false))).is_false()

	for nest_cell in grid.get_root_nest_cells():
		var nest_entry := grid.get_structure_at(nest_cell)
		assert_str(nest_entry.get("type", "")).is_equal(StructureTypeRes.ROOT_NEST)
		assert_bool(bool(nest_entry.get("restoration_enabled", false))).is_true()
