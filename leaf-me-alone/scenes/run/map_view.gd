extends Node2D
## Map container — grid display scale and pan bounds for InputRouter.

const GridRendererScene := preload("res://scenes/run/grid_renderer.tscn")
const GridDataRes := preload("res://scripts/data/grid_data.gd")

const TILE_SIZE := 16
const DISPLAY_SCALE := 3.0
const PAN_MARGIN := 80.0

var _grid_renderer: Node2D
var _visible_size: Vector2 = Vector2(1920.0, 1080.0)
var _pan_enabled: bool = false


func _ready() -> void:
	_grid_renderer = GridRendererScene.instantiate()
	_grid_renderer.scale = Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	add_child(_grid_renderer)


func sync_from_grid_data(grid: GridDataRes) -> void:
	_grid_renderer.sync_from_grid_data(grid)
	_update_pan_state()
	_clamp_position()


func set_visible_map_size(size: Vector2) -> void:
	_visible_size = size
	_update_pan_state()
	_clamp_position()


func get_map_pixel_size() -> Vector2:
	var grid: GridDataRes = RunManager.grid_data
	if grid == null:
		return Vector2.ZERO
	return Vector2(grid.width * TILE_SIZE, grid.height * TILE_SIZE) * DISPLAY_SCALE


func can_pan() -> bool:
	return _pan_enabled


func apply_pan_delta(screen_delta: Vector2) -> void:
	if not _pan_enabled:
		return
	position += screen_delta
	_clamp_position()


func _update_pan_state() -> void:
	var map_size := get_map_pixel_size()
	_pan_enabled = map_size.x > _visible_size.x or map_size.y > _visible_size.y


func _clamp_position() -> void:
	var map_size := get_map_pixel_size()
	if map_size == Vector2.ZERO:
		return
	var min_x := _visible_size.x - map_size.x - PAN_MARGIN
	var max_x := PAN_MARGIN
	var min_y := _visible_size.y - map_size.y - PAN_MARGIN
	var max_y := PAN_MARGIN
	position.x = clampf(position.x, min_x, max_x)
	position.y = clampf(position.y, min_y, max_y)
