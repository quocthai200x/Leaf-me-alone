extends Node
## Multi-cause dissatisfaction + flee threshold detection (Stories 3.1, 3.3).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const DissatisfactionCauseLogicRes := preload(
	"res://scripts/systems/dissatisfaction_cause_logic.gd"
)
const DissatisfactionThresholdRes := preload(
	"res://scripts/systems/dissatisfaction_threshold.gd"
)
const PrBillboardLogicRes := preload("res://scripts/systems/pr_billboard_logic.gd")

var _pause_care: Dictionary = {}
var _combat_tick_timer: float = 0.0
var _hr_modifiers: Array = []
var _billboards: Array = []
var _flee_pending_cells: Dictionary = {}
var active_flee_count: int = 0


func _ready() -> void:
	add_to_group("dissatisfaction_system")
	EventBus.run_event.connect(_on_run_event)


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_combat_tick_timer -= delta
	if _combat_tick_timer > 0.0:
		return
	_combat_tick_timer = GameConstantsRes.get_dissatisfaction_combat_tick_sec()
	_apply_environmental_dissatisfaction()
	_apply_billboard_dissatisfaction()


func register_hr_modifier(center: Vector2i, radius: int = -1) -> void:
	var effective_radius := radius
	if effective_radius < 0:
		effective_radius = GameConstantsRes.HR_MODIFIER_DEFAULT_RADIUS_TILES
	_hr_modifiers.append({"center": center, "radius": effective_radius})


func clear_hr_modifiers() -> void:
	_hr_modifiers.clear()


func get_hr_modifiers() -> Array:
	return _hr_modifiers.duplicate(true)


func register_billboard(center: Vector2i, radius: int = -1) -> void:
	var effective_radius := radius
	if effective_radius < 0:
		effective_radius = GameConstantsRes.PR_BILLBOARD_RADIUS_TILES
	_billboards.append({"center": center, "radius": effective_radius})


func clear_billboards() -> void:
	_billboards.clear()


func get_billboards() -> Array:
	return _billboards.duplicate(true)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.PLANT_CARED:
		var care_payload: Dictionary = payload
		_mark_care(care_payload.get("cell", Vector2i(-1, -1)), str(care_payload.get("care_type", "")))
		return
	if event == RunEventRes.Type.PLANT_PLACED:
		var place_payload: Dictionary = payload
		_init_care_tracking(place_payload.get("cell", Vector2i(-1, -1)))
		return
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	var state_payload: Dictionary = payload
	var to_state: int = int(state_payload.get("to", -1))
	if to_state == RunStateEnumRes.State.PausePhase:
		_reset_pause_care_tracking()
		clear_billboards()
	elif to_state == RunStateEnumRes.State.CombatPhase:
		_apply_missed_care_penalties()
		_combat_tick_timer = 0.0


func _reset_pause_care_tracking() -> void:
	_pause_care.clear()
	var grid := RunManager.grid_data
	if grid == null:
		return
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.has_plant(pos):
				_init_care_tracking(pos)


func _init_care_tracking(cell: Vector2i) -> void:
	if cell.x < 0:
		return
	_pause_care[cell] = {"watered": false, "fertilized": false}


func _mark_care(cell: Vector2i, care_type: String) -> void:
	if cell.x < 0:
		return
	if not _pause_care.has(cell):
		_init_care_tracking(cell)
	var entry: Dictionary = _pause_care[cell]
	if care_type == "water":
		entry["watered"] = true
	elif care_type == "fertilize":
		entry["fertilized"] = true
	_pause_care[cell] = entry


func _apply_missed_care_penalties() -> void:
	var grid := RunManager.grid_data
	if grid == null:
		return
	var changed := false
	for cell_key in _pause_care.keys():
		var cell: Vector2i = cell_key
		if not grid.has_plant(cell):
			continue
		var entry: Dictionary = _pause_care[cell]
		var delta := DissatisfactionCauseLogicRes.compute_missed_care_delta(
			bool(entry.get("watered", false)),
			bool(entry.get("fertilized", false))
		)
		if delta <= 0:
			continue
		grid.adjust_plant_dissatisfaction(cell, delta)
		changed = true
	if changed:
		_emit_dissatisfaction_updated()
	_check_flee_thresholds()


func _apply_environmental_dissatisfaction() -> void:
	var grid := RunManager.grid_data
	if grid == null:
		return
	var weather_id := RunManager.run_state.current_weather
	var changed := false
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if not grid.has_plant(pos):
				continue
			var species_id := grid.get_plant_species_id(pos)
			var species := ContentRegistry.get_species(species_id)
			var delta := DissatisfactionCauseLogicRes.compute_environmental_delta(
				grid, pos, species, weather_id
			)
			if delta <= 0:
				continue
			grid.adjust_plant_dissatisfaction(pos, delta)
			changed = true
	if changed:
		_emit_dissatisfaction_updated()
	_check_flee_thresholds()


func _apply_billboard_dissatisfaction() -> void:
	if _billboards.is_empty():
		return
	var grid := RunManager.grid_data
	if grid == null:
		return
	var changed := false
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if not grid.has_plant(pos):
				continue
			if not PrBillboardLogicRes.is_in_aoe(pos, _billboards):
				continue
			grid.adjust_plant_dissatisfaction(pos, GameConstantsRes.PR_BILLBOARD_DISSATISFACTION_DELTA)
			changed = true
	if changed:
		_emit_dissatisfaction_updated()
	_check_flee_thresholds()


func _check_flee_thresholds() -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	var grid := RunManager.grid_data
	if grid == null:
		return
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			if not grid.has_plant(cell) or _flee_pending_cells.has(cell):
				continue
			var dissat := grid.get_plant_dissatisfaction(cell)
			var species := ContentRegistry.get_species(grid.get_plant_species_id(cell))
			var threshold := DissatisfactionThresholdRes.get_flee_threshold(
				species, cell, _hr_modifiers
			)
			if DissatisfactionThresholdRes.should_flee(dissat, threshold):
				trigger_flee(cell)


func trigger_flee(cell: Vector2i) -> void:
	var grid := RunManager.grid_data
	if grid == null or not grid.has_plant(cell) or _flee_pending_cells.has(cell):
		return
	_flee_pending_cells[cell] = true
	active_flee_count += 1
	var species_id := grid.get_plant_species_id(cell)
	EventBus.emit_run_event(
		RunEventRes.Type.FLEE_TRIGGERED,
		{
			"cell": cell,
			"species_id": species_id,
			"dissatisfaction": grid.get_plant_dissatisfaction(cell),
		}
	)


func notify_flee_completed(cell: Vector2i) -> void:
	if not _flee_pending_cells.has(cell):
		return
	_flee_pending_cells.erase(cell)
	active_flee_count = maxi(active_flee_count - 1, 0)


func _emit_dissatisfaction_updated() -> void:
	EventBus.emit_run_event(RunEventRes.Type.DISSATISFACTION_UPDATED, {})
