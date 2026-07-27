class_name StructurePlacementLogic
extends RefCounted
## Seed-deterministic Forest Core + Root Nest placement (Story 5.1).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const StructureTypeRes := preload("res://scripts/data/structure_type.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")

const ROOT_NEST_OFFSETS: Array[Vector2i] = [
	Vector2i(-6, -3),
	Vector2i(0, -4),
	Vector2i(6, -3),
]


static func compute_structure_entries(grid: GridDataRes, master_seed: int) -> Array:
	var candidates := _collect_red_walkable_cells(grid)
	if candidates.is_empty():
		return []

	var rng := RandomNumberGenerator.new()
	rng.seed = master_seed

	var core_anchor := Vector2i(grid.width / 2, grid.height - 1)
	var core_cell := _pick_nearest_cell(candidates, core_anchor, rng)
	if core_cell == Vector2i(-1, -1):
		return []

	var used: Array[Vector2i] = [core_cell]
	var entries: Array = [
		_make_entry(StructureTypeRes.FOREST_CORE, "forest_core", core_cell),
	]

	for i in ROOT_NEST_OFFSETS.size():
		var target := core_cell + ROOT_NEST_OFFSETS[i]
		var nest_cell := _pick_nearest_unused_cell(candidates, target, used, rng)
		if nest_cell == Vector2i(-1, -1):
			continue
		used.append(nest_cell)
		entries.append(
			_make_entry(StructureTypeRes.ROOT_NEST, "root_nest_%d" % i, nest_cell)
		)

	return entries


static func _make_entry(type_id: String, id: String, cell: Vector2i) -> Dictionary:
	var max_hp := GameConstantsRes.ROOT_NEST_MAX_HP
	if type_id == StructureTypeRes.FOREST_CORE:
		max_hp = GameConstantsRes.FOREST_CORE_MAX_HP
	return {
		"id": id,
		"type": type_id,
		"cell": cell,
		"current_hp": max_hp,
		"max_hp": max_hp,
		"restoration_enabled": type_id == StructureTypeRes.ROOT_NEST,
	}


static func _collect_red_walkable_cells(grid: GridDataRes) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if grid.get_soil_type(pos) != SoilTypeRes.Type.RED:
				continue
			var cost := float(grid.get_cell(pos).get("movement_cost", 99.0))
			if cost >= 99.0 or grid.is_depleted(pos):
				continue
			cells.append(pos)
	return cells


static func _pick_nearest_cell(
	candidates: Array[Vector2i],
	target: Vector2i,
	rng: RandomNumberGenerator
) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_dist := INF
	var tie_breakers: Array[Vector2i] = []
	for cell in candidates:
		var dist := float(cell.distance_to(target))
		if dist < best_dist - 0.001:
			best_dist = dist
			best = cell
			tie_breakers = [cell]
		elif absf(dist - best_dist) <= 0.001:
			tie_breakers.append(cell)
	if tie_breakers.is_empty():
		return Vector2i(-1, -1)
	if tie_breakers.size() == 1:
		return tie_breakers[0]
	return tie_breakers[rng.randi() % tie_breakers.size()]


static func _pick_nearest_unused_cell(
	candidates: Array[Vector2i],
	target: Vector2i,
	used: Array[Vector2i],
	rng: RandomNumberGenerator
) -> Vector2i:
	var available: Array[Vector2i] = []
	for cell in candidates:
		if cell in used:
			continue
		available.append(cell)
	if available.is_empty():
		return Vector2i(-1, -1)
	return _pick_nearest_cell(available, target, rng)
