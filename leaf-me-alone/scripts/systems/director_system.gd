extends Node
## Wave 5 Director spawn, dissatisfaction spike, and win hook (Story 5.4).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")

var _director_spawned: bool = false
var _spike_applied: bool = false
var _telegraph_timer: float = -1.0
var _spike_timer: float = -1.0
var _spike_active: bool = false


func _ready() -> void:
	add_to_group("director_system")
	EventBus.run_event.connect(_on_run_event)


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	if RunManager.run_state.wave_index != GameConstantsRes.MAX_COMBAT_WAVES:
		return
	_update_spike_timers(delta)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.WAVE_STARTED:
		var wave := int((payload as Dictionary).get("wave", 0))
		if wave == GameConstantsRes.MAX_COMBAT_WAVES:
			_reset_wave_state()
			call_deferred("_spawn_director")
			_telegraph_timer = GameConstantsRes.DIRECTOR_SPIKE_TELEGRAPH_SEC
	elif event == RunEventRes.Type.APE_KILLED:
		var data: Dictionary = payload
		if str(data.get("ape_id", "")) == "director":
			RunManager.run_state.director_defeated = true
			if RunManager.has_method("try_declare_run_win"):
				RunManager.try_declare_run_win()
	elif event == RunEventRes.Type.STATE_CHANGED:
		var to_state := int((payload as Dictionary).get("to", -1))
		if to_state != RunStateEnumRes.State.CombatPhase:
			_reset_wave_state()


func _spawn_director() -> void:
	if _director_spawned or RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	if not ContentRegistry.has_ape("director"):
		push_warning("[DirectorSystem] director ape not in ContentRegistry")
		return
	var spawn_cell := _pick_spawn_cell()
	EventBus.emit_run_event(
		RunEventRes.Type.APE_SPAWNED,
		{
			"wave": RunManager.run_state.wave_index,
			"ape_id": "director",
			"index": 0,
			"total": 1,
			"spawn_cell": spawn_cell,
			"move_speed_multiplier": 1.0,
			"hp_multiplier": GameConstantsRes.get_wave_hp_multiplier(RunManager.run_state.wave_index),
		}
	)
	_director_spawned = true
	_notify_boss_banner()


func _notify_boss_banner() -> void:
	var hud_nodes := get_tree().get_nodes_in_group("combat_hud")
	if hud_nodes.is_empty():
		return
	var hud: Node = hud_nodes[0]
	if hud.has_method("show_boss_banner"):
		hud.show_boss_banner(GameConstantsRes.DIRECTOR_BANNER_TEXT)


func _update_spike_timers(delta: float) -> void:
	if _spike_applied:
		if _spike_active:
			_spike_timer -= delta
			if _spike_timer <= 0.0:
				_spike_active = false
		return
	if _telegraph_timer >= 0.0:
		_telegraph_timer -= delta
		if _telegraph_timer <= 0.0:
			_apply_dissatisfaction_spike()
		return


func _apply_dissatisfaction_spike() -> void:
	if _spike_applied:
		return
	_spike_applied = true
	_spike_active = true
	_spike_timer = GameConstantsRes.DIRECTOR_SPIKE_DURATION_SEC
	var grid := RunManager.grid_data
	if grid == null:
		return
	var core := grid.get_forest_core_cell()
	if core == Vector2i(-1, -1):
		return
	var radius := GameConstantsRes.DIRECTOR_SPIKE_RADIUS_TILES
	var delta := GameConstantsRes.DIRECTOR_SPIKE_DISSATISFACTION
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if pos.distance_to(core) > float(radius):
				continue
			if grid.has_plant(pos):
				grid.adjust_plant_dissatisfaction(pos, delta)
	var map_view := _get_map_view()
	if map_view != null and map_view.has_method("sync_dissatisfaction_indicators"):
		map_view.sync_dissatisfaction_indicators(grid)
	EventBus.emit_run_event(
		RunEventRes.Type.DISSATISFACTION_UPDATED,
		{"source": "director_spike", "delta": delta}
	)


func _pick_spawn_cell() -> Vector2i:
	var grid := RunManager.grid_data
	if grid == null:
		return Vector2i(2, 2)
	for y in [2, 3, grid.height - 3]:
		for x in [2, grid.width - 3, grid.width / 2]:
			var pos := Vector2i(x, y)
			if grid.is_in_bounds(pos) and not grid.has_structure_at(pos):
				var cost := float(grid.get_cell(pos).get("movement_cost", 99.0))
				if cost < 99.0 and not grid.is_depleted(pos):
					return pos
	return Vector2i(2, 2)


func _reset_wave_state() -> void:
	_director_spawned = false
	_spike_applied = false
	_spike_active = false
	_telegraph_timer = -1.0
	_spike_timer = -1.0


func _get_map_view() -> Node:
	var nodes := get_tree().get_nodes_in_group("map_view")
	if nodes.is_empty():
		return null
	return nodes[0]
