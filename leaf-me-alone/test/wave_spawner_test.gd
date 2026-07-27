extends GdUnitTestSuite
## WaveSpawner tests (Story 4.2).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const WaveSpawnerScript := preload("res://scripts/systems/wave_spawner.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")
const ApePoolScript := preload("res://scripts/systems/ape_pool.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_slice_waves_queue_sizes_match_gdd() -> void:
	var spawner: Node = WaveSpawnerScript.new()
	add_child(spawner)
	var expected := {1: 8, 2: 8, 3: 8, 4: 8, 5: 9}
	for wave in expected.keys():
		spawner.start_wave(wave)
		assert_int(spawner.get_target_count()).is_equal(expected[wave])
	spawner.queue_free()


func test_wave_hp_multipliers() -> void:
	var spawner: Node = WaveSpawnerScript.new()
	add_child(spawner)
	var expected := [1.0, 1.2, 1.4, 1.6, 2.0]
	for i in expected.size():
		spawner.start_wave(i + 1)
		assert_float(spawner.get_hp_multiplier()).is_equal(expected[i])
	spawner.queue_free()


func test_ape_spawned_payload_includes_hp_multiplier() -> void:
	RunManager.start_run(42)
	RunManager.begin_combat_wave()

	var captured: Array = []
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.APE_SPAWNED:
			captured.append(payload)

	EventBus.run_event.connect(handler)

	var spawner: Node = WaveSpawnerScript.new()
	add_child(spawner)
	spawner.start_wave(3)
	spawner._spawn_timer = 0.0
	spawner._process(0.01)

	assert_int(captured.size()).is_equal(1)
	var data: Dictionary = captured[0]
	assert_float(float(data.get("hp_multiplier", 0.0))).is_equal(1.4)
	assert_str(str(data.get("ape_id", ""))).is_equal("saw_ape")

	EventBus.run_event.disconnect(handler)
	spawner.queue_free()


func test_wave1_tutorial_interval_pacing() -> void:
	RunManager.start_run(99)
	RunManager.begin_combat_wave()

	var captured: Array = []
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.APE_SPAWNED:
			captured.append(payload)

	EventBus.run_event.connect(handler)

	var spawner: Node = WaveSpawnerScript.new()
	add_child(spawner)
	spawner.start_wave(1)

	spawner._process(3.9)
	assert_int(captured.size()).is_equal(0)

	spawner._process(0.2)
	assert_int(captured.size()).is_equal(1)

	spawner._process(2.4)
	assert_int(captured.size()).is_equal(1)

	spawner._process(0.2)
	assert_int(captured.size()).is_equal(2)

	EventBus.run_event.disconnect(handler)
	spawner.queue_free()


func test_burst_spawns_extra_ape() -> void:
	RunManager.start_run(77)
	RunManager.begin_combat_wave()

	var captured: Array = []
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.APE_SPAWNED:
			captured.append(payload)

	EventBus.run_event.connect(handler)

	var spawner: Node = WaveSpawnerScript.new()
	add_child(spawner)
	spawner.start_wave(2)
	assert_int(spawner.get_target_count()).is_equal(8)

	spawner._burst_timer = 0.0
	spawner._process(0.01)
	assert_int(captured.size()).is_equal(1)

	EventBus.run_event.disconnect(handler)
	spawner.queue_free()


func test_debug_spawn_interval_constants() -> void:
	if OS.is_debug_build():
		assert_float(GameConstantsRes.get_ape_spawn_interval_sec()).is_equal(
			GameConstantsRes.DEBUG_APE_SPAWN_INTERVAL_SEC
		)
		assert_float(GameConstantsRes.get_ape_burst_interval_sec()).is_equal(
			GameConstantsRes.DEBUG_APE_BURST_INTERVAL_SEC
		)
	else:
		assert_float(GameConstantsRes.get_ape_spawn_interval_sec()).is_equal(
			GameConstantsRes.APE_SPAWN_INTERVAL_SEC
		)
		assert_float(GameConstantsRes.get_ape_burst_interval_sec()).is_equal(
			GameConstantsRes.APE_BURST_INTERVAL_SEC
		)


func test_ape_pool_applies_hp_multiplier() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(5)
	RunManager.grid_data = grid

	var spawn_payload := {
		"wave": 2,
		"ape_id": "saw_ape",
		"index": 1,
		"total": 8,
		"spawn_cell": Vector2i(grid.width / 2, 0),
		"move_speed_multiplier": 1.0,
		"hp_multiplier": 1.2,
	}

	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	EventBus.emit_run_event(RunEventRes.Type.APE_SPAWNED, spawn_payload)
	await get_tree().process_frame

	var role_hp := ContentRegistry.get_ape("saw_ape").hp
	var expected_hp := int(round(float(role_hp) * 1.2))
	for ape in ape_pool.get_active_items():
		assert_int(ape.max_hp).is_equal(expected_hp)
		assert_int(ape.current_hp).is_equal(expected_hp)

	ape_pool.queue_free()
