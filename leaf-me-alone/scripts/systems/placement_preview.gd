extends Node2D
## Ghost preview and invalid-tile outline during PLACE_PLANT mode.

const TILE_SIZE := 16
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")

var _hover_cell: Vector2i = Vector2i(-1, -1)
var _species_id: String = ""
var _valid: bool = false
var _show: bool = false


func set_preview(cell: Vector2i, species_id: String, valid: bool, visible: bool) -> void:
	_hover_cell = cell
	_species_id = species_id
	_valid = valid
	_show = visible
	queue_redraw()


func clear_preview() -> void:
	set_preview(Vector2i(-1, -1), "", false, false)


func _draw() -> void:
	if not _show or _hover_cell.x < 0:
		return
	var rect := Rect2(_hover_cell * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
	var fill := Color(0.482, 0.788, 0.314, 0.35) if _valid else Color(1.0, 0.29, 0.29, 0.25)
	var border := Color(0.482, 0.788, 0.314, 0.9) if _valid else Color(1.0, 0.29, 0.29, 0.95)
	draw_rect(rect, fill, true)
	draw_rect(rect, border, false, 2.0)
