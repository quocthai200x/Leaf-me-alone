extends Node
## Wave spawn scripts — interval queue + burst groups (Story 4.2).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const WAVES_PRIMARY_PATH := "res://data/waves/slice_waves.json"
const WAVES_FALLBACK_PATH := "res://data/fallback/waves.json"

var _spawn_queue: Array[String] = []
var _burst_spawns: Array[Dictionary] = []
var _spawn_timer: float = 0.0
var _burst_timer: float = 0.0
var _spawn_interval: float = 15.0
var _burst_interval: float = 60.0
var _spawned_count: int = 0
var _target_count: int = 0
var _burst_spawn_count: int = 0
var _active_wave: int = 0
var _hp_multiplier: float = 1.0
var _running: bool = false
var _queue_exhausted: bool = false


func _process(delta: float) -> void:
	if not _running:
		return
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0 and not _queue_exhausted:
		if _spawn_queue.is_empty():
			_queue_exhausted = true
			if _burst_spawns.is_empty():
				_running = false
		else:
			_spawn_from_queue()
			_spawn_timer = _spawn_interval

	_burst_timer -= delta
	if _burst_timer <= 0.0 and not _burst_spawns.is_empty():
		_spawn_burst_group()
		_burst_timer = _burst_interval


func start_wave(wave_number: int) -> void:
	stop_wave()
	_active_wave = wave_number
	var script_data := _load_wave_script(wave_number)
	if script_data.is_empty():
		push_warning("[WaveSpawner] No script for wave %d" % wave_number)
		return

	_spawn_queue = _build_spawn_queue(script_data.get("spawns", []))
	_burst_spawns = _normalize_burst_spawns(script_data.get("burst_spawns", []))
	_target_count = _spawn_queue.size()
	_spawned_count = 0
	_burst_spawn_count = 0
	_queue_exhausted = _target_count == 0
	_hp_multiplier = GameConstantsRes.get_wave_hp_multiplier(wave_number)

	if script_data.has("interval_sec"):
		_spawn_interval = float(script_data["interval_sec"])
	else:
		_spawn_interval = GameConstantsRes.get_ape_spawn_interval_sec()

	if script_data.has("burst_interval_sec"):
		_burst_interval = float(script_data["burst_interval_sec"])
	else:
		_burst_interval = GameConstantsRes.get_ape_burst_interval_sec()

	_spawn_timer = float(script_data.get("initial_delay_sec", 2.0))
	_burst_timer = _burst_interval
	_running = _target_count > 0 or not _burst_spawns.is_empty()

	EventBus.emit_run_event(
		RunEventRes.Type.WAVE_STARTED,
		{"wave": wave_number, "tutorial": script_data.get("tutorial", false)}
	)
	print(
		"[WaveSpawner] Wave %d started — %d interval spawns, %d burst entries"
		% [wave_number, _target_count, _burst_spawns.size()]
	)


func stop_wave() -> void:
	_running = false
	_spawn_queue.clear()
	_burst_spawns.clear()
	_spawned_count = 0
	_burst_spawn_count = 0
	_target_count = 0
	_active_wave = 0
	_queue_exhausted = false


func get_spawned_count() -> int:
	return _spawned_count + _burst_spawn_count


func get_target_count() -> int:
	return _target_count


func get_hp_multiplier() -> float:
	return _hp_multiplier


func get_spawn_queue_remaining() -> int:
	return _spawn_queue.size()


func _spawn_from_queue() -> void:
	if _spawn_queue.is_empty():
		return
	var ape_id: String = _spawn_queue.pop_front()
	_emit_spawn(ape_id, true)


func _spawn_burst_group() -> void:
	for entry in _burst_spawns:
		var ape_id := str(entry.get("ape_id", ""))
		var count := int(entry.get("count", 0))
		for _i in count:
			_emit_spawn(ape_id, false)


func _emit_spawn(ape_id: String, from_queue: bool) -> void:
	if not ContentRegistry.has_ape(ape_id):
		push_error("[WaveSpawner] Unknown ape id: %s" % ape_id)
		if from_queue:
			_queue_exhausted = _spawn_queue.is_empty()
			if _queue_exhausted and _burst_spawns.is_empty():
				_running = false
		return

	if from_queue:
		_spawned_count += 1
	else:
		_burst_spawn_count += 1

	var spawn_index := _spawned_count + _burst_spawn_count
	var spawn_cell := _default_spawn_cell()
	var move_mult := 1.0
	var ability_nodes := get_tree().get_nodes_in_group("plant_ability_system")
	if not ability_nodes.is_empty():
		var ability = ability_nodes[0]
		if ability.has_method("get_ape_move_speed_multiplier"):
			move_mult = ability.get_ape_move_speed_multiplier(spawn_cell)

	EventBus.emit_run_event(
		RunEventRes.Type.APE_SPAWNED,
		{
			"wave": _active_wave,
			"ape_id": ape_id,
			"index": spawn_index,
			"total": _target_count,
			"spawn_cell": spawn_cell,
			"move_speed_multiplier": move_mult,
			"hp_multiplier": _hp_multiplier,
		}
	)
	print(
		"[WaveSpawner] Spawned %s (%d total, queue %d/%d)"
		% [ape_id, spawn_index, _spawned_count, _target_count]
	)


func _default_spawn_cell() -> Vector2i:
	var grid := RunManager.grid_data
	if grid == null:
		return Vector2i.ZERO
	return Vector2i(grid.width / 2, 0)


func _build_spawn_queue(spawns: Array) -> Array[String]:
	var queue: Array[String] = []
	for entry in spawns:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var ape_id := str(entry.get("ape_id", ""))
		var count := int(entry.get("count", 0))
		for _i in count:
			queue.append(ape_id)
	return queue


func _normalize_burst_spawns(raw: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(raw) != TYPE_ARRAY:
		return result
	for entry in raw:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		result.append(entry)
	return result


func _load_wave_script(wave_number: int) -> Dictionary:
	var waves: Variant = _parse_json_file(WAVES_PRIMARY_PATH)
	if typeof(waves) != TYPE_ARRAY:
		waves = _parse_json_file(WAVES_FALLBACK_PATH)
	if typeof(waves) != TYPE_ARRAY:
		return {}

	for entry in waves:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if int(entry.get("wave_number", -1)) != wave_number:
			continue
		return _normalize_wave_entry(entry)
	return {}


func _normalize_wave_entry(entry: Dictionary) -> Dictionary:
	var normalized := entry.duplicate(true)
	var spawns: Array = entry.get("spawns", [])
	if spawns.is_empty():
		return {}

	# Legacy fallback: interval/delay nested inside first spawn entry.
	if not normalized.has("interval_sec") and typeof(spawns[0]) == TYPE_DICTIONARY:
		var first_spawn: Dictionary = spawns[0]
		if first_spawn.has("interval_sec"):
			normalized["interval_sec"] = float(first_spawn["interval_sec"])
		if first_spawn.has("initial_delay_sec"):
			normalized["initial_delay_sec"] = float(first_spawn["initial_delay_sec"])

	var clean_spawns: Array = []
	for spawn_entry in spawns:
		if typeof(spawn_entry) != TYPE_DICTIONARY:
			continue
		clean_spawns.append(
			{
				"ape_id": str(spawn_entry.get("ape_id", "saw_ape")),
				"count": int(spawn_entry.get("count", 0)),
			}
		)
	normalized["spawns"] = clean_spawns
	if not normalized.has("burst_spawns"):
		normalized["burst_spawns"] = []
	return normalized


func _parse_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())
