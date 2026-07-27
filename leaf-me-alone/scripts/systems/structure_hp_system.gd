extends Node
## Forest Core + Root Nest HP tracking (Stories 4.7, 5.1).

const StructureHpLogicRes := preload("res://scripts/systems/structure_hp_logic.gd")
const StructureTypeRes := preload("res://scripts/data/structure_type.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")

var _core: Dictionary = {}
var _nests: Array[Dictionary] = []


func _ready() -> void:
	add_to_group("structure_hp_system")
	call_deferred("_bootstrap_from_grid")


func _bootstrap_from_grid() -> void:
	var grid := _get_grid_data()
	if grid == null or grid.get_structures().is_empty():
		_bootstrap_from_pathfinding_fallback()
		return
	_load_from_grid(grid)


func _bootstrap_from_pathfinding_fallback() -> void:
	var pathfinding := _get_pathfinding_service()
	if pathfinding == null:
		_reset_defaults(Vector2i.ZERO, [])
		return
	var core_cell: Vector2i = pathfinding.get_forest_core_stub()
	var nest_cells: Array = pathfinding.get_root_nest_stubs()
	_reset_defaults(core_cell, nest_cells)


func _load_from_grid(grid: GridDataRes) -> void:
	var core_cell := grid.get_forest_core_cell()
	var nest_cells: Array = grid.get_root_nest_cells()
	_reset_defaults(core_cell, nest_cells)
	for entry in grid.get_structures():
		var type_id := str(entry.get("type", ""))
		var current_hp := int(entry.get("current_hp", 0))
		var max_hp := int(entry.get("max_hp", 1))
		if type_id == StructureTypeRes.FOREST_CORE:
			_core["current_hp"] = current_hp
			_core["max_hp"] = max_hp
			_core["cell"] = entry.get("cell", core_cell)
		elif type_id == StructureTypeRes.ROOT_NEST:
			for i in _nests.size():
				if str(_nests[i].get("id", "")) == str(entry.get("id", "")):
					_nests[i]["current_hp"] = current_hp
					_nests[i]["max_hp"] = max_hp
					_nests[i]["cell"] = entry.get("cell", Vector2i.ZERO)
					break


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
			"restoration_enabled": true,
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


func can_apply_between_wave_restoration() -> bool:
	for nest in _nests:
		if int(nest.get("current_hp", 0)) > 0:
			return true
	return false


func apply_between_wave_restoration_stub() -> void:
	# Story 5.2+ implements actual between-wave restoration via Root Nests.
	pass


func _get_grid_data() -> GridDataRes:
	return RunManager.grid_data


func _get_pathfinding_service() -> Node:
	var nodes := get_tree().get_nodes_in_group("pathfinding_service")
	if nodes.is_empty():
		return null
	return nodes[0]
