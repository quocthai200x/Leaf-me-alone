extends Node
## Wave 1 tutorial spawn script — 8× Saw Ape with paced intervals (FR77).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const WAVES_FALLBACK_PATH := "res://data/fallback/waves.json"

var _spawn_timer: float = 0.0
var _spawned_count: int = 0
var _target_count: int = 0
var _spawn_interval: float = 2.5
var _active_wave: int = 0
var _running: bool = false


func _process(delta: float) -> void:
	if not _running:
		return
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	if _spawned_count >= _target_count:
		_running = false
		return
	_spawn_next_ape()


func start_wave(wave_number: int) -> void:
	stop_wave()
	_active_wave = wave_number
	var script_data := _load_wave_script(wave_number)
	if script_data.is_empty():
		push_warning("[WaveSpawner] No script for wave %d" % wave_number)
		return
	_target_count = int(script_data.get("count", 0))
	_spawn_interval = float(script_data.get("interval_sec", 2.5))
	_spawn_timer = float(script_data.get("initial_delay_sec", 2.0))
	_spawned_count = 0
	_running = _target_count > 0
	EventBus.emit_run_event(
		RunEventRes.Type.WAVE_STARTED,
		{"wave": wave_number, "tutorial": script_data.get("tutorial", false)}
	)
	print("[WaveSpawner] Wave %d started — %d spawns queued" % [wave_number, _target_count])


func stop_wave() -> void:
	_running = false
	_spawned_count = 0
	_target_count = 0
	_active_wave = 0


func get_spawned_count() -> int:
	return _spawned_count


func _spawn_next_ape() -> void:
	var script_data := _load_wave_script(_active_wave)
	var ape_id := str(script_data.get("ape_id", "saw_ape"))
	if not ContentRegistry.has_ape(ape_id):
		push_error("[WaveSpawner] Unknown ape id: %s" % ape_id)
		_running = false
		return
	_spawned_count += 1
	_spawn_timer = _spawn_interval
	EventBus.emit_run_event(
		RunEventRes.Type.APE_SPAWNED,
		{
			"wave": _active_wave,
			"ape_id": ape_id,
			"index": _spawned_count,
			"total": _target_count,
		}
	)
	print("[WaveSpawner] Spawned %s (%d/%d)" % [ape_id, _spawned_count, _target_count])


func _load_wave_script(wave_number: int) -> Dictionary:
	var waves: Variant = _parse_json_file(WAVES_FALLBACK_PATH)
	if typeof(waves) != TYPE_ARRAY:
		return {}
	for entry in waves:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if int(entry.get("wave_number", -1)) != wave_number:
			continue
		var spawns: Array = entry.get("spawns", [])
		if spawns.is_empty() or typeof(spawns[0]) != TYPE_DICTIONARY:
			return {}
		var spawn_entry: Dictionary = spawns[0]
		return {
			"ape_id": str(spawn_entry.get("ape_id", "saw_ape")),
			"count": int(spawn_entry.get("count", 0)),
			"interval_sec": float(spawn_entry.get("interval_sec", 2.5)),
			"initial_delay_sec": float(spawn_entry.get("initial_delay_sec", 2.0)),
			"tutorial": bool(entry.get("tutorial", false)),
		}
	return {}


func _parse_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())
