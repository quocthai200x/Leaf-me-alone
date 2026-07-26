class_name GridData
extends Resource

const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const DEFAULT_WIDTH := 32
const DEFAULT_HEIGHT := 24

var width: int = DEFAULT_WIDTH
var height: int = DEFAULT_HEIGHT
var _cells: Array = []


func generate_from_seed(master_seed: int) -> void:
	width = DEFAULT_WIDTH
	height = DEFAULT_HEIGHT
	_cells.clear()
	_cells.resize(width * height)

	var rng := RandomNumberGenerator.new()
	rng.seed = master_seed

	var center := Vector2(width * 0.5, height * 0.5)
	var island_radius := minf(width, height) * 0.38

	for y in height:
		for x in width:
			var pos := Vector2i(x, y)
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(center)
			var noise := rng.randf_range(-1.8, 1.8)
			var effective_radius := island_radius + noise
			var soil: int = SoilTypeRes.Type.ROCK
			if dist <= effective_radius * 0.72:
				soil = SoilTypeRes.Type.RED
			elif dist <= effective_radius:
				soil = SoilTypeRes.Type.SAND
			_set_cell_raw(pos, _make_cell(soil))


func get_cell(pos: Vector2i) -> Dictionary:
	if not is_in_bounds(pos):
		return {}
	return _cells[_index(pos)].duplicate(true)


func set_cell_soil(pos: Vector2i, soil: int) -> bool:
	if not is_in_bounds(pos):
		return false
	var cell: Dictionary = _cells[_index(pos)]
	cell["soil_type"] = soil
	cell["movement_cost"] = _movement_cost_for_soil(soil)
	_cells[_index(pos)] = cell
	return true


func get_soil_type(pos: Vector2i) -> int:
	if not is_in_bounds(pos):
		return SoilTypeRes.Type.ROCK
	return int(_cells[_index(pos)]["soil_type"])


func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < width and pos.y < height


func world_to_grid(world_pos: Vector2, cell_size: float = 32.0) -> Vector2i:
	return Vector2i(floori(world_pos.x / cell_size), floori(world_pos.y / cell_size))


func count_soil(soil: int) -> int:
	var total := 0
	for cell in _cells:
		if int(cell["soil_type"]) == soil:
			total += 1
	return total


func compute_layout_hash() -> int:
	var hash := width
	hash = hash * 31 + height
	for cell in _cells:
		hash = hash * 31 + int(cell["soil_type"])
		hash = hash * 31 + int(cell["occupied"])
		hash = hash * 31 + int(cell["depleted"])
	return hash


func _index(pos: Vector2i) -> int:
	return pos.y * width + pos.x


func _set_cell_raw(pos: Vector2i, cell: Dictionary) -> void:
	_cells[_index(pos)] = cell


func _make_cell(soil: int) -> Dictionary:
	return {
		"soil_type": soil,
		"occupied": false,
		"depleted": false,
		"structure_ref": -1,
		"concrete_overlay": false,
		"movement_cost": _movement_cost_for_soil(soil),
	}


static func _movement_cost_for_soil(soil: int) -> float:
	match soil:
		SoilTypeRes.Type.RED:
			return 1.0
		SoilTypeRes.Type.SAND:
			return 1.2
		SoilTypeRes.Type.MOLD:
			return 1.5
		_:
			return 99.0
