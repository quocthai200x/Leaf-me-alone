extends Node
## Saw Ape extraction ticks while in ACT state (Story 4.3).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const SawExtractionLogicRes := preload("res://scripts/systems/saw_extraction_logic.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")

var _extract_timers: Dictionary = {}


func _ready() -> void:
	add_to_group("saw_ape_system")


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	var pool := _get_ape_pool()
	if pool == null:
		return
	for ape in pool.get_active_items():
		if ape.role_id != "saw_ape" or ape.state != ApeBaseScript.State.ACT:
			_clear_timer(ape)
			continue
		_tick_extract(ape, delta)


func _tick_extract(ape: Node, delta: float) -> void:
	var key := ape.get_instance_id()
	var timer := float(_extract_timers.get(key, 0.0))
	timer -= delta
	if timer > 0.0:
		_extract_timers[key] = timer
		return
	_extract_timers[key] = GameConstantsRes.get_saw_extract_interval_sec()
	_perform_extract(ape)


func _perform_extract(ape: Node) -> void:
	var grid := RunManager.grid_data
	if grid == null:
		return
	var target_cell: Vector2i = ape.goal_cell
	if target_cell == Vector2i.ZERO:
		target_cell = ape.grid_cell

	var abilities := _get_plant_ability_system()
	var result: Dictionary = SawExtractionLogicRes.apply_extract_tick(
		abilities,
		target_cell,
		GameConstantsRes.SAW_EXTRACT_DAMAGE
	)

	var reflect_damage := int(result.get("reflect_damage", 0))
	if reflect_damage > 0 and ape.has_method("take_damage"):
		ape.take_damage(reflect_damage)

	if bool(result.get("tile_depleted", false)):
		_emit_tile_depleted(target_cell, str(result.get("species_id", "")))
		_sync_map()


func _emit_tile_depleted(cell: Vector2i, species_id: String) -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.PLANT_FLED,
		{
			"cell": cell,
			"species_id": species_id,
			"reason": "extraction",
			"wave": RunManager.run_state.wave_index,
		}
	)


func _sync_map() -> void:
	var map_view := _get_map_view()
	var grid := RunManager.grid_data
	if map_view != null and grid != null and map_view.has_method("sync_from_grid_data"):
		map_view.sync_from_grid_data(grid)


func _clear_timer(ape: Node) -> void:
	_extract_timers.erase(ape.get_instance_id())


func _get_ape_pool() -> Node:
	var nodes := get_tree().get_nodes_in_group("ape_pool")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_plant_ability_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("plant_ability_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_map_view() -> Node:
	var nodes := get_tree().get_nodes_in_group("map_view")
	if nodes.is_empty():
		return null
	return nodes[0]
