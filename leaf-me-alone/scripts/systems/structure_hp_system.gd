extends Node
## Forest Core + Root Nest HP stubs for combat HUD (Story 4.7).

const StructureHpLogicRes := preload("res://scripts/systems/structure_hp_logic.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")

var _core: Dictionary = {}
var _nests: Array[Dictionary] = []


func _ready() -> void:
	add_to_group("structure_hp_system")
	call_deferred("_bootstrap_from_pathfinding")


func _bootstrap_from_pathfinding() -> void:
	var pathfinding := _get_pathfinding_service()
	if pathfinding == null:
		_reset_defaults(Vector2i.ZERO, [])
		return
	var core_cell: Vector2i = pathfinding.get_forest_core_stub()
	var nest_cells: Array = pathfinding.get_root_nest_stubs()
	_reset_defaults(core_cell, nest_cells)


func _reset_defaults(core_cell: Vector2i, nest_cells: Array) -> void:
	_core = {
		"id": "forest_core",
		"cell": core_cell,
		"current_hp": GameConstantsRes.FOREST_CORE_MAX_HP,
		"max_hp": GameConstantsRes.FOREST_CORE_MAX_HP,
	}
	_nests.clear()
	for i in nest_cells.size():
		var cell: Vector2i = nest_cells[i]
		_nests.append({
			"id": "root_nest_%d" % i,
			"cell": cell,
			"current_hp": GameConstantsRes.ROOT_NEST_MAX_HP,
			"max_hp": GameConstantsRes.ROOT_NEST_MAX_HP,
		})


func get_core_state() -> Dictionary:
	return _core.duplicate(true)


func get_nest_states() -> Array:
	return _nests.duplicate(true)


func get_pause_summary() -> String:
	return StructureHpLogicRes.format_pause_summary(
		int(_core.get("current_hp", 0)),
		int(_core.get("max_hp", 1)),
		_nests
	)


func _get_pathfinding_service() -> Node:
	var nodes := get_tree().get_nodes_in_group("pathfinding_service")
	if nodes.is_empty():
		return null
	return nodes[0]
