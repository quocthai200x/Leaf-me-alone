extends Node
## AStarGrid2D pathfinding synced from GridData — incremental flee updates (Story 4.1).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")

# Epic 5 stubs — replace with real Structure node positions.
const ROOT_NEST_OFFSETS: Array[Vector2i] = [
	Vector2i(-8, -2),
	Vector2i(0, -2),
	Vector2i(8, -2),
]

var _grid: GridDataRes
var _astar := AStarGrid2D.new()
var _initialized: bool = false


func _ready() -> void:
	add_to_group("pathfinding_service")
	EventBus.run_event.connect(_on_run_event)


func initialize_from_grid(grid: GridDataRes) -> void:
	_grid = grid
	_astar = AStarGrid2D.new()
	_astar.region = Rect2i(0, 0, grid.width, grid.height)
	_astar.cell_size = Vector2(1, 1)
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	for y in grid.height:
		for x in grid.width:
			_sync_cell_to_astar(Vector2i(x, y))
	_initialized = true


func find_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	if not _initialized or _grid == null:
		return PackedVector2Array()
	if not _grid.is_in_bounds(from) or not _grid.is_in_bounds(to):
		return PackedVector2Array()
	if _is_cell_impassable(from) or _is_cell_impassable(to):
		return PackedVector2Array()
	return _astar.get_id_path(from, to)


func select_goal(from: Vector2i) -> Vector2i:
	return select_goal_and_path(from).get("goal", Vector2i.ZERO)


func select_goal_and_path(from: Vector2i) -> Dictionary:
	if _grid == null:
		return {"goal": Vector2i.ZERO, "path": PackedVector2Array()}

	var forest_core := get_forest_core_stub()
	var core_path := find_path(from, forest_core)
	if not core_path.is_empty():
		return {"goal": forest_core, "path": core_path}

	var nest_result := _select_nearest_root_nest_by_path(from)
	if nest_result.get("goal", Vector2i(-1, -1)) != Vector2i(-1, -1):
		return nest_result

	var extract_result := _select_best_extract_tile_by_path(from)
	if extract_result.get("goal", Vector2i(-1, -1)) != Vector2i(-1, -1):
		return extract_result

	var center := _grid_center()
	return {"goal": center, "path": find_path(from, center)}


func get_forest_core_stub() -> Vector2i:
	if _grid == null:
		return Vector2i.ZERO
	return Vector2i(_grid.width / 2, _grid.height - 1)


func get_root_nest_stubs() -> Array[Vector2i]:
	var core := get_forest_core_stub()
	var nests: Array[Vector2i] = []
	for offset in ROOT_NEST_OFFSETS:
		var cell := core + offset
		if _grid != null and _grid.is_in_bounds(cell):
			nests.append(cell)
	return nests


func update_cell(cell: Vector2i) -> void:
	if not _initialized or _grid == null or not _grid.is_in_bounds(cell):
		return
	_sync_cell_to_astar(cell)
	_astar.update()


func is_cell_blocked(cell: Vector2i) -> bool:
	return _is_cell_impassable(cell)


func clear_blocked_cells() -> void:
	if not _initialized or _grid == null:
		return
	for y in _grid.height:
		for x in _grid.width:
			_sync_cell_to_astar(Vector2i(x, y))
	_astar.update()


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.PLANT_FLED:
		return
	var data: Dictionary = payload
	var cell: Vector2i = data.get("cell", Vector2i(-1, -1))
	if cell.x < 0:
		return
	update_cell(cell)


func _select_nearest_root_nest_by_path(from: Vector2i) -> Dictionary:
	var best_goal := Vector2i(-1, -1)
	var best_path := PackedVector2Array()
	var best_len := INF
	for nest in get_root_nest_stubs():
		if _is_cell_impassable(nest):
			continue
		var route := find_path(from, nest)
		if route.is_empty():
			continue
		if route.size() < best_len:
			best_len = route.size()
			best_goal = nest
			best_path = route
	return {"goal": best_goal, "path": best_path}


func _select_best_extract_tile_by_path(from: Vector2i) -> Dictionary:
	var candidates: Array[Dictionary] = []
	for y in _grid.height:
		for x in _grid.width:
			var pos := Vector2i(x, y)
			if not _grid.has_plant(pos):
				continue
			var cost := float(_grid.get_cell(pos).get("movement_cost", 99.0))
			if cost >= 99.0:
				continue
			candidates.append({"cell": pos, "score": 1.0 / cost})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("score", 0.0)) > float(b.get("score", 0.0))
	)
	for entry in candidates:
		var pos: Vector2i = entry.get("cell", Vector2i(-1, -1))
		var route := find_path(from, pos)
		if not route.is_empty():
			return {"goal": pos, "path": route}
	return {"goal": Vector2i(-1, -1), "path": PackedVector2Array()}


func _grid_center() -> Vector2i:
	return Vector2i(_grid.width / 2, _grid.height / 2)


func _sync_cell_to_astar(cell: Vector2i) -> void:
	var data := _grid.get_cell(cell)
	var cost := float(data.get("movement_cost", 99.0))
	var impassable := bool(data.get("depleted", false)) or cost >= 99.0
	_astar.set_point_solid(cell, impassable)
	if not impassable:
		_astar.set_point_weight_scale(cell, maxf(cost, 0.01))


func _is_cell_impassable(cell: Vector2i) -> bool:
	if _grid == null or not _grid.is_in_bounds(cell):
		return true
	var data := _grid.get_cell(cell)
	if bool(data.get("depleted", false)):
		return true
	return float(data.get("movement_cost", 99.0)) >= 99.0
