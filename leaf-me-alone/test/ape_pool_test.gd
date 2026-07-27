extends GdUnitTestSuite
## ApePool tests (Story 4.1).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const ObjectPoolRes := preload("res://scripts/utils/object_pool.gd")
const ApePoolScript := preload("res://scripts/systems/ape_pool.gd")
const PathfindingServiceScript := preload("res://scripts/systems/pathfinding_service.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")
const MapViewScene := preload("res://scenes/run/map_view.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_object_pool_acquire_release_and_active_count() -> void:
	var state := {"created": 0}
	var factory := func() -> int:
		state.created += 1
		return state.created
	var pool := ObjectPoolRes.new(factory, 3)
	assert_int(pool.get_capacity()).is_equal(3)
	assert_int(pool.get_available_count()).is_equal(3)
	assert_int(pool.get_active_count()).is_equal(0)

	var first: int = pool.acquire()
	var second: int = pool.acquire()
	assert_int(pool.get_active_count()).is_equal(2)
	assert_int(pool.get_available_count()).is_equal(1)
	assert_bool(first != second).is_true()

	pool.release(first)
	assert_int(pool.get_active_count()).is_equal(1)
	assert_int(pool.get_available_count()).is_equal(2)
	assert_int(state.created).is_equal(3)


func test_object_pool_returns_null_when_exhausted() -> void:
	var pool := ObjectPoolRes.new(func() -> int: return 1, 1)
	assert_int(pool.acquire()).is_equal(1)
	assert_object(pool.acquire()).is_null()


func test_ape_pool_respects_capacity_without_mid_wave_instantiate() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	var grid := GridDataRes.new()
	grid.generate_from_seed(12345)
	pathfinding.initialize_from_grid(grid)
	await get_tree().process_frame

	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	assert_int(ape_pool.get_active_count()).is_equal(0)
	var acquired := 0
	for i in GameConstantsRes.APE_POOL_SIZE:
		EventBus.emit_run_event(
			RunEventRes.Type.APE_SPAWNED,
			{
				"wave": 1,
				"ape_id": "saw_ape",
				"index": i + 1,
				"total": GameConstantsRes.APE_POOL_SIZE,
				"spawn_cell": Vector2i(grid.width / 2, 0),
				"move_speed_multiplier": 1.0,
			}
		)
		await get_tree().process_frame
		if ape_pool.get_active_count() > acquired:
			acquired = ape_pool.get_active_count()

	assert_int(acquired).is_equal(GameConstantsRes.APE_POOL_SIZE)
	assert_int(ape_pool.get_active_count()).is_equal(GameConstantsRes.APE_POOL_SIZE)

	var before_extra := map_view.get_node("Entities").get_child_count()
	EventBus.emit_run_event(
		RunEventRes.Type.APE_SPAWNED,
		{
			"wave": 1,
			"ape_id": "saw_ape",
			"index": GameConstantsRes.APE_POOL_SIZE + 1,
			"total": GameConstantsRes.APE_POOL_SIZE + 1,
			"spawn_cell": Vector2i(grid.width / 2, 0),
			"move_speed_multiplier": 1.0,
		}
	)
	await get_tree().process_frame
	assert_int(ape_pool.get_active_count()).is_equal(GameConstantsRes.APE_POOL_SIZE)
	assert_int(map_view.get_node("Entities").get_child_count()).is_equal(before_extra)

	ape_pool.queue_free()
	pathfinding.queue_free()
	map_view.queue_free()


func test_ape_pool_release_returns_ape_to_pool() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	var grid := GridDataRes.new()
	grid.generate_from_seed(99)
	pathfinding.initialize_from_grid(grid)

	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	EventBus.emit_run_event(
		RunEventRes.Type.APE_SPAWNED,
		{
			"wave": 1,
			"ape_id": "saw_ape",
			"index": 1,
			"total": 1,
			"spawn_cell": Vector2i(grid.width / 2, 0),
			"move_speed_multiplier": 1.0,
		}
	)
	await get_tree().process_frame
	assert_int(ape_pool.get_active_count()).is_equal(1)

	var entities: Node = map_view.get_node("Entities")
	var ape: Node = null
	for child in entities.get_children():
		if child.visible:
			ape = child
			break
	assert_object(ape).is_not_null()
	ape_pool.release_ape(ape)
	assert_int(ape_pool.get_active_count()).is_equal(0)
	assert_bool(ape.visible).is_false()
	assert_int(ape.state).is_equal(ApeBaseScript.State.DEAD)

	ape_pool.queue_free()
	pathfinding.queue_free()
	map_view.queue_free()
