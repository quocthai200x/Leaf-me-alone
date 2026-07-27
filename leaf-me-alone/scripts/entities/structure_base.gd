extends Node2D
## Greybox structure entity — Forest Core / Root Nest (Story 5.1).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")

var structure_id: String = ""
var structure_type: String = ""
var grid_cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	add_to_group("structures")


func configure(id: String, type_id: String, cell: Vector2i) -> void:
	structure_id = id
	structure_type = type_id
	grid_cell = cell
	position = GameConstantsRes.grid_cell_to_local(cell)
